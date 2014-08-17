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
OUTPUT_DIR="$OS-$VERSION"

# Install git and curl
if (! hash git 2>/dev/null ) || ( ! hash curl 2>/dev/null ); then
    echo "Git or curl not installed on the local host.  Attempting to install..."
    CAPTURE=$(cat /etc/issue | cut -d ' ' -f 1 | tr -d '\n')
    if [ "$CAPTURE" == "Ubuntu" ]; then
        sudo apt-get update
        sudo apt-get -y install git-core curl
    elif [ "$CAPTURE" == "CentOS" ]; then
        sudo yum install git curl
    else
        echo "Not sure about the remote OS, please manually install git and curl."
        exit -1
    fi
fi

if [ ! -d '/vagrant' ]; then

    echo "Missing /vagrant directory."
    exit 1
fi

cd '/vagrant';
if [ ! -d 'output' ]; then
    mkdir 'output'
fi
cd 'output'

# clone repo
if [ ! -d $OUTPUT_DIR ]; then

    # Git fails to verify the SSL connection when run on Lucid
    if [[ $OS == "Ubuntu" && $VERSION == "10.04.4" ]];then
        git config --global http.sslVerify false
    fi
    git clone https://github.com/dmikusa-pivotal/cf-php-buildpack-binary-build-scripts.git $OUTPUT_DIR
    cd $OUTPUT_DIR
else
    cd $OUTPUT_DIR
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
