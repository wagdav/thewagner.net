---
title: Building container images with Nix
---

`Dockerfiles` are de facto standard for creating container images.  In this
article I highlight some issues with this approach and I propose building
container images with Nix.

# Container images

Many compute engines adopted [container images][OCI] as an interface between
your code and their runtime platform.  You package your application in a
self-contained bundle and hand it over to your compute engine of choice for
execution.  The compute engine's runtime system creates one or many container
instances based on the provided image and runs your application using some form
of isolation.

Typically the application doesn't have access to any software packages
installed on the physical computer where it runs.  Therefore, the application
can only run correctly in a container if all of its software dependencies are
also packaged in the same image.

# Dockerfile

The canonical way of creating container images is via a `Dockerfile`.  For
example, let's create an image for a [web application written in
Python][FlaskApp]:

```Dockerfile
FROM alpine:3.5  # ①

RUN apk add --update py2-pip  # ②

RUN pip install --upgrade pip  # ③

COPY requirements.txt /usr/src/app/  # ④
RUN pip install --no-cache-dir -r \
    /usr/src/app/requirements.txt  # ⑤
COPY app.py /usr/src/app/  # ⑥
COPY templates/index.html /usr/src/app/templates/  # ⑦

EXPOSE 5000
CMD ["python", "/usr/src/app/app.py"]
```

This is a short, working example which you can use to deploy a non-trivial web
application.  But if you look closely, there are some issues with this
`Dockerfile`.  Let's see them, line by line:

1. The `FROM` keyword indicates that we're starting from a base image.  In other
   words, we define a dependency on a binary blob.  You may not know what
   programs and libraries the selected base image contains.  In this specific
   case, the Alpine Linux Docker images are described in [in this
   repository][DockerAlpine].

1. The `apk` package manager, part of the base image, installs _some_ version
   of the Python interpreter which is required to run our application.
   Because we don't specify the exact version, every time you build this image
   you may install different versions.

1. We install `pip` which we'll need at subsequent build steps, but not when
   the application is running.  The problem of the unpredictable versions,
   mentioned in the previous item, applies here as well.

1. We copy the `requirements.txt` to the image.  This also only required for
   building the image.

1. The `pip` package manager installs the run-time dependencies of our
   application.  If `requirements.txt` specifies exact version numbers we know
   exactly which packages will be in the final image.

1. We copy the application, which is only a single file in this case.

1. We copy an HTML template, also required during run-time.

Each line transfers some component into the final container image.  However,
the `Dockerfile`'s imperative language fails to capture precisely our
application's dependencies:

* _Extra components_: some dependencies are only needed to build the image,
  some are essential for the application to execute correctly.  Yet, both
  kinds end up in the final image.  For example: `pip`, `apk`, and
  `requirements.txt` are not needed in the final image.

* _Implicit dependencies_: The image contains all packages from the base image
  but it's not clear which ones are actual dependencies.

* _Non-determinism_: The version of most of the dependencies are not pinned.  At
  each build different versions may be installed.

* _Package managers_: we use four different ways to manage dependencies: base
  image with the `FROM` keyword, `pip`, `apk` and copying files.

We find `Dockerfiles` with such structure used by many software projects.  I
took this section's example from a _Docker for Beginners_
[repository](https://github.com/docker/labs/tree/master/beginner).  In the next
section we'll see how novice users  write their `Dockerfiles`.

# Dockerfile from scratch

The ideal container image contains the application and the application's
dependencies and _nothing else_.

Kelsey Hightower [shows how to build such a container image][HightowerDemo] for
an application called `weather-data-collector` using the following
`Dockerfile`:

```Dockerfile
FROM scratch
COPY weather-data-collector .
ENTRYPOINT ["/weather-data-collector"]
```

This copies the application's locally built executable on the image's
filesystem.  The image contains no shell, no package manager, no additional
libraries.  Both image size and its the attack surface is minimal.  This
technique does work and creates an ideal container image and does solve all the
issues raised in the previous section.

There's a limitation though: this `Dockerfile` assumes that the application is
built as a single, statically linked binary.

Also, by reading this `Dockerfile` we don't know anything about provenance of
the application's binary: which build commands were executed, which tool chain
version is used, what additional libraries were installed before building.  To
remedy this it's common to use [multi-stage Dockerfiles][HightowerHelloWorld].
The first stage prepares the build environment and builds the application's
binary.  Then, during second stage, the binary is copied into an independent
layer.

Multi-stage builds may work well for you if you always run the application in
containers, even during development.  In my experience, however, the build
instructions in the Dockerfile quickly become the duplicate of the project's
native build instructions.

# Blame your build system

I don't believe that writing a `Dockerfile` is inherently bad.  I think the
underlying problem is that our build systems do a poor job of capturing our
application's dependencies.  The various `Dockerfile` tricks are just
workarounds for the absence of proper dependency management.

Take a look at _any_ non-trivial project's build instructions.  I bet you'll
find a getting started guide with a long list of tools and libraries to install
_before_ you can invoke the project's build system.

This is admitting that the project's dependency lists are incomplete and you
need out-of-band manipulations such as installing a package or downloading
something else from the Internet.

# Container images with Nix

[Nix]({filename}2020-04-30-Exploring-Nix.markdown) was explicitly designed to
capture _all_ dependencies of a software component.  This makes it a great fit
for building ideal container images which contain the application, the
application's dependencies and _nothing else_.

To demonstrate, here's an example which packages the HTML pages of this blog
together and a webserver into a container image.

```nix
containerImage = pkgs.dockerTools.buildLayeredImage
  {
    name = "thewagner.net";
    contents = [ pkgs.python3 htmlPages ];
    config = {
      Cmd = [
        "${pkgs.python3}/bin/python" "-m" "http.server" 8000
        "--directory" "${htmlPages}"
      ];
      ExposedPorts = {
        "8000/tcp" = { };
      };
    };
  };
```

You can run the built image yourself:

```text
docker run -p 8000:8000 wagdav/thewagner.net
```

If you visit `http://localhost:8000` you can read my articles served from the
locally running container.

This [snippet][FlakeImage] calls the function `buildLayeredImage` from the [Nix
Packages Collection][nixpkgs] to build the container image.  The function's
arguments define the image's name, contents and its configuration according to
the [OCI][OCI] specification.  The function returns a derivation which builds a
container image containing the Python interpreter, for the webserver, and the
static pages of my blog.

In short, you list the components you want in the image and Nix copies those
and their dependencies into the image archive.  Perhaps this summary sounds
underwhelming, but proper dependency management renders the building of the
container images conceptually simpler.  Instructions in a `Dockerfile` are
analogous to a shell script provisioning a freshly installed computer.  The Nix
expression looks like creating a compressed archive specifying a list of files.

To use `buildLayeredimage` you must have a Nix expression to build your
application. The [Nixpkgs manual][NixpkgsLanguages] has a long section on
building packages for various programming languages.

Concretely, for the example showed in this section,  you can find the complete
definition of `htmlPages` [here][FlakeHtml].  Everything is built from source
and the `pkgs` attribute set points to a specific commit of the [Nix Packages
collection][nixpkgs]. The image is reproducible: no software version changes
between builds unless explicitly updated.

As a bonus, this image is automatically built by [GitHub
Actions][BlogImagePush] every time I push new content in the source repository.
And this works without fiddling with [QEMU, BuildX and Docker][GHActions] or
using a special [remote Docker][CircleCI] setup.

# Summary

Dockerfiles, when used naively, yield bloated container images with
non-deterministic content.  The various techniques such as building static
executables and using multi-staged builds are just workarounds for the absence
of a programming language independent build system which is capable of
capturing all dependencies of an application.

Using Nix and the Nix Packages Collection it's possible to build minimal,
reproducible container images with a few lines of code which run locally and on
any hosted build automation system.

[HightowerDemo]: https://www.youtube.com/watch?v=U6SfRPwTKqo
[HightowerHelloWorld]: https://github.com/kelseyhightower/helloworld/blob/master/Dockerfile
[GHActions]: https://github.com/marketplace/actions/build-and-push-docker-images
[CircleCI]: https://circleci.com/docs/2.0/building-docker-images/
[OCI]: https://opencontainers.org
[FlaskApp]: https://github.com/docker/labs/blob/master/beginner/flask-app/Dockerfile
[DockerAlpine]: https://github.com/alpinelinux/docker-alpine
[FlakeImage]: https://github.com/wagdav/thewagner.net/blob/fcda05cf33ca24ed97a0a71a9139de72ecdc90c9/flake.nix#L52-L75
[FlakeHtml]: https://github.com/wagdav/thewagner.net/blob/fcda05cf33ca24ed97a0a71a9139de72ecdc90c9/flake.nix#L23-L39
[nixpkgs]: https://github.com/NixOS/nixpkgs
[FlakeBlog]: {filename}2020-12-06-Blog-deployment-update.markdown
[BlogImagePush]: https://github.com/wagdav/thewagner.net/blob/fcda05cf33ca24ed97a0a71a9139de72ecdc90c9/.github/workflows/test.yml#L22
[NixpkgsLanguages]: https://nixos.org/manual/nixpkgs/stable/#chap-language-support
