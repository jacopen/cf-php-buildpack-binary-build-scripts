#!/bin/sh
#
# Connect to a remote machine, build there and download output.
#
#  - remote environment needs to be setup and listening for SSH
#  - remote environment needs git installed
#  - process will install dependencies on the remote environment
#
# Date: 6-9-2014
# Author: Daniel Mikusa <dmikusa@gopivotal.com>
#
# Usage:
#   ./run_remote.sh [user@]hostname
#
set -e

REMOTE_HOST=$1
if [ "$REMOTE_HOST" == "" ]; then
    echo "Usage:"
    echo "  run_remote.sh <host/ip>"
    exit -1
fi

# Get ROOT Directory
ROOT=$(dirname $(dirname $(readlink -e $0)))

# Install git
# TODO: make this work for other OS like CentOS
ssh -t "$REMOTE_HOST" "sudo apt-get -y install git-core"

# Clone or update the repo
if ssh -q "$REMOTE_HOST" [[ -d cf-php-buildpack-binary-build-scripts ]]; then 
    ssh "$REMOTE_HOST" "cd cf-php-buildpack-binary-build-scripts; git pull"
else
    ssh "$REMOTE_HOST" "git clone https://github.com/dmikusa-pivotal/cf-php-buildpack-binary-build-scripts.git"
fi

# Update / install dependencies
ssh -t "$REMOTE_HOST" "cd cf-php-buildpack-binary-build-scripts; ./build/install-deps.sh"

# Run the build-all.sh script
ssh "$REMOTE_HOST" "cd cf-php-buildpack-binary-build-scripts; ./build/build-all.sh"

# Copy the binaries to the 
scp -r "$REMOTE_HOST:./cf-php-buildpack-binary-build-scripts/output/*" "$ROOT/output/"
