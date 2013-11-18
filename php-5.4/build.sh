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
PHP_VERSION=5.4.22
ZTS_VERSION=20100525
# location where files are built
INSTALL_DIR="/tmp/staged/app"
BUILD_DIR=`pwd`/build
##################################################################
set -e

function build_php54() {
	cd "$BUILD_DIR"
	if [ "n$PHP_VERSION" == "n" ]; then
		PHP_VERSION=5.4.22
	fi
	if [ ! -d "php-$PHP_VERSION" ]; then
		curl -L -o "php-$PHP_VERSION.tar.bz2" "http://us1.php.net/get/php-$PHP_VERSION.tar.bz2/from/us2.php.net/mirror"
		tar jxf "php-$PHP_VERSION.tar.bz2"
		rm "php-$PHP_VERSION.tar.bz2"
	fi
	cd "php-$PHP_VERSION"
	# Investigate these options: --enable-pear, --with-inifile, --with-flatfile, --with-exif
	./configure \
		--prefix="$INSTALL_DIR/php" \
		--with-config-file-path=/home/vcap/app/php/etc \
		--disable-cli \
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
		--without-pear \
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
		--enable-mbstring \
		--enable-mbregex \
		--enable-exif \
		--with-openssl=shared \
		--enable-fpm
	make
	make install
	cd "$BUILD_DIR"
}

package_php_extension() {
	cd "$INSTALL_DIR"
	NAME=$1
	tar cf "php-$NAME-$PHP_VERSION.tar" "php/lib/php/extensions/no-debug-non-zts-$ZTS_VERSION/$NAME.so"
	if [ $# -gt 1 ]; then
		for FILE in "${@:2}"; do
			cp "/usr/lib/$FILE" php/lib/
			tar rf "php-$NAME-$PHP_VERSION.tar" "php/lib/$FILE"
		done
	fi
	gzip -9 "php-$NAME-$PHP_VERSION.tar"
	shasum "php-$NAME-$PHP_VERSION.tar.gz" > "php-$NAME-$PHP_VERSION.tar.gz.sha1"
	cd "$INSTALL_DIR"
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
	# remove packaged files
	rm php/lib/lib*
	rm php/lib/php/extensions/no-debug-non-zts-$ZTS_VERSION/*
	cd "$INSTALL_DIR"
}

package_php_fpm() {
	cd "$INSTALL_DIR"
	tar czf "php-fpm-$PHP_VERSION.tar.gz" php/sbin php/php/fpm
	shasum "php-fpm-$PHP_VERSION.tar.gz" > "php-fpm-$PHP_VERSION.tar.gz.sha1"
	rm php/sbin/*
	rm -rf php/php/fpm
	cd "$INSTALL_DIR"
}

package_php() {
	cd "$INSTALL_DIR"
	tar czf "php-$PHP_VERSION.tar.gz" "php"
	shasum "php-$PHP_VERSION.tar.gz" > "php-$PHP_VERSION.tar.gz.sha1"
	cd "$INSTALL_DIR"
}

# clean up previous work
rm -rf "$INSTALL_DIR"

# setup build directory
if [ ! -d "$BUILD_DIR" ]; then
	mkdir "$BUILD_DIR"
fi

# build and install php
build_php54

# Remove unused files
rm "$INSTALL_DIR/php/etc/php-fpm.conf.default"
rm -rf "$INSTALL_DIR/php/include"
rm -rf "$INSTALL_DIR/php/php/man"
rm -rf "$INSTALL_DIR/php/lib/php/build"

# Build binaries - one for PHP, one for FPM and one for each module
package_php_extensions
package_php_fpm
package_php

echo "Done!"

