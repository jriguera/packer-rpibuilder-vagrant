# packer-rpibuilder-vagrant

Packer builder for RPI Vagrant Builder box for Virtualbox.

The purpose is create a Vagrant Virtualbox template with all dependencies installed ready to create Raspbian images with https://github.com/RPi-Distro/pi-gen
Because of qemu issues identified in https://github.com/RPi-Distro/pi-gen/issues/271 , this vm is based 32bits Debian Buster (i686)

It also installs `apt-cacher-ng` in order to make it possible to cache downloaded deb packages via `0.0.0.0:3142`

# Run

`./build.sh`

When the vm is built, it will be exported as Vagrant box to `builds` folder, 
you can already test it direclty with `vagrant up` (have a look at the `vagrantfile`).

The build script can also upload the vm to VagrantCloud if `upload` argument is provided
and a proper enviornment variable is defined.


# Usage

Clone https://github.com/RPi-Distro/pi-gen
```
git clone https://github.com/RPi-Distro/pi-gen.git
```

and inside the repository create a file called `Vagrantfile` (there is also a
`Vagrantfile.template` in this project as a example) with:
```
$run = <<"SCRIPT"
echo ">>> Generating rpi image ... $@"
export DEBIAN_FRONTEND=noninteractive
export RPIGEN_DIR="${1:-/home/vagrant/rpi-gen}"
export APT_PROXY='http://127.0.0.1:3142' 
# Prepare. Copy the repo to another location to run as root
rsync -a --delete --exclude 'work' --exclude 'deploy' /vagrant/  ${RPIGEN_DIR}/
cd ${RPIGEN_DIR}
# Clean previous builds. Start always from scratch (the proxy helps here!)
sudo umount --recursive work/*/stage*/rootfs/{dev,proc,sys} || true
# Delete old builds
sudo rm -rf work/*
# Build it again
sudo --preserve-env=APT_PROXY ./build.sh
# Copy images back to host
[ -d deploy ] && cp -vR deploy /vagrant/
SCRIPT

Vagrant.configure("2") do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.  

  config.vm.define :rpigen do |rpigen|
      # Every Vagrant virtual environment requires a box to build off of.
      rpigen.vm.box = "jriguera/rpibuilder-buster-10.4-i386"
      rpigen.vm.provision "shell" do |s|
        s.inline = $run
        s.args = "#{ENV['WORK_DIR']}"
      end
  end
end
```

and run `vagrant up`. It will start downloading the Virtualbox base image 
(based on Debian Buster i386) and after done, it will run the `build.sh` script
of the repo. Once finished, it will move the images in the `deploy` folder.
If the process fails, you can run again with `vagrant provision`. `vagrant destroy`
will delete the vm and its contents.

For more usage options, have a look to https://github.com/jriguera/raspbian-cloud 

**Please make sure you are targeting the correct rpibuilder version https://app.vagrantup.com/boxes/search?utf8=%E2%9C%93&sort=downloads&provider=&q=rpibuilder**


# Author

Jose Riguera, jriguera@gmail.com

MIT License


