#!/bin/bash
#
##################################################################
#
# Script to package HHVM 3.2 for Ubuntu Lucid
#
#   Author:  Daniel Mikusa
#     Date:  12-13-2014
#
##################################################################
#  Configuration
#
HHVM_VERSION=3.2.0
BUILD_DIR=`pwd`/build
##################################################################
set -e

function download() {
	URL=$1
	NAME=$2
	FILE=$(basename "$URL")
	mkdir -p "$BUILD_DIR/files_$NAME"
	if [ ! -f "$BUILD_DIR/files_$NAME/$FILE" ]; then
		echo -n "    Downloading [$NAME]..."
		curl -s -L -O "$URL"
		mv "$FILE" "$BUILD_DIR/files_$NAME"
		echo " done"
	fi
	echo -n "    Extracting [$NAME]..."
	cd "$BUILD_DIR/files_$NAME"
	ar xf "$FILE"
	tar zxf "data.tar.gz"
	rm -f data.tar.gz control.tar.gz debian-binary _gpgbuilder
	cd ../../
	echo " done"
}

echo "Packaging up HHVM"

# get stuff
download "http://dl.hhvm.com/ubuntu/pool/main/h/hhvm/hhvm_$HHVM_VERSION~lucid_amd64.deb" "hhvm"
download "http://ppa.launchpad.net/ubuntu-toolchain-r/test/ubuntu/pool/main/b/binutils/binutils_2.22-4ubuntu1~10.04.1_amd64.deb" "binutils"
download "http://ppa.launchpad.net/ubuntu-toolchain-r/test/ubuntu/pool/main/g/gcc-4.8/libstdc++6_4.8.1-2ubuntu1~10.04.1_amd64.deb" "glibc"
download "http://mirrors.kernel.org/ubuntu/pool/universe/t/tbb/libtbb2_2.2+r009-1_amd64.deb" "libtbb2"
download "http://mirrors.kernel.org/ubuntu/pool/universe/libo/libonig/libonig2_5.9.1-1_amd64.deb" "libonig"
download "http://mirrors.kernel.org/ubuntu/pool/universe/libm/libmcrypt/libmcrypt4_2.5.8-3.1_amd64.deb" "libmcrypt"
download "http://mirrors.kernel.org/ubuntu/pool/main/e/elfutils/libelf1_0.143-1_amd64.deb" "libelf"

# package up external files
echo -n "    Packaging additional libraries..."
rm -rf "$BUILD_DIR/files_hhvm/etc" "$BUILD_DIR/files_hhvm/var" "$BUILD_DIR/files_hhvm/usr/share"
rm "$BUILD_DIR/files_hhvm/usr/bin/hh_server" \
   "$BUILD_DIR/files_hhvm/usr/bin/hh_client" \
   "$BUILD_DIR/files_hhvm/usr/bin/hack_remove_soft_types" \
   "$BUILD_DIR/files_hhvm/usr/bin/hackificator"
cp "$BUILD_DIR/files_binutils/usr/lib/libbfd-2.22-system.so" "$BUILD_DIR/files_hhvm/usr/lib/hhvm/"
cp "$BUILD_DIR/files_glibc/usr/lib/libstdc++.so.6" "$BUILD_DIR/files_hhvm/usr/lib/hhvm/"
cp "$BUILD_DIR/files_libelf/usr/lib/libelf-0.143.so" "$BUILD_DIR/files_hhvm/usr/lib/hhvm/libelf.so.1"
cp "$BUILD_DIR/files_libonig/usr/lib/libonig.so.2.0.0" "$BUILD_DIR/files_hhvm/usr/lib/hhvm/libonig.so.2"
cp "$BUILD_DIR/files_libtbb2/usr/lib/libtbb.so.2" "$BUILD_DIR/files_hhvm/usr/lib/hhvm/"
cp "$BUILD_DIR/files_libmcrypt/usr/lib/libmcrypt.so.4.4.8" "$BUILD_DIR/files_hhvm/usr/lib/hhvm/libmcrypt.so.4"

# package up files in the build environment
cp "/usr/lib/libc-client.so.2007e" "$BUILD_DIR/files_hhvm/usr/lib/hhvm/"
echo " done"

# Move directory & zip it up
echo -n "    Creating archive..."
cd "$BUILD_DIR"
mv "files_hhvm" "hhvm"
mkdir -p "files_hhvm"
mv "hhvm/hhvm_3.2.0~lucid_amd64.deb" "files_hhvm/"
tar czf "hhvm-$HHVM_VERSION.tar.gz" "hhvm/"
rm -rf "hhvm/"
cd ../
echo ' done'
echo 'HHVM Build complete.'
