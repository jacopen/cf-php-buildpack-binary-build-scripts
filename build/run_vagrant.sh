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

function is_do() {
    VM=$1
    RES=$("$VM/vm_ctl" status | grep digital_ocean)
    if [ "$RES" == "" ]; then
        return 0;
    else
        return 1;
    fi
}

function scp_helper() {
    VM=$1
    SSHCFG=$("$VM"/vm_ctl ssh-config)
    HOST=$(echo "$SSHCFG" | grep HostName | sed -e 's/^[ \t]*//' | cut -d ' ' -f 2)
    USER=$(echo "$SSHCFG" | grep "User " | sed -e 's/^[ \t]*//' | cut -d ' ' -f 2)
    PORT=$(echo "$SSHCFG" | grep Port | sed -e 's/^[ \t]*//' | cut -d ' ' -f 2)
    KEY=$(echo "$SSHCFG" | grep IdentityFile | sed -e 's/^[ \t]*//' | cut -d ' ' -f 2)
    OS=$(./vagrant/lucid/vm_ctl ssh -c "cat /etc/issue" | sed -n 1p | cut -d ' ' -f 1)
    VERSION=$(./vagrant/lucid/vm_ctl ssh -c "cat /etc/issue" | sed -n 1p | cut -d ' ' -f 2 | cut -d '.' -f 1,2)
    mkdir -p "./output/$OS-$VERSION"
    echo "Downloading build files to [./output/$OS-$VERSION]..."
    scp -r -i "$KEY" -P "$PORT" "$USER"@"$HOST":./cf-php-buildpack-binary-build-scripts/output/* "./output/$OS-$VERSION"
}

function run_build_local() {
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

function run_build_do() {
    VM=$1
    PKG=$2
    echo "Running build for [$(basename $VM)]"
    "$VM/vm_ctl" up
    if [ "$PKG" == "" ]; then
        "$VM/vm_ctl" ssh -c 'cd $HOME; bash <( curl -s https://raw.githubusercontent.com/dmikusa-pivotal/cf-php-buildpack-binary-build-scripts/master/build/run_local.sh )'
    else
        "$VM/vm_ctl" ssh -c "cd \$HOME; bash <( curl -s https://raw.githubusercontent.com/dmikusa-pivotal/cf-php-buildpack-binary-build-scripts/master/build/run_local.sh ) $PKG"
    fi
    scp_helper "$VM"
    "$VM/vm_ctl" halt
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
        is_do "$VM" && CHK="0" || CHK="1"
        if [ "$CHK" == 1 ]; then
            run_build_do "$VM" "$2"
        else
            run_build_local "$VM" "$2"
        fi
    done
else
    VM="$ROOT/vagrant/$1"
    is_do "$VM" && CHK="0" || CHK="1"
    if [ "$CHK" == 1 ]; then
        run_build_do "$VM" "$2"
    else
        run_build_local "$VM" "$2"
    fi
fi
