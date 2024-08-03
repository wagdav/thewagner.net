---
title: Raspberry Pi camera on NixOS
---

In this article I describe how I configured my Raspberry Pi V1 camera module
working on my Raspberry Pi 3 running NixOS.

The Raspberry Pi OS has [excellent support][RPi-Camera-Configuraiton] for many
camera modules.  If you run the officialy supported operating system most
cameras work without any further configuration.

In my Homelab I don't use the Raspberry Pi OS, but I run NixOS on my Raspberry
Pis.  This works reasonably well, but the camera module I own needs special
configuration.

# The "modern" camera stack

In 2020 the Raspbery Pi team [released a new camera
stack][libcameraAnnouncement] which provides better access to the internals of
the camera system.  Today the legacy system, based on Broadcom proprietary
software, is unsupported and obsolete.  Unfortunately, many online instructions
and tutorials [still refer to the Broadcom stack][CameraNotDetected] which
renders them irrelevant to the modern camera stack.

The new camera stack is built out the following components:

1. Linux kernel using board specific configurations
1. Camera module specific drivers (in my case Omnivision OV5647 for my version 1 module)
1. libcamera library built from Raspberry Pi
1. rpicam-apps camera utilities from the Rapberry Pi foundation

The next sections describe how I put these together on NixOS.

## Kernel 

The Nix Packages collections have a few variants of the Linux kernel.  The
default one works on most hardware without any problems.  For my Raspberry Pi 3
I select the `linux_rp3` kernel package, which is built from the Raspberry Pi
foundation's fork.

```
{ pkgs, ...}:
{
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_rpi3;
}
```

## Camera driver (OV5647)

```
{ pkgs, ...}:
{

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_rpi3;

  https://wiki.nixos.org/wiki/NixOS_on_ARM/Raspberry_Pi#Camera

  hardware.deviceTree.filter = "bcm2837-rpi-3*";
  hardware.deviceTree.overlays = [
    name = "ov5647-overlay";
    dtsText = '''
    ''';
  ]
}
```

## libcamera

## rpi-apps


[libcameraAnnouncement]: https://www.raspberrypi.com/news/an-open-source-camera-stack-for-raspberry-pi-using-libcamera/
[CameraNotDetected]: https://forums.raspberrypi.com/viewtopic.php?t=362707
[RPi-Camera-Configuration]: https://www.raspberrypi.com/documentation/computers/camera_software.html#configuration
[NixWikiCamera]: https://wiki.nixos.org/wiki/NixOS_on_ARM/Raspberry_Pi#Camera
