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
VERSION=$(cat /etc/issue | cut -d ' ' -f 2)

# Install git
if ! hash git 2>/dev/null; then
    echo "Git not installed on the local host.  Attempting to install..."
    CAPTURE=$(cat /etc/issue | cut -d ' ' -f 1 | tr -d '\n')
    if [ "$CAPTURE" == "Ubuntu" ]; then
        remote_run "sudo apt-get -y install git-core"
    elif [ "$CAPTURE" == "CentOS" ]; then 
        remote_run "sudo yum install git"
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

# Build the component requested or all of them
if [ "$1" == "" ]; then
    echo "Building all components."
    ./build/build-all.sh
else
    if [ -f ./$1/build.sh ]; then
        echo "Building component [$1]."
        cd ./$1
        ./build.sh
    else
        echo "Could not find component specified [$1]. Skipping."
    fi
fi
