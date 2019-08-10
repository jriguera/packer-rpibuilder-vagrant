#!/bin/bash -eux

RPI_USER="${RPI_USER:-pi}"
RPI_PASS="${RPI_PASS:-pi}"
RPI_NAME="${RPI_NAME:-rpibuilder}"
RPI_HOME="${RPI_HOME:-/home/${RPI_USER}}"

INSTALL_LIST=$(cat <<-EOF | grep -v '#' | xargs
	# List of packages to install
        apt-cacher-ng
	# RPI builder dependencies: https://github.com/RPi-Distro/pi-gen
	git autoconf autotools-dev libtool debootstrap quilt build-essential fakeroot pkg-config
	xxd zerofree dosfstools libcap2-bin binfmt-support qemu-user-static
	# https://mender.io/
	# https://github.com/mendersoftware/mender-convert
	golang
	kpartx bison flex mtools mtd-utils e2fsprogs u-boot-tools device-tree-compiler
EOF
)

echo "* Installing packages ..."
for package in ${INSTALL_LIST}; do
	apt-get install -y ${package}
done
echo "mtools_skip_check=1" >> /etc/mtools.conf

echo "# Load loop module" > /etc/modules-load.d/loop.conf
echo "loop" >> /etc/modules-load.d/loop.conf

# RPI user
echo "* Creating RPI user ..."
adduser --firstuid 1000 --gecos "${RPI_NAME}" --disabled-password ${RPI_USER}
passwd -d ${RPI_USER}
echo "${RPI_USER}:${RPI_PASS}" | chpasswd
