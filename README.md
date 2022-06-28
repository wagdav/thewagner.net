Source of [my personal homepage](https://thewagner.net), using [Pelican](http://getpelican.com)

# Requirements

Install the [Nix package manager](https://nixos.org/nix/):

```shell
curl -L https://nixos.org/nix/install | sh
```

# Commands

Run a development server

```shell
scripts/devserver.sh
```

Make a release:

```shell
scripts/publish.sh
```

# Container image

The contents of the blog is packaged as a OCI/Docker image.  At each build the
container image is pushed to DockerHub.  Run the image with the following
command:

```
docker pull wagdav/thewagner.net
docker run --rm -it -p 8000:8000 wagdav/thewagner.net
```

Open <http://localhost:8000/> in your browser.
