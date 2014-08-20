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
PHP_VERSION=5.4.31
VERSION_POSTFIX=
ZTS_VERSION=20100525
# Third Party Module Versions
RABBITMQ_C_VERSION="0.5.1"
LIBMEMCACHED_VERSION="1.0.18"
HIREDIS_VERSION="0.11.0"
declare -A MODULES
MODULES[amqp]="1.4.0"
MODULES[APC]="3.1.9"
MODULES[apcu]="4.0.6"
MODULES[igbinary]="1.1.1"
MODULES[imagick]="3.1.2"
MODULES[intl]="3.0.0"
MODULES[mailparse]="2.1.6"
MODULES[memcache]="2.2.7"
MODULES[memcached]="2.2.0"
MODULES[mongo]="1.5.4"
MODULES[msgpack]="0.5.5"
MODULES[phalcon]="1.3.2"
MODULES[phpiredis]="trunk"
MODULES[redis]="2.2.5"
MODULES[sundown]="0.3.11"
MODULES[twig]="1.16.0"
MODULES[xcache]="3.1.0"
MODULES[xdebug]="2.2.5"
MODULES[zendopcache]="7.0.3"
# location where files are built
INSTALL_DIR="/tmp/staged/app"
BUILD_DIR=`pwd`/build
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
		cd "php-$PHP_VERSION"
		./configure \
			--prefix="$INSTALL_DIR/php" \
			--with-config-file-path=/home/vcap/app/php/etc \
			--disable-static \
			--enable-shared \
			--enable-ftp=shared \
			--enable-sockets=shared \
			--enable-soap=shared \
			--enable-fileinfo=shared \
			--enable-bcmath \
			--enable-calendar \
			--with-kerberos \
			--enable-zip=shared \
			--with-bz2=shared \
			--with-curl=shared \
			--enable-dba=shared \
			--with-cdb \
			--with-gdbm \
			--with-mcrypt=shared \
			--with-mhash=shared \
			--with-mysql=shared \
			--with-mysqli=shared \
            --enable-pdo=shared \
            --with-pdo-sqlite=shared,/usr \
			--with-pdo-mysql=shared,mysqlnd \
			--with-gd=shared \
			--with-jpeg-dir=/usr \
			--with-freetype-dir=/usr \
			--enable-gd-native-ttf \
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
			--enable-mbstring=shared \
			--enable-mbregex \
			--enable-exif=shared \
			--with-openssl=shared \
			--enable-fpm
	else
		cd "php-$PHP_VERSION"
	fi
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
    package_php_extension "exif"
    package_php_extension "fileinfo"
    package_php_extension "ftp"
	package_php_extension "gd"
	package_php_extension "gettext"
	package_php_extension "gmp"
	package_php_extension "imap" "libc-client.so.2007e"
	package_php_extension "ldap"
    package_php_extension "mbstring"
	package_php_extension "mcrypt" "libmcrypt.so.4"
    package_php_extension "mysqli"
    package_php_extension "mysql"
	package_php_extension "openssl"
    package_php_extension "pdo_mysql"
	package_php_extension "pdo_pgsql"
    package_php_extension "pdo"
    package_php_extension "pdo_sqlite"
	package_php_extension "pgsql"
	package_php_extension "pspell" "libaspell.so.15" "libpspell.so.15"
    package_php_extension_snmp
    package_php_extension "soap"
    package_php_extension "sockets"
	package_php_extension "zlib"
	# package third party extensions
	package_php_extension "amqp" "$INSTALL_DIR/librmq-$RABBITMQ_C_VERSION/lib/librabbitmq.so.1"
	package_php_extension "apc"
	package_php_extension "apcu"
	package_php_extension "igbinary"
	package_php_extension "imagick"
    package_php_extension "intl" "libicui18n.so.48" "libicuuc.so.48" "libicudata.so.48" "libicuio.so.48"
	package_php_extension "mailparse"
	package_php_extension "memcache"
	package_php_extension "memcached" \
		"$INSTALL_DIR/libmemcached-$LIBMEMCACHED_VERSION/lib/libmemcached.so.11" \
		"$INSTALL_DIR/libmemcached-$LIBMEMCACHED_VERSION/lib/libmemcachedutil.so.2"
	package_php_extension "mongo"
	package_php_extension "msgpack"
    package_php_extension "opcache"  # ZendOpCache
	package_php_extension "phalcon"
    package_php_extension "phpiredis" "$INSTALL_DIR/hiredis-$HIREDIS_VERSION/lib/libhiredis.so.0.10"
	package_php_extension "redis"
	package_php_extension "sundown"
    package_php_extension "twig"
    package_php_extension "xcache"
	package_php_extension "xdebug"
	package_php_extension "zip"
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
source "$BUILD_DIR/../../php-common/build.sh"

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

# Move packages to the output directory
cd "$BUILD_DIR/../../"
mkdir -p "output/php-$PHP_VERSION"
mv /tmp/staged/app/php-*.gz "output/php-$PHP_VERSION"
mv /tmp/staged/app/php-*.gz.sha1 "output/php-$PHP_VERSION"

# Rename with correct postfix
rename_with_postfix

echo "Done!"

