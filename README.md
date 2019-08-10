# packer-rpibuilder-vagrant

Packer builder for RPI Vagrant Builder box for Virtualbox.

The purpose is create a Vagrant Virtualbox template with all dependencies installed ready to create Raspbian images with https://github.com/RPi-Distro/pi-gen
Because of qemu issues identified in https://github.com/RPi-Distro/pi-gen/issues/271 , this vm is based 32bits Debian Buster (i686)

# Run

`./build.sh`

When the vm is built, it will be uploaded to vagrant cloud and it will be exported as Vagrant box to `builds` folder, 
you can alreayd test it with `vagrant up` (have a look at the `vagrantfile`).

For usage have a look to https://github.com/jriguera/raspbian-cloud 


# Author

(c) Jose Riguera



 
