#!/bin/bash -eux

UPGRADE=${UPGRADE:-no}

echo "* Remove the CDROM as a media source."
sed -i -e "/cdrom:/d" /etc/apt/sources.list

echo "* Updating list of packages from repositories"
# apt-get update does not actually perform updates, it just downloads and indexes the list of packages
apt-get -y update

if [ -z "${UPGRADE##*true*}" ] || [ -z "${UPGRADE##*1*}" ] || [ -z "${UPGRADE##*yes*}" ]; then
    echo "* Performing upgrade (all packages and kernel)"
    apt-get -y dist-upgrade --allow-change-held-packages
    sync
fi

echo "* Disabling automatic updater"
# Keep the daily apt updater from deadlocking our installs.
systemctl stop apt-daily.service apt-daily.timer

# If the apt configuration directory exists, we add our own config options.
if [ -d /etc/apt/apt.conf.d/ ]; then
    echo "* Tuning APT configuration"

    # Disable daily apt unattended updates.
    echo 'APT::Periodic::Enable "0";' >> /etc/apt/apt.conf.d/10periodic

    # Enable retries, which should reduce the number box buld failures resulting from a temporal network problems.
    echo 'APT::Acquire::Retries "3";' > /etc/apt/apt.conf.d/80retries
fi

