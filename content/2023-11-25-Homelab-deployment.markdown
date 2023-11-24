---
title: Homelab deployment
---

I configured continuous deployment in [my homelab][Homelab]. This article
describes how I use Nix with GitHub Actions and Cachix Deploy to automatically
deploy NixOS machines on my home network.

# Overview

My home network comprises a wirelesss router, a few computers, temperature and
humidity sensors and remote controllable switches.  I configure these devices
mainly using Nix, and when it's possible, I run NixOS on them.  I use this
setup to experiment with [home automation and to learn about new
tools][Homelab]. The entire configuration of my home network is [available on
GitHub][HomelabRepo].

The configuration of the NixOS servers was always built from a declarative
specification stored in version control system. But the deployment of the new
configuration was manual, slow and often tedious.  I ran `nixos-build` from the
command line, and sometimes I had to wait an hour to build and deploy the new
machine configuration.

I wanted to reconfigure my servers automatically, triggered by committing to a
Git repository.

To solve this problem I built a system based on Nix and freely available hosted
services:

![Figure1]({static}/images/homelab-deployment.svg "Homelab deployment")

The automatic deployments work as follows:

1. The [Homelab repository][HomelabRepo] contains the NixOS host configurations.
1. A workflow in [GitHub Action][HomelabAction] _builds_ the NixOS system and
   _stores_ it in a [hosted binary cache](https://www.cachix.org/).
1. An agent on the target machine _pulls_ the built binaries from the cache and
   _activates_ the new deployment.

# Host configuration

The configuration of my servers is written in the Nix language.  For example,
[host-nuc.nix][HomelabNuc] describes the hardware and software configuration of
my Intel NUC device:

```nix
{ config, ... }:

{
  imports = [
    ./hardware/nuc.nix
    ./modules/cachix.nix
    ./modules/common.nix
    ./modules/consul/server.nix
    ./modules/git.nix
    ./modules/grafana
    ./modules/loki.nix
    ./modules/mqtt.nix
    ./modules/prometheus.nix
    ./modules/push-notifications.nix
    ./modules/remote-builder
    ./modules/traefik.nix
    ./modules/vpn.nix
  ];

  system.stateVersion = "22.05";
}
```

The configuration is split into modules.  Glancing at the `imports` block you
can tell what is installed on this machine.  The host `nuc` is my main home
server, it runs all my "production" services.

For example, the `cachix.nix` module configures the [Cachix
Agent](https://docs.cachix.org/deploy/running-an-agent/) which is responsible
for reconfiguring the NixOS machine when a new build is available.  The agent
runs on all machines whose configuration automatically managed.

# Building with GitHub Actions

The NixOS host specifications are built with a single `nix build` command:

```
nix build .#nixosConfigurations.nuc.config.system.build.toplevel
```

This builds the whole system for the `nuc` machine: the kernel, the installed
packages and their configuration.  By default, `nix` downloads pre-built
packages from the [NixOS public binary cache](http://cache.nixos.org/), so a
typical execution of the build command takes only a few minutes.

To run the build in GitHub Actions, the build job installs Nix and configures
the access to the Cachix binary cache where the deployment artifacts are
stored:

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    environment:
      name: Homelab
      url: "https://app.cachix.org/deploy/workspace/lab.thewagner.home/"  # ⑴
    steps:
      - uses: actions/checkout@v4
      - uses: docker/setup-qemu-action@v3                                 # ⑵
      - uses: cachix/install-nix-action@v23
        with:
          extra_nix_config: "extra-platforms = aarch64-linux"             # ⑶
      - uses: cachix/cachix-action@v12                                    # ⑷
        with:
          name: wagdav
          authToken: '${{ secrets.CACHIX_AUTH_TOKEN }}'
      - run: nix build --print-build-logs .#cachix-deploy-spec            # ⑸
      - run: |                                                            # ⑹
          cachix push wagdav ./result
          cachix deploy activate --async ./result
        env:
          CACHIX_ACTIVATE_TOKEN: "${{ secrets.CACHIX_ACTIVATE_TOKEN }}"
```

The `build` job of the [workflow][HomelabAction]:

1. Configures a [deployment target][GitHubEnvironment]. When a GitHub Actions
   workflow deploys to an environment, the environment is displayed on the main
   page of the repository.
1. Installs the QEMU static binaries for building packages for architectures
   different than that of the build runner.
1. Configures Nix to use emulation to [build ARM 64 packages][QEMUBuilds].
1. Configures the [Cachix hosted binary cache](https://cachix.org).
1. Builds the [deploy specification][DeploySpec] which is a set of the NixOS
   systems to deploy.
1. Pushes the built binaries to the cache and sends an activation signal to the
   Cachix Agent.

The job uses two secrets: `CACHIX_AUTH_TOKEN` is the authentication token to
push to the binary cache and `CACHIX_ACTIVATE_TOKEN` is required to activate
the built NixOS configurations.

# Deploying with Cachix Deploy

To deploy the built NixOS configurations I use the generous free-tier of
[Cachix Deploy](https://docs.cachix.org/deploy/).  Following their
documentation, I installed `cachix-agent` on the target hosts and configured a
few authentication keys.

The agent process connects to the Cachix backend and waits for a deployment.
When a new deployment is available, the agent pulls the relevant binaries from
the binary cache and reconfigures the NixOS system it runs on.

# Summary

Since I configured [automatic deployment of this blog][BlogDeployment] I wanted
the same for my home infrastructure.  I had my configuration repository and I
knew how to build the machine configurations with GitHub Actions.  I was
missing the automatic deployment part until Cachix Deploy was announced.
Cachix has excellent documentation and the integration with my Homelab was
super simple.

# Acknowledgement

I'm grateful to [Cachix Deploy](https://www.cachix.org/) for offering a binary
cache and a deployment service.

[BlogDeployment]: {filename}/2020-12-06-Blog-deployment-update.markdown
[DeploySpec]: https://docs.cachix.org/deploy/deploying-to-agents/#write-deploy-specification
[GitHubEnvironment]: https://docs.github.com/en/actions/deployment/about-deployments/deploying-with-github-actions#using-environments
[HomelabAction]: https://github.com/wagdav/homelab/blob/master/.github/workflows/build-and-deploy.yml
[HomelabNuc]: https://github.com/wagdav/homelab/blob/master/host-nuc.nix
[HomelabRepo]: https://github.com/wagdav/homelab
[Homelab]: {filename}/2020-05-31-Homelab.markdown
[QEMUBuilds]: {filename}/2023-11-20-Raspberry-Pi-Github-Actions.markdown
