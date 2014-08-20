#!/bin/bash
#
# Runs the build using vagrant
#   - starts up a vagrant vm
#   - runs `run_local.sh` on that vm
#   - stops the vm
#
# Usage:
#   ./run_vagrant.sh all|<vm-name> [package]
#
# Script takes as an argument either `all` or the name of the vm
#  to run.  Specifying `all` runs the build for all of the vms.
#  Specifying an individual name runs the build for just that vm.
#
# Date:  8-20-2014
# Author:  Daniel Mikusa <dmikusa@pivotal.io>
#
set -e

function run_build() {
    VM=$1
    PKG=$2
    echo "Running build for [$(basename $VM)]"
    "$VM/vm_ctl" up
    if [ "$PKG" == "" ]; then
        "$VM/vm_ctl" ssh -c 'cd $HOME; /vagrant/build/run_local.sh'
    else
        "$VM/vm_ctl" ssh -c "cd \$HOME; /vagrant/build/run_local.sh $PKG"
    fi
    "$VM/vm_ctl" suspend
}

# Get ROOT Directory
if [[ "$0" == /dev/* ]]; then
    ROOT=$(pwd)
elif [[ "$0" == *bash* ]]; then
    ROOT=$(pwd)
elif [[ "$0" == /* ]]; then
    ROOT=$(dirname "$(dirname "$0")")
else
    ROOT=$(dirname $(dirname "$(pwd)/${0#./}"))
fi
echo "Local working directory [$ROOT]"

if [ "$1" == "all" ]; then
    for VM in "$ROOT/vagrant/"*; do
        run_build "$VM" "$2"
    done
else
    run_build "$ROOT/vagrant/$1" "$2"
fi
