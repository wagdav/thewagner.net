---
title: Raspberry Pi camera on NixOS
---

In this article, I describe how I configured my Raspberry Pi v1 camera module
on my Raspberry Pi 3 running NixOS.

The Raspberry Pi OS has [excellent support][RPi-Camera-Configuration] for many
camera modules.  If you run the officially supported operating system, most
cameras work without any further configuration.

In my [Homelab][Homelab] I don't use the Raspberry Pi OS, but I run NixOS on all
my computers, including the Raspberry Pi.  NixOS works well on the Pi, but the
camera module I own needs a special configuration.

# The "new" camera stack

Four years ago, the Raspberry Pi team [released a new camera
stack][libcameraAnnouncement] that provides better access to the internals of
the camera system.  Today, the old stack using Broadcom proprietary software is
unsupported and obsolete.  Unfortunately, many online instructions and tutorials
[still refer to the Broadcom stack][CameraNotDetected] which renders them
irrelevant to the modern camera stack.

The new camera stack comprises four layers:

1. Linux kernel with board-specific configuration
1. Camera-specific drivers
1. The libcamera library
1. rpicam-apps camera utilities for taking photos and videos

The next sections describe how I configured these components on NixOS to use a
Raspberry Pi v1 camera module (Omnivision OV5647) with my Raspberry Pi 3B.

## Kernel

The official NixOS installer works well on the Raspberry Pi.  However, the camera
modules require some subsystems that are not enabled by default.

Fortunately, it's easy to switch to a kernel tailored to the Raspberry Pi.  For
my model 3B, I select the `linux_rp3` kernel package:

```
{ pkgs, ...}:
{
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_rpi3;
}
```

Actually, I don't adjust this parameter in [my configuration][HomelabHostRpi3],
but I import the `raspberry-pi-3` module from
[nixos-hardware][NixOSHardwareRPi3] which selects the correct kernel and tunes
a few other parameters too.

## Camera driver (OV5647)

The Raspberry Pi v1 camera module uses an Omnivision OV5647 image sensor.  We
need to describe the OV5647 hardware to the kernel so that the sensor can be
controlled via the respective system calls.  The data structure and language
for describing hardware is called the _device tree_.

This is NixOS configuration block that enables the image sensor:

```
{ pkgs, ...}:
{
  hardware.deviceTree.filter = "bcm2837-rpi-3*";
  hardware.deviceTree.overlays = [
    name = "ov5647-overlay";
    dtsText = '''
       ...ELIDED...
    ''';
  ]
}
```

For brevity, I omitted the value of the `dtsText`.  In my Homelab repository you
can read the full [device tree overlay configuration][HomelabDeviceTreeOverlay].

The `dtsText` string is a copy of the file
[ov5467-overlay.dts][ov5467-overlay.dts] from the Linux kernel source with one
modification: I changed the `compatible` property from `bcm2835` to `bcm2837`.
It turns out the OV546 device tree overlay is compatible with both BCM
chipsets, but I don't understand why overlay's source doesn't reflect this.

I learned about this technique in [a GitHub issue
comment](https://github.com/NixOS/nixpkgs/issues/125354). It works™, the kernel
recognizes the image sensor on the I2C bus:

```
$ cat /sys/bus/i2c/devices/10-0036/name
ov5647
```

It was hard to get the device tree overlay working, but I'm not entirely
satisfied:  fiddling with the device tree source files doesn't
feel right.

Fortunately, the hardware configuration is done. Next, the software stack.

## libcamera

The libcamera library drives the Raspberry Pi's camera system directly from the
Linux kernel, with minimal proprietary code running on the Broadcom GPU.

libcamera is part of [nixpkgs][NixpkgsLibcamera], but it's built without
support for the Raspberry Pi.  I developed a [Nix package
overlay][HomelabLibcamera], based on the [Raspberry Pi specific libcamera
instructions][BuildLibcamera], which the compiles libcamera with a few
additional flags:

```
mesonFlags = old.mesonFlags ++ [
  "-Dcam=disabled"
  "-Dgstreamer=disabled"
  "-Dipas=rpi/vc4,rpi/pisp"
  "-Dpipelines=rpi/vc4,rpi/pisp"
];
```

The upstream libcamera package uses the Meson build system.  In the previous
snippet, `old.mesonFlags` refers to the upstream package's build flags.  The
overlay appends to the original flag list enabling the Raspberry Pi specific
Image Processing Algorithms (IPAs) and pipelines.

This example shows off the strength of the Nix Packages overlay systems: the
overlay describes the differences from the upstream package's build
instructions, like a _patch_ representing the differences between two versions
of a text file.

## rpicam-apps

rpicam-apps is a set of command line applications, built on top of libcamera,
to capture images and video from a Raspberry Pi camera.

Based on a [draft pull-request in nixpkgs][NixpkgsLibcameraPR], I wrote [a Nix
derivation][HomelabRpicamApps] which builds rpicam-apps using my own libcamera
build and enabling only a minimal set of features.  For example, I deactivate
support for preview windows and advanced post-processing capabilities.

# Picture time

I collected the configuration I described in the previous sections in a [NixOS
module][HomelabCameraModule] which is imported from my [Raspberry Pi 3 host
configuration][HomelabHostRpi3].

After the configuration is deployed on the device, I can list the available
cameras:

``` text
$ rpicam-still --list-cameras
Available cameras
-----------------
0 : ov5647 [2592x1944 10-bit GBRG] (/base/soc/i2c0mux/i2c@1/ov5647@36)
    Modes: 'SGBRG10_CSI2P' : 640x480 [58.92 fps - (16, 0)/2560x1920 crop]
                             1296x972 [43.25 fps - (0, 0)/2592x1944 crop]
                             1920x1080 [30.62 fps - (348, 434)/1928x1080 crop]
                             2592x1944 [15.63 fps - (0, 0)/2592x1944 crop]
```

And, I can take a picture:

```
rpicam-still --output test-image.jpg
```

I won't try to impress you with the quality of the recorded image.  The v1
camera module is [old][v1Release], the modules available today have much better
sensors and optics.

# Summary

I use NixOS because the operating system is described in a declarative
configuration.  The camera specific modifications I described in this article
are in a [NixOS module][HomelabCameraModule] which is included in my Raspberry
Pi's [host configuration][HomelabHostRpi3].

By choosing NixOS over the official Raspberry Pi OS I set myself up to an
arduous journey.   But, I learned about details of the camera stack, and now I
appreciate more the integration work done by the Raspberry Pi Foundation.

[BuildLibcamera]: https://www.raspberrypi.com/documentation/computers/camera_software.html#build-libcamera-and-rpicam-apps
[CameraNotDetected]: https://forums.raspberrypi.com/viewtopic.php?t=362707
[HomelabCameraModule]: https://github.com/wagdav/homelab/blob/master/modules/camera-rpi-v1/default.nix
[HomelabDeviceTreeOverlay]: https://github.com/wagdav/homelab/blob/master/modules/camera-rpi-v1/default.nix#L34
[HomelabHostRpi3]: https://github.com/wagdav/homelab/blob/master/host-rp3.nix
[Homelab]: https://github.com/wagdav/homelab
[HomelabRpicamApps]: https://github.com/wagdav/homelab/blob/master/modules/camera-rpi-v1/rpicam-apps.nix
[HomelabLibcamera]: https://github.com/wagdav/homelab/blob/master/modules/camera-rpi-v1/overlays/libcamera.nix
[libcameraAnnouncement]: https://www.raspberrypi.com/news/an-open-source-camera-stack-for-raspberry-pi-using-libcamera/
[NixOSHardwareRPi3]: https://github.com/NixOS/nixos-hardware/blob/a59f00f5ac65b19382617ba00f360f8bc07ed3ac/raspberry-pi/3/default.nix#L7
[NixpkgsLibcamera]: https://github.com/NixOS/nixpkgs/blob/4b616a8ecce7aaceea5360f9724065c182dc016f/pkgs/by-name/li/libcamera/package.nix
[NixpkgsLibcameraPR]: https://github.com/NixOS/nixpkgs/pull/281803
[NixWikiCamera]: https://wiki.nixos.org/wiki/NixOS_on_ARM/Raspberry_Pi#Camera
[RPi-Camera-Configuration]: https://www.raspberrypi.com/documentation/computers/camera_software.html#configuration
[ov5467-overlay.dts]: https://github.com/raspberrypi/linux/blob/rpi-6.1.y/arch/arm/boot/dts/overlays/ov5647-overlay.dts
[v1Release]: https://www.raspberrypi.com/news/camera-board-available-for-sale/
