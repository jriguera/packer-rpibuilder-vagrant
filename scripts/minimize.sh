#!/bin/bash -eux

echo "* Disk usage before minimization"
df -h

echo "* Cleanup apt cache"
apt-get -y autoremove --purge
apt-get -y autoclean
apt-get -y clean
dpkg --get-selections | grep -v deinstall

echo "* Clean up orphaned packages with deborphan"
apt-get -y install deborphan --no-install-recommends
while [ -n "$(deborphan --guess-all --libdevel)" ]; do
    deborphan --guess-all --libdevel | xargs apt-get -y purge
done

echo "* Remove package manager cache"
find /var/cache/apt/archives/ -type f -exec rm -f {} \;

echo "* Removing APT files"
find /var/lib/apt -type f | xargs rm -f

echo "* Removing caches"
find /var/cache -type f -exec rm -rf {} \;

# Whiteout root
echo "* Clear out root fs"
count=$(( $(df --sync -kP / | awk '/^\/dev/{ print $4 }') - 1 ))
dd if=/dev/zero of=/whitespace bs=1024 count=${count} || true
rm -fv /whitespace

echo "* Clear out swap and disable until reboot"
swapuuid=$(/sbin/blkid -o value -l -s UUID -t TYPE=swap)
count=$(( $(free -k | awk '/Swap:/{ print $2 }') -1 ))
if [ -n "${swapuuid}" ]; then
	# Whiteout the swap partition to reduce box size
	# Swap is disabled till reboot
	swappart=$(readlink -f /dev/disk/by-uuid/$swapuuid)
	swapoff "${swappart}"
	dd if=/dev/zero of="${swappart}" bs=1024 count=${count} || true
	mkswap -U "${swapuuid}" "${swappart}"
fi

echo "* Disk usage after minimization"
df -h

# Make sure we wait until all the data is written to disk, otherwise
# Packer might quite too early before the large files are deleted
sync

