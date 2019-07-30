#!/bin/bash -eux

SSH_USER="${SSH_USER:-vagrant}"
SSH_USER_HOME="${SSH_USER_HOME:-/home/${SSH_USER}}"

if [ "${PACKER_BUILDER_TYPE}" = 'virtualbox-iso' ]
then
	vbox_version="$(cat ${SSH_USER_HOME}/.vbox_version)"
	echo "* Installing VirtualBox Guest Tools for ${PACKER_BUILDER_TYPE} version ${vbox_version}"

	apt-get install -y linux-headers-$(uname -r) build-essential perl dkms
	mount -o loop "${SSH_USER_HOME}/VBoxGuestAdditions_${vbox_version}.iso" /mnt
	if sh /mnt/VBoxLinuxAdditions.run --nox11
	then
		echo "* VirtualBox Guest Additions installation failed!" >&2
		exit 1
	fi
	umount /mnt
	rm -rf "${SSH_USER_HOME}/VBoxGuestAdditions_${vbox_version}.iso"
fi

