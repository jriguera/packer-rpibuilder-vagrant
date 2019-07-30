#!/bin/bash -eux

INSTALL_LIST=$(cat <<-EOF | grep -v '#' | xargs
	# List of packages to install
	acpid coreutils kmod
	htop iotop tcpdump ethtool lsscsi lshw iftop nload pciutils strace parted lsof
	curl wget bsdtar rsync zip unzip vim-nox nano xz-utils
EOF
)

UNINSTALL_LIST=$(cat <<-EOF | grep -v '#' | xargs
	# List of packages to uninstall
	pppoeconf pppconfig ppp
	wireless-tools wpasupplicant
EOF
)

echo "* Installing packages ..."
for package in ${INSTALL_LIST}; do
	apt-get install -y ${package}
done

echo "* Uninstalling packages ..."
for package in ${UNINSTALL_LIST}; do
	apt-get remove -y --purge ${package}
done

# Disable the release upgrader
if [ -e /etc/update-manager/release-upgrades ]; then
	echo "* Disabling the release upgrader"
	sed -i 's/^Prompt=.*$/Prompt=never/' /etc/update-manager/release-upgrades
fi

# Tweak sshd to prevent DNS resolution (speed up logins)
echo "* Turning off DNS lookups for SSH Server"
sed -i -e 's/^#UseDNS no/UseDNS no/' /etc/ssh/sshd_config

echo "* Installed packages:"
dpkg -l

