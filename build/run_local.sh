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
else
    cd cf-php-buildpack-binary-build-scripts
    git pull
fi

# update / install dependencies
./build/install-deps.sh

# build all
./build/build-all.sh
