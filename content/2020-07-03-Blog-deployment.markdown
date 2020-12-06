---
title: Deploying thewagner.net
---

For a long time I've been manually deploying this blog to [GitHub
Pages][GithubPages].  This worked OK because I publish less than once a month.
But I always wished for a better, automatic solution.  Recently I used Nix to
rebuild [my home network][Homelab] and I was curious if I can improve the
workflow of publishing my articles to [thewagner.net](https://thewagner.net).

# Ingredients

I write the articles in Markdown files which are converted to static HTML files
by [Pelican][Pelican].  The source content is stored in a [Git
repository][GitHubThewagnerNet].  I push to this repository when I write new
content.

The blog is served from [GitHub Pages][GithubPages] so I don't have to manage
any servers.  GitHub expects the HTML pages in a repository with a specific
name: in my case this is [wagdav.github.com][WagdavGitHubIo].  This repository
only hosts generated content. I push to this repository when I want to publish
the changes in the source repository.

I configured [Travis CI][TravisCI] to execute the build and deploy steps when a change
is committed to the source repository.

In short:

* The source repository [thewagner.net][GitHubThewagnerNet] stores articles.
* The deployment repository [wagdav.github.io][WagdavGitHubIo] stores generated
  HTML pages.
* When triggered, Travis CI checks out the source repository, builds the blog
  and pushes the generated files to the deployment repository.

Let's see the build and deploy steps in detail.

# Build

The build pipeline is defined as a [Nix expression][CodeDefaultNix].  I don't
explain how it works, but I highlight the steps it performs:

* Build the static website using Pelican.
* Run static analysis on the bash scripts using [shellcheck][ShellCheck].
* Run [markdownlint][Markdownlint] to flag formatting issues in the articles.

These steps depend on tools from three different language ecosystems: Pelican
is a Python project, shellcheck and markdownlint are written in Haskell and
Ruby, respectively.  Yet, the _only_ dependency of running this pipeline is the
Nix package manager.

To execute all the checks and build the blog I run:

```shell
nix build
```

All dependencies are pinned to a specific version of Nix Packages therefore
this command always uses the same version of _every_ tool and library no matter
where or when it is executed.

# Deploy

A [shell script][CodePublishSh] pushes the generated HTML files to the
deployment repository:

```shell
./scripts/publish.sh
```

Because the script runs within a Nix shell, again, Nix is the only dependency
and I don't have to install any additional tools or libraries to run it.

# Automate

The commands described in the previous sections can be executed on my local
workstation.  However, to deploy my changes reliably I choose [Travis
CI][TravisCI] to automate the build, check and deployment steps.

The Nix support of Travis CI is fantastic: it takes only [seven lines of sweet
YAML][CodeTravisYAML] to setup everything:

```yaml
language: nix

deploy:
  provider: script
  script: nix-shell scripts/publish.sh $GITHUB_TOKEN
  on:
    branch: master
```

Behind the scenes this configuration builds the artifacts described in
[default.nix][CodeDefaultNix] and executes the [publish.sh][CodePublishSh] when
the change was triggered on the `master` branch.  The secret value
`GITHUB_TOKEN` is configured on the Travis CI web interface.

# Summary

Deploying my blog is now fully automatic:  I only push the contents of the
articles to a repository.  A hosted service builds and deploys the HTML pages.
I can develop, test and execute each step of the pipeline locally and  the
dependency on hosted services is isolated to a few lines of code.

[CodeDefaultNix]: https://github.com/wagdav/thewagner.net/blob/3e423bb/default.nix
[CodePublishSh]: https://github.com/wagdav/thewagner.net/blob/3e423bb/scripts/publish.sh
[CodeTravisYAML]: https://github.com/wagdav/thewagner.net/blob/3e423bb/.travis.yml
[GithubPages]: https://pages.github.com/
[GitHubThewagnerNet]: https://github.com/wagdav/thewagner.net
[Homelab]: {filename}2020-05-31-Homelab.markdown
[Markdownlint]: https://github.com/markdownlint/markdownlint
[Pelican]: https://blog.getpelican.com/
[TravisCI]: https://travis-ci.org/
[WagdavGitHubIo]: https://github.com/wagdav/wagdav.github.com
[Shellcheck]: https://github.com/koalaman/shellcheck
