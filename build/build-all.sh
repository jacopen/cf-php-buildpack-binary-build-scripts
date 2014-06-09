#!/bin/bash
#
# Script that will recursively build all of the dependencies for the build pack.
#
# Date: 6-9-2014
# Author: Daniel Mikusa <dmikusa@gopivotal.com
#
set -e

# Get ROOT Directory
ROOT=$(dirname $(dirname $(readlink -e $0)))
echo $ROOT

# Build Apache HTTPD 2.4
cd "$ROOT/apache-httpd-2.4"
./build.sh

# Build PHP 5.4 & 5.5
cd "$ROOT/php-5.4"
./build.sh
cd "$ROOT/php-5.5"
./build.sh

# Build Nginx 1.5, 1.6 & 1.7
cd "$ROOT/nginx-1.5"
./build.sh
cd "$ROOT/nginx-1.6"
./build.sh
cd "$ROOT/nginx-1.7"
./build.sh

echo "All files build, check the [$ROOT/output] directory for the binaries."
