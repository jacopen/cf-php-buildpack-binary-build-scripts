#!/bin/bash
#
##################################################################
#
# Script to build PHP 5.4 for use with CloudFoundry
#
#   Author:  Daniel Mikusa
#     Date:  11-17-2013
#
##################################################################
#  Configuration
#
PHP_VERSION=5.4.28
VERSION_POSTFIX=
ZTS_VERSION=20100525
# Third Party Module Versions
RABBITMQ_C_VERSION="0.5.0"
LIBMEMCACHED_VERSION="1.0.18"
declare -A MODULES
MODULES[APC]="3.1.9"
MODULES[mongo]="1.5.1"
MODULES[redis]="2.2.5"
MODULES[xdebug]="2.2.5"
MODULES[amqp]="1.4.0"
MODULES[memcache]="2.2.7"
MODULES[igbinary]="1.1.1"
MODULES[msgpack]="0.5.5"
MODULES[memcached]="2.2.0"
# location where files are built
INSTALL_DIR="/tmp/staged/app"
BUILD_DIR=`pwd`/build
REPO_DIR=$(dirname $BUILD_DIR)
##################################################################
set -e

function build_php54() {
	cd "$BUILD_DIR"
	if [ "n$PHP_VERSION" == "n" ]; then
		echo "No PHP Version Specified!!"
		exit -1
	fi
	if [ ! -d "php-$PHP_VERSION" ]; then
		curl -L -o "php-$PHP_VERSION.tar.bz2" "http://us1.php.net/get/php-$PHP_VERSION.tar.bz2/from/us2.php.net/mirror"
		tar jxf "php-$PHP_VERSION.tar.bz2"
		rm "php-$PHP_VERSION.tar.bz2"
	fi
	cd "php-$PHP_VERSION"
	./configure \
		--prefix="$INSTALL_DIR/php" \
		--with-config-file-path=/home/vcap/app/php/etc \
		--disable-static \
		--enable-shared \
		--enable-ftp \
		--enable-sockets \
		--enable-soap \
		--enable-fileinfo \
		--enable-bcmath \
		--enable-calendar \
		--with-kerberos \
		--enable-zip \
		--with-bz2=shared \
		--with-curl=shared \
		--enable-dba=shared \
		--with-cdb \
		--with-gdbm \
		--with-mcrypt=shared \
		--with-mhash=shared \
		--with-mysql=mysqlnd \
		--with-mysqli=mysqlnd \
		--with-pdo-mysql=mysqlnd \
		--with-gd=shared \
		--with-pdo-pgsql=shared \
		--with-pgsql=shared \
		--with-pspell=shared \
		--with-gettext=shared \
		--with-gmp=shared \
		--with-imap=shared \
		--with-imap-ssl=shared \
		--with-ldap=shared \
		--with-ldap-sasl \
		--with-zlib=shared \
		--with-snmp=shared \
		--enable-mbstring \
		--enable-mbregex \
		--enable-exif \
		--with-openssl=shared \
		--enable-fpm
	# Fix path on phar.phar
	sed 's|PHP_PHARCMD_BANG = `.*`|PHP_PHARCMD_BANG = /home/vcap/app/php/bin/php|' Makefile > Makefile.phar-fix
	mv Makefile.phar-fix Makefile
	# Build
	make -j 5
	make install
	cd "$BUILD_DIR"
}

package_php_extensions() {
	cd "$INSTALL_DIR"
	package_php_extension "bz2"
	package_php_extension "curl"
	package_php_extension "dba"
	package_php_extension "gd"
	package_php_extension "gettext"
	package_php_extension "gmp"
	package_php_extension "ldap"
	package_php_extension "openssl"
	package_php_extension "pdo_pgsql"
	package_php_extension "pgsql"
	package_php_extension "imap" "libc-client.so.2007e"
	package_php_extension "mcrypt" "libmcrypt.so.4"
	package_php_extension "pspell" "libaspell.so.15" "libpspell.so.15"
	package_php_extension "zlib"
	package_php_extension "snmp" "libnetsnmp.so.15"
	# package third party extensions
	package_php_extension "apc"
	package_php_extension "mongo"
	package_php_extension "redis"
	package_php_extension "xdebug"
	package_php_extension "amqp" "$INSTALL_DIR/librmq-$RABBITMQ_C_VERSION/lib/librabbitmq.so.1"
	package_php_extension "memcache"
	package_php_extension "msgpack"
	package_php_extension "igbinary"
	package_php_extension "memcached" \
		"$INSTALL_DIR/libmemcached-$LIBMEMCACHED_VERSION/lib/libmemcached.so.11" \
		"$INSTALL_DIR/libmemcached-$LIBMEMCACHED_VERSION/lib/libmemcachedutil.so.2"
	# remove packaged files
	rm php/lib/lib*
	rm php/lib/php/extensions/no-debug-non-zts-$ZTS_VERSION/*
	cd "$INSTALL_DIR"
}

# clean up previous work
rm -rf "$INSTALL_DIR"

# setup build directory
if [ ! -d "$BUILD_DIR" ]; then
	mkdir "$BUILD_DIR"
fi

# include common functionality
source "$REPO_DIR/php-common/build.sh"

# build and install php
build_php54
build_external_extensions

# Remove unused files
rm "$INSTALL_DIR/php/etc/php-fpm.conf.default"
rm -rf "$INSTALL_DIR/php/include"
rm -rf "$INSTALL_DIR/php/php/man"
rm -rf "$INSTALL_DIR/php/lib/php/build"

# Build binaries - one for PHP, one for FPM and one for each module
package_php_extensions
package_php_fpm
package_php_cgi
package_php_cli
package_php_pear
package_php

# Move packages to this directory
cd "$BUILD_DIR/../"
mkdir -p "php-$PHP_VERSION"
mv /tmp/staged/app/php-*.gz "php-$PHP_VERSION"
mv /tmp/staged/app/php-*.gz.sha1 "php-$PHP_VERSION"

# Rename with correct postfix
rename_with_postfix

echo "Done!"

