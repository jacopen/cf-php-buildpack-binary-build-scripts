#!/bin/bash
#
# Bootstrap a local machine
#   - install git
#   - clone repo
#   - update repos
#   - install depencencies
#
# Date: 6-9-2014
# Author: Daniel Mikusa <dmikusa@gopivotal.com>
#
set -e

# Detect OS & Version
OS=$(cat /etc/issue | cut -d ' ' -f 1)
VERSION=$(cat /etc/issue | cut -d ' ' -f 2 | cut -d '.' -f 1,2)

# Install git
if ! hash git 2>/dev/null; then
    echo "Git not installed on the local host.  Attempting to install..."
    if [ "$OS" == "Ubuntu" ]; then
        if [ "$VERSION" == "10.04" ]; then
            # Make sure we have a modern version of Git, as the version installed on Lucid
            # fails to establish an SSL connection with GitHub.
            # https://launchpad.net/~git-core/+archive/ubuntu/ppa
            sudo apt-get update
            sudo apt-get -y install python-software-properties
            sudo add-apt-repository ppa:git-core/ppa
            sudo apt-key adv --recv-keys --keyserver keyserver.ubuntu.com A1715D88E1DF1F24
            sudo apt-get update
            # for some reason ca-certificates gets bungled
            # on VirtualBox after running the above. A simple reinstall fixes it.
            sudo apt-get -y install --reinstall ca-certificates
        fi
        sudo apt-get update
        sudo apt-get -y install git-core
    elif [ "$CAPTURE" == "CentOS" ]; then 
        sudo yum install git
    else
        echo "Not sure about the remote OS, please manually install git."
        exit -1
    fi
fi

# clone repo
if [ ! -d cf-php-buildpack-binary-build-scripts ]; then 
    git clone https://github.com/dmikusa-pivotal/cf-php-buildpack-binary-build-scripts.git
    cd cf-php-buildpack-binary-build-scripts
else
    cd cf-php-buildpack-binary-build-scripts
    git pull
fi

# check out right branch
VERSION=`echo $VERSION | cut -d '.' -f 1,2`
git checkout "$OS-$VERSION"

# create /home/vcap/logs
#  This path is used at runtime, but is also required by some of the packages 
#  to exist at compile time.
#  It's not actually used, other than to satisfy that requirement.
sudo mkdir -p /home/vcap/logs

# update / install dependencies
./build/install-deps.sh

# Clear output directory, gives us a fresh set of files
if [ -d output ]; then
    rm -rf output/*
fi

# Build the component requested or all of them
if [ "$1" == "" ]; then
    echo "Building all components."
    ./build/build-all.sh
else
    if [ -f ./$1/build.sh ]; then
        echo "Building component [$1]."
        cd ./$1
        ./build.sh
        cd ../
    else
        echo "Could not find component specified [$1]. Skipping."
    fi
fi

# If using vagrant, move output to shared directory
if [ -d /vagrant ]; then
    mkdir -p "/vagrant/output/$OS-$VERSION"
    cp -R output/* "/vagrant/output/$OS-$VERSION/"
fi
