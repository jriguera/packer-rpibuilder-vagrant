#!/bin/bash -eux

echo "* Setup grub configuration"
if [ -f /etc/default/grub ]; then
	sed -i -E -e 's/GRUB_TIMEOUT=.+/GRUB_TIMEOUT=0/' /etc/default/grub
fi

echo "* Installing grub ..."
update-grub
