#!/bin/bash -eux

SSH_USER="${SSH_USER:-vagrant}"
SSH_USER_HOME="${SSH_USER_HOME:-/home/${SSH_USER}}"

echo "* Installing PAM module for systemd to prevent Vagrant/SSH hangs"
if dpkg-query -W -f='${Status}' systemd 2>/dev/null | cut -f 3 -d ' ' | grep -q '^installed$'; then
	apt-get -y install libpam-systemd
fi

# Tweak sshd to prevent DNS resolution (speed up logins)
echo "* Turning off DNS lookups for SSH Server"
sed -i -e 's/^#UseDNS no/UseDNS no/' /etc/ssh/sshd_config

# Installing vagrant keys
echo "* Installing Vagrant SSH key ..."
mkdir -pm 700 "${SSH_USER_HOME}/.ssh"
wget --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -O "${SSH_USER_HOME}/.ssh/authorized_keys"
chmod 600 "${SSH_USER_HOME}/.ssh/authorized_keys"
chown -R "${SSH_USER}:${SSH_USER}" "${SSH_USER_HOME}/.ssh"

