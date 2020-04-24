---
title: Exploring Nix
---

For the last few weeks I've been exploring [NixOS](https://nixos.org/) and its
related tools.  This article is an experience report and a collection of
learning material I find useful.

NixOS is a unique Linux distribution with [origins][Wikipedia] in
[research][DolstraThesis] conducted at Utrect University.  NixOS handles
software delivery and configuration in a different way than any other
distribution I know.  The entire operating system is treated as an immutable
value which  makes deploying and maintaining NixOS-based systems easy and
reliable.

## The language

NixOS, is configured using the
[Nix expression language][NixExpressionLanguage]:
a small, purely functional programming language.  Besides the usual data types
(booleans, numbers, strings, lists and sets) Nix has some features which are
uncommon in configuration languages.

Let blocks bind values to symbols. The bindings appear after the keyword `let`
and the symbols can be used after the keyword `in`.  For example, the
expression:

``` nix
let
  x = "a";
  y = "b";
in
  x + y + x
```
evaluates to `"aba"`.

In Nix, functions are first-class values.  A function which adds one to a value is defined succinctly:
```
n: n + 1
```

Typically, functions take sets as arguments and return sets as results.  This expression defines and calls the `endpoints` function:
``` nix
let
  endpoints = { engine, domain }: {
    http = "http://${engine}.${domain}";
    https = "https://${engine}.${domain}";
  };
in
  endpoints { engine = "google"; domain = "com"; }
```

which evaluates to:

``` nix
{ http = "http://google.com"; https = "http://google.com"; }
```

This last example also shows how symbols in the current scope are interpolated
in strings using `${}`.

These constructs are sufficient to read the examples in this article.  For a
comprehensive overview of the language features see [this tutorial][LearnXinYminutes].


## Derivations

A _derivation_, a core concept of Nix, is a build recipe: it describes how to
obtain, in other words _derive_, a component from its inputs.  Let's make this
statement more concrete with an example.

We will use Nix to put a string into a file using a build action equivalent to:

``` shell
$ echo hello from Nix > output.txt
```

This build runs the `echo` shell command to generate a file.  The build
requires no input source files, but a shell to be present.  We could use `bash`
but from where do we get its executable?

Typical build systems assume that certain programs are available in the build
environment.  Nix doesn't make such assumptions.  Builds are performed in
isolation: no programs, no environment variables, nor access to the outside
world are available unless explicitly specified.

In programming we use a function to abstract over an input parameter of a
computation.  Let's do the same and write a function which takes `bash` as
input and returns the build recipe, a derivation:

``` nix
# hello.nix
{ bash } :

derivation {
  name = "hello";
  builder = "${bash}/bin/bash";
  args = [ "-c" "echo hello from Nix > $out" ];
  system = builtins.currentSystem;
}
```

`derivation` is keyword of the Nix language.  It's represented as a set with
specific attributes: a name, a program and its arguments to produce some
output, and a specification of the operating system's architecture where this
derivation can be built.

The `bash` argument is a dependency, it refers to a derivation which must be
built before the `hello` derivation.

To understand better the derivation's structure, let's assume we have `bash`
built and we evaluate the `hello` derivation.  Nix stores the resulting
derivation in the following structure:

``` json
{
  "/nix/store/61lcv6k65f42d3v8nww7m7k48h7v9mhy-hello.drv": {
    "outputs": {
      "out": {
        "path": "/nix/store/qcnf97fclrnqppq3h5ld9smqdb8l2ybk-hello"
      }
    },
    "inputSrcs": [],
    "inputDrvs": {
      "/nix/store/8ynv2wxv6vaa75sbpmz8rnlbv1bxcfzn-bash-4.4-p23.drv": [
        "out"
      ]
    },
    "platform": "x86_64-linux",
    "builder": "/nix/store/9si14qjcz8072c0v42zbkglq08s2cg04-bash-4.4-p23/bin/bash",
    "args": [
      "-c",
      "echo hello from Nix > $out"
    ],
    "env": {
      "builder": "/nix/store/9si14qjcz8072c0v42zbkglq08s2cg04-bash-4.4-p23/bin/bash",
      "name": "hello",
      "out": "/nix/store/qcnf97fclrnqppq3h5ld9smqdb8l2ybk-hello",
      "system": "x86_64-linux"
    }
  }
}
```

In this representation we can see how Nix stores the build artifacts under
`/nix/store`.  The filenames in the store are cryptographic hashes of the
defining Nix expression suffixed with a readable, user-provided name.

This data structure is a concrete description how to build the `hello`
greeting:

* _Outputs_: the derivation yields one output named `out`.  The output will be
  stored under the given path.

* _InputSrcs_: the derivation requires no input sources

* _InputDrvs_: the derivation depends on the derivation which builds `bash`.

* _Platform_: on my PC the expression `builtin.currentSystem` evaluates to `x86_64_linux`.

* _Builder and args_: the program and its arguments we provided, but now
  referencing concrete artifacts in the store.

* _Env_: the environment variables available during build.  These are
  originating from the dervation's attributes we provided in the Nix
  expression.  We reference `$out` in the build script.

Derivations are just data without any knowledge of the Nix language.  When
evaluated, a Nix expression typically produces many, interdependent derivations
which are built in topological order, that is each derivation is built after
their dependent derivations.

Nix builds a component in two stages:

1. Evaluates the expression and writes resulting derivations in the Nix store.
2. Builds the derivation and writes build results in the Nix store.

Nix expressions provide a high-level language for developers to define
components, component configuration and component relationships.  Derivations
encode build instructions for a single component for a given configuration in a
well-defined environment.

Nix expressions can be evaluated on any system where Nix is installed.
Derivations may be copied to other nodes for building: to a build farm, or to
nodes with special hardware.


## Build the example

To build the example in the previous section, save the expression in a file
named `hello.nix` and run:

``` shell
$ nix-build hello.nix --arg bash '(import <nixpkgs> {}).bash'
/nix/store/qcnf97fclrnqppq3h5ld9smqdb8l2ybk-hello
```

The `--arg` switch tells Nix to use the `bash` package from the [Nix Packages
collection][Nixpkgs].  `nix-build` prints the path where the build result is
stored.  By default, `nix-build` also creates a symbolic link to the build
result in the current working directory so it's easy to verify if we find the
string we expect:

``` shell
$ < result
hello from Nix
```

To see the internal structure of the derivation, run the command:
``` shell
nix show-derivation /nix/store/qcnf97fclrnqppq3h5ld9smqdb8l2ybk-hello
```
which outputs data structure as shown in the previous section.


## Composing an operating system

The Nix language provides a clean component description formalism: [a single
expression][AllPackages] builds 40000 packages on multiple platforms.  To
achieve this scale, higher-level abstractions are built from the Nix language
primitives.

[Modules][NixWikiModules] are functions which return a set with specific
attributes:

``` nix
{ config, pkgs, ... }:

{
  imports = [
    # paths to other modules
  ];

  options = {
    # option declarations
  };

  config = {
    # option definitions
  };
}
```

Modules are useful for configuring complete subsystems such as networking,
printing, graphics and so on.  The top-level NixOS configuration, typically
stored in `/etc/nixos/configuration.nix`, is a module itself which may include
other modules.

For example, the [firewall module][ModuleFirewall] allows you to specify the
open ports of your system:

```
networking.firewall.allowedTCPPorts = [ 80 ];
```

The module keeps the intricacies of generating iptables rules within its
implementation.  Our system configuration remains simple and declarative.


## Applications

The existence of [NixOS](http://nixos.org) proves that the Nix expression
language is a solid foundation for software packaging and software delivery.
NixOS is not the most popular [Linux
distribution](https://distrowatch.com/table.php?distribution=nixos) today, but
if you felt the pain of server management using tools like Puppet, Salt or
Ansible, you should definitely give NixOS a try.

You don't have to replace your operating system to try Nix.  You can use Nix
packages on [Linux and Mac systems](https://nixos.org/nix/) to set up and share
build environments for your projects, regardless of what programming languages
and tools you're using.

The Nix model can also be used to [deploy
servers](https://github.com/NixOS/nixops) and for [continuous integration and
delivery](https://github.com/NixOS/hydra).

## Learn more

This section is a collection of online resources which I find useful to learn
about Nix.

Learn the Nix language:

* [Learn X in Y minutes where X=Nix][LearnXinYminutes]
* [Nix Expression Language section of the Nix Manual][NixExpressionLanguage]

Learn about modules and overlays:

* [Modules][NixWikiModules]
* [Overlays][NixWikiOverlays]

Browse Nix packages and NixOS options:

* [Search NixOS packages][NixPkgs]
* [Search NixOS options][NixOptions]

Read about the original research:

* [Integrating Software Construction and Software Deployment][DolstraIntegrating] (Nix used to be called Maak)
* [The Purely Functional Software Deployment Model][DolstraThesis]

Additionally, the NixOS Wiki contains [a list of learning resources][NixWikiResources].

## Summary

After a few weeks of learning I'm amazed by Nix.  I believe NixOS is the best
operating system to deploy from a declarative configuration.  The expression
language, the Nix store, the evaluation and build strategy were built for
painless software deployments.

If you value infrastructure as code and immutable deployments you should
definitely spend time on Nix and its core concepts.

I updated my main laptop and my servers at home to NixOS.  The configuration of
all my machines is [available on GitHub](https://github.com/wagdav/homelab).

[AllPackages]: https://github.com/NixOS/nixpkgs/blob/master/pkgs/top-level/all-packages.nix
[DolstraIntegrating]: https://edolstra.github.io/pubs/iscsd-scm11-final.pdf
[DolstraThesis]: https://edolstra.github.io/pubs/phd-thesis.pdf
[LearnXinYminutes]: https://learnxinyminutes.com/docs/nix/
[ModuleFirewall]: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/networking/firewall.nix
[NixExpressionLanguage]: https://nixos.org/nix/manual/#ch-expression-language
[NixOptions]: https://nixos.org/nixos/options.html
[NixPkgs]: https://nixos.org/nixos/packages.html
[NixWikiModules]: https://nixos.wiki/wiki/Module
[NixWikiOverlays]: https://nixos.wiki/wiki/Overlays
[NixWikiResources]: https://nixos.wiki/wiki/Resources
[Wikipedia]: https://en.wikipedia.org/wiki/NixOS
