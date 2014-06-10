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
# TODO: make this work for other OS like CentOS
sudo apt-get -y install git-core

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
