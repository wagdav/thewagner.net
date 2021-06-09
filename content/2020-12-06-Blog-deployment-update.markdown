---
title: Deploying with GitHub Actions and more Nix
---

In July I described how I use Travis CI to deploy this static site to GitHub
Pages using a Nix pipeline.  Before continuing I suggest reading [that
article][Deploying] because rest of this post builds on top of that.

This article is about the changes I made in this blog's deployment process
during the last months. These include switching to Nix Flakes, adding more
checks to the pipeline and moving from Travis CI to GitHub Actions.

# Flakes

Flakes are an experimental mechanism to package Nix expressions into composable
entities.  Flakes define a standard structure of Nix projects for hermetic and
reproducible evaluation.

The blog is still built using Nix, but now the entry point is
[flake.nix][flake.nix].  The heart of this expression is a
[function]({filename}2020-01-07-Essence-of-build-pipeline.markdown):

```nix
outputs = { self, inputs.. }:
{
  checks = ..
  modules = ..
  packages = ..
  ..
}
```

The function `outputs` takes the project's external dependencies as inputs and
returns the build artifacts in a record.  Build artifacts can be Nix packages,
NixOS modules, test results, container images, virtual machine images.
Basically anything Nix can build.  We'll see a concrete example of the `checks`
attribute in subsequent section.  There's an ongoing effort to define a
standard structure for the returned value so that specific tools can understand
and use the built derivations.

The source tree also contains a lock file [flake.lock][flake.lock] to ensure
that pages of this blog are always built with _exactly_ the same set of tools
independently where the build is executed.  The same environment is used on my
workstation, on yours, on a worker of a hosted CI system.

To learn more about Flakes I recommend the following resources:

* Presentation by Eelco Dolstra at NixCon 2019 ([Youtube][FlakesNixCon2019])
* Three-part series on Tweag's technical blog ([part 1][Flakes1],
  [part 2][Flakes2], [part 3][Flakes3])
* RFC documenting the flake's structure ([link][FlakesRFC])

# Compatibility

Currently flakes are unstable and experimental in Nix. You need to explicitly
enable flake support if you want to use them. The repository
[flake-compat][FlakeCompat] provides a compatibility function to allow flakes
to be used by non-flake-enabled Nix versions.

If you [install the Nix package manager](https://nixos.org/download.html) on
your platform and clone the repository you can build the static pages of this
site by running `nix-build` in the source tree.

With a flake-enabled, experimental Nix version you can even build the project
without cloning, directly referencing the repository on GitHub:

```console
nix build github:wagdav/thewagner.net
```

Building the static pages of this blog has no practical use for anybody but me.
But imagine if your favorite project would build on your machine without
installing _anything_ but one standalone binary?

Language-specific package managers such as `cargo`, `go get`, `npm`, `pip` work
well if your project uses _only_ that specific language.  The reality is that
even the simplest projects, such as the source code of this blog, may require
tools from _any_ language ecosystems.

# Checks

The `checks` attribute of the structure returned by the flake's `outputs`
function describes self-tests.  For this blog's source the checks look like
this:

```nix
outputs = { self, nixpkgs }:
  checks.x86_64-linux = {

    build = self.defaultPackage.x86_64-linux;

    shellcheck = pkgs.runCommand "shellcheck" { .. }

    markdownlint = pkgs.runCommand "mdl" { .. }

    yamllint = pkgs.runCommand "yamllint" { .. }
  };
};
```

The checks are grouped per supported platform, in this case there's only one:
`x86_64-linux`.  For this blog's source _checking_ means:

* Build the static the blog's static HTML files
* Run `shellcheck` on all scripts in the source code
* Run `mdl` on all markdown files in the source code
* Run `yamllint` on all YAML files in the source code

If any of these steps fail, the project is considered broken. You can see the
full code [here][flake.nix].

If you use the experimental Nix version with flake support you can execute all
the checks with the following command:

```console
nix flake check  # using Nix experimental
```

Or with stable Nix without flake-support:

```console
nix-build -a checks.x86_64-linux  # using Nix stable
```

Again, running the checks only requires the Nix package manager to be
installed.

# GitHub Actions

Previously the build and deployment scripts ran on Travis CI.  I was curious to
see how the deployment would work on GitHub Actions, which has become popular
during the past year.

The transition from Travis CI to GitHub Actions was trivial.  The [workflow
definition][Workflow] contains the minimal required boilerplate.  21 lines
specify the following steps:

* Check out the repository
* Install Nix using Cachix's
  [install-nix-action](https://github.com/cachix/install-nix-action)
* Run the checks
* Deploy the site if on the master branch

The workflow is not concerned with installing or configuring anything but Nix
and it's merely coordinating the build and deploy steps.

# Summary

I use a Nix expression to build the static pages of my blog.  The build runs
locally and on the workers of hosted CI/CD systems such as GitHub Actions and
Travis CI.  The build requires no external dependencies other than the Nix
package manager.  The build is reproducible and hermetic: no matter where the
project is built, which packages are installed, the result is always the same
everywhere.

[Deploying]: /blog/2020/07/03/deploying-thewagnernet/
[FlakeCompat]: https://github.com/edolstra/flake-compat
[flake.lock]: https://github.com/wagdav/thewagner.net/blob/efa3d5b5f62/flake.lock
[flake.nix]: https://github.com/wagdav/thewagner.net/blob/efa3d5b5f62/flake.nix
[Flakes1]: https://www.tweag.io/blog/2020-05-25-flakes/
[Flakes2]: https://www.tweag.io/blog/2020-06-25-eval-cache/
[Flakes3]: https://www.tweag.io/blog/2020-07-31-nixos-flakes/
[FlakesNixCon2019]: https://www.youtube.com/watch?v=UeBX7Ide5a0
[FlakesRFC]: https://github.com/tweag/rfcs/blob/flakes/rfcs/0049-flakes.md
[Workflow]: https://github.com/wagdav/thewagner.net/blob/efa3d5b5f62/.github/workflows/test.yml
