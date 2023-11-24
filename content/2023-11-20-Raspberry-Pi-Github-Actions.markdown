---
title: Building Nix packages for the Raspberry Pi with GitHub Actions
---

Building Nix packages for the Raspberry Pi 3 or newer requires building for an
ARM 64 architecture, which Nix refers to as `aarch64-linux`.

To build `aarch64-linux` binaries we can:

1. Build natively on an `aarch64-linux` machine.
1. Cross compile for `aarch64-linux`.
1. Compile with an emulator.

The first option is the simplest.  For example, a Raspberry Pi with Nix
installed compiles the `aarch64-linux` binaries reasonably well. Typically, you
need to build only a few packages from source and the rest may be downloaded
from the [Nix public binary cache](https://cache.nixos.org).  You can also use
a more powerful ARM 64 computer for building, if you own or rent one.

I have little to say about the second option because I never managed to get it
working.  I also suspect that cross compiled packages are not in the public
binary cache, so build times are longer than native builds.

In the rest of the article I explore the third option: compiling with an
emulator, in particular with QEMU.

# On NixOS

On NixOS, it's trivial to use QEMU to build for different architectures.  You
need to [adjust one parameter][EmulatedSystems] in your NixOS host
configuration:

```nix
boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
```

This snippet installs and configures QEMU and enables emulated builds for the
Raspberry Pi.  For example, to build
[hello](https://www.gnu.org/software/hello/) from source, run:

```
nix build nixpkgs#legacyPackages.aarch64-linux.hello --no-substitute
```

For this demonstration I added the `--no-substitute` flag to disallow binary
substitutes.  In other words, this flag forces Nix to build all packages from
source.

If the compilation with the emulated tool chain works, Nix writes an ARM 64-bit
binary at `./result/bin/hello`

# Using GitHub Actions

Recently I discovered the [setup-qemu-action][QEMUAction] from Docker which
helps us to configure a hosted GitHub Action runner to build for the Raspberry
Pi:

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: docker/setup-qemu-action@v3                                     # ⑴
      - uses: cachix/install-nix-action@v23                                   # ⑵
        with:
          extra_nix_config: "extra-platforms = aarch64-linux"
      -run: |                                                                 # ⑶
        nix build nixpkgs#legacyPackages.aarch64-linux.hello --no-substitute
```

This GitHub Actions workflow starts an Ubuntu virtual machine and installs Nix:

1. Install the QEMU static binaries using a [GitHub Action from
   Docker][QEMUAction].
1. Install Nix using a [GitHub Action from Cachix][NixAction] and configure it
   to allow building for `aarch64-linux`.
1. Build `hello` for `aarch64-linux`.

# Summary

Using two GitHub Actions from [Docker][QEMUAction] and [Cachix][NixAction] I
set up a workflow to build packages for the Raspberry Pi using freely available
Ubuntu runners from GitHub.

In a [related article][HomelabDeployment] I explain how I use this technique to
build and deploy NixOS on Raspberry Pi.

[EmulatedSystems]: https://nixos.org/manual/nixos/stable/options#opt-boot.binfmt.emulatedSystems
[QEMUAction]: https://github.com/marketplace/actions/docker-setup-qemu
[NixAction]: https://github.com/cachix/install-nix-action
[HomelabDeployment]: {filename}/2023-11-25-Homelab-deployment.markdown
