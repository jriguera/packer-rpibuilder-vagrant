#!/usr/bin/env bash
# set -o pipefail  # exit if pipe command fails
RE_VERSION_NUMBER='^[0-9]+([0-9\.]*[0-9]+)*$'

[ -z "$DEBUG" ] || set -x
set -e

if ! [ -x "$(command -v packer)" ]
then
  echo '> Error! Please install packer: https://www.packer.io/!'
  exit 1
fi

if [ -z "${VAGRANT_CLOUD_TOKEN}" ]
then
  echo '> Error! Please define VAGRANT_CLOUD_TOKEN'
  exit 1
fi

version=1
case $# in
    0)
        ;;
    1)
        if [ $1 == "-h" ] || [ $1 == "--help" ]
        then
            echo "Usage:  $0 [version-number]"
            echo "  Creates a new vagrant box and push to vagrantcloud"
            exit 0
        else
            version=$1
            if ! [[ $version =~ $RE_VERSION_NUMBER ]]
            then
                echo "ERROR: Incorrect version number!"
                exit 1
            fi
        fi
        ;;
    *)
        echo "ERROR: incorrect argument. See '$0 --help'"
        exit 1
        ;;
esac

echo "> Creating vagrant box version 1 ..."
packer build -var "vm_version=$version" debian-10-i386.json

