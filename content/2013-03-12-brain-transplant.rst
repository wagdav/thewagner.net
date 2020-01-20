Brain transplant
================

:category: tech

In the lab we have a camera system composed of four cameras.  The system is
controlled by two identical PCs, two cameras connected to each.  After a
long break of operation, when we wanted to use the system again, the hard
drive in one PC decided to quit science and went dead.  We replaced the poor
fellow with a new drive and I wanted to transfer the system as it is from
the ``healty`` computer to the new drive of the ``braindead`` system .
Following the brain transplant procedure in its most realistic, bloody
purity.

My idea is to run on ``healthy``::

    dd if=/dev/hda | ssh user@braindead sudo dd of=/dev/sda

To this end I boot up ``braindead`` (with the new drive in) from a `Debian
Live CD <http://www.debian.org/CD/live/>`_.  While setting up the network
(IP address, DNS, etc.), it turns out that the network card needs some
non-free firmware which are not on the Installer/Live CD.  This is a bit
annoying but not the end of the world.  After some googling I learn that I
need `fimrware-linux-nonfree
<http://packages.debian.org/squeeze/all/firmware-linux-nonfree/download>`_,
so I download and put it on a USB stick and install (``dpkg -i``) it on
``braindead``.  Now it has network connection and an SSH server running.

To prepare for the transplant I put ``healthy`` in single user mode and
mount the file system read-only (as root)::

    $ init 1
    $ mount / -o remount,ro

Now everything is ready for the procedure.  I run ``dd`` through SSH as
described above.  It takes some time, but the transfer works fine.

On ``braindead``, still running the Live CD,  I mount the new disk and

* change the host name in ``/etc/hostname``
* generate new host keys
  (``ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key``)

I reboot ``braindead`` and voilá, it works!  Well almost... I experience
some problem with the networking.  I quickly figure it out that the network
card enumeration (eth0 eth1 swap thingy) is screwed, but it is easy to fix
by editing ``/etc/udev/rules.d/70-persistent-net.rules`` and removing the
lines that refer (by MAC address) to the network card which is in the other
machine.
