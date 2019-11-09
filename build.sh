#!/usr/bin/env bash
# set -o pipefail  # exit if pipe command fails

PACKER_DEFINITION="debian-10-i386.json"
PACKER_VAGRANTCLOUD_POST="vagrantcloud.json"
OS_VERSION="10.1"

RE_VERSION_NUMBER='^[0-9]+([0-9\.]*[0-9]+)*$'
[ -z "$DEBUG" ] || set -x
set -e


if ! [ -x "$(command -v jq)" ]
then
  echo 'ERROR: Please install jq: https://github.com/stedolan/jq!'
  exit 1
fi

if ! [ -x "$(command -v packer)" ]
then
  echo 'ERROR: Please install packer: https://www.packer.io/!'
  exit 1
fi

packerjson=$(echo "packerbuild-$$.json")
trap "{ rm -f ${packerjson}; }" EXIT

case $# in
    0)
        cat "${PACKER_DEFINITION}" > "${packerjson}"
        ;;
    1)
        if [ $1 == "-h" ] || [ $1 == "--help" ] || [ $1 == "help" ]
        then
            echo "Usage:  $0 [upload]"
            echo "  Creates a new vagrant box taking a version number from 'VERSION' file."
            echo "  Optionally push the build to vagrantcloud if 'upload' arg is provided."
            exit 0
        elif [ $1 == "upload" ]
        then
            if [ -z "${VAGRANT_CLOUD_TOKEN}" ]
            then
                echo 'ERROR, Please define VAGRANT_CLOUD_TOKEN env var'
                exit 1
            fi
        else
            echo "ERROR: Incorrect argument. See '$0 --help'"
            exit 1
        fi
        # patch packer definion to add vagrant cloud post-proc
        jq --argjson vagrantcloud "$(<${PACKER_VAGRANTCLOUD_POST})" '."post-processors"[] += [$vagrantcloud]' "${PACKER_DEFINITION}" > "${packerjson}"
        ;;
    *)
        echo "ERROR: Incorrect arguments. See '$0 --help'"
        exit 1
        ;;
esac
version="$(<VERSION)"
if [ $? -ne 0 ]
then
    echo "ERROR: File VERSION not found"
    exit 1
fi
if ! [[ $version =~ $RE_VERSION_NUMBER ]]
then
    echo "ERROR: Incorrect version number!"
    exit 1
fi

if [ ! -d iso ]
then
	mkdir iso
fi
cp Vagrantfile.template Vagrantfile
sed -i "s/{{VERSION}}/$version/g" Vagrantfile
sed -i "s/{{OS_VERSION}}/$OS_VERSION/g" Vagrantfile
echo "> Creating vagrant box version $version ..."
packer build -var "vm_version=$version" "${packerjson}"
