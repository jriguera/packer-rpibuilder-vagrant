#!/bin/bash -eux

echo "* Remove fd from fstab"
sed -i '/^\/dev\/fd0/d' /etc/fstab

echo "* Remove the CDROM as a media source."
sed -i -e "/cdrom:/d" /etc/apt/sources.list

echo "* Cleaning gem cache"
rm -rf /var/lib/gems/*/cache/*

echo "* Remove the utmp file"
rm -f /var/run/utmp

echo "* Remove udev rules"
# http://6.ptmc.org/?p=164
rm -rf /dev/.udev/
rm -f /etc/udev/rules.d/70-persistent-net.rules
# Better fix that persists package updates: http://serverfault.com/a/485689
touch /etc/udev/rules.d/75-persistent-net-generator.rules

echo "* Remove temporary files"
rm -rf /tmp/*
rm -rf /var/tmp/*

echo "* Regenerate ssh server keys"
rm -rf /etc/ssh/*_host_*
dpkg-reconfigure openssh-server

echo "* Remove the PAM data"
rm -rf /var/run/console/*
rm -rf /var/run/faillock/*
rm -rf /var/run/sepermit/*

echo "* Remove the process accounting log files"
if [ -d /var/log/account ]; then
    rm -f /var/log/account/pacct*
    touch /var/log/account/pacct
fi

echo "* Remove email from the local mail spool directory"
rm -rf /var/spool/mail/*
rm -rf /var/mail/*

echo "* Remove the local machine ID"
# cleanup systemd machine-id. see https://salsa.debian.org/cloud-team/vagrant-boxes/blob/master/helpers/vagrant-setup#L103
if [ -d /etc/machine-id ]; then
    rm -f /etc/machine-id
    touch /etc/machine-id
fi
if [ -d /var/lib/dbus/machine-id ]; then
    rm -f /var/lib/dbus/machine-id
    touch /var/lib/dbus/machine-id
fi

echo "* Clearing last login information"
>/var/log/lastlog
>/var/log/wtmp
>/var/log/btmp

echo "* Empty log files"
find /var/log -type f | while read f; do echo -ne '' > "$f"; done;

echo "* Cleaning up leftover dhcp leases"

# Ubuntu 10.04
if [ -d "/var/lib/dhcp3" ]; then
    rm /var/lib/dhcp3/*
fi
# Ubuntu 12.04 & 14.04
if [ -d "/var/lib/dhcp" ]; then
    rm /var/lib/dhcp/*
fi

echo "* Remove blkid tab"
rm -f /dev/.blkid.tab
rm -f /dev/.blkid.tab.old

echo "* Remove Bash history"
unset HISTFILE
rm -f /root/.bash_history
rm -f /home/*/.bash_history

echo "* Flag the system for reconfiguration"
touch /.unconfigured

