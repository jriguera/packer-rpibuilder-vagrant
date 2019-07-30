#!/bin/bash -eux

echo "* Blacklist floppy kernel module ..."
echo 'blacklist floppy' > /etc/modprobe.d/floppy.conf
mkinitramfs -o /boot/initrd.img-$(uname -r) $(uname -r)

