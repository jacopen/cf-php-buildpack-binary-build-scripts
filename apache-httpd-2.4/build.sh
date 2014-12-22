#!/bin/bash
#
##################################################################
#
# Script to build Apache HTTPD 2.4.x for use with CloudFoundry
#
#   Author:  Daniel Mikusa
#     Date:  11-17-2013
#
##################################################################
#  Configuration
#
APR_VERSION=1.5.1
APR_ICONV_VERSION=1.2.1
APR_UTIL_VERSION=1.5.4
HTTPD_VERSION=2.4.10
# location where files are built
INSTALL_DIR="/tmp/staged/app"
BUILD_DIR=`pwd`/build
##################################################################
set -e

function build_apr() {
	if [ "n$APR_VERSION" == "n" ]; then
		APR_VERSION=1.4.8
	fi
	if [ ! -d "apr-$APR_VERSION" ]; then
		curl -L -O "http://apache.mirrors.tds.net/apr/apr-$APR_VERSION.tar.gz"
		tar zxf "apr-$APR_VERSION.tar.gz"
		rm "apr-$APR_VERSION.tar.gz"
	fi
	cd "apr-$APR_VERSION"
	./configure --prefix="$INSTALL_DIR/libapr-$APR_VERSION"
	make -j 3
	make install
	cd ..
}

function build_apr_iconv() {
	if [ "n$APR_ICONV_VERSION" == "n" ]; then
		APR_ICONV_VERSION=1.2.1
	fi
	if [ ! -d "apr-iconv-$APR_ICONV_VERSION" ]; then
		curl -L -O "http://apache.mirrors.tds.net/apr/apr-iconv-$APR_ICONV_VERSION.tar.gz"
		tar zxf "apr-iconv-$APR_ICONV_VERSION.tar.gz"
		rm "apr-iconv-$APR_ICONV_VERSION.tar.gz"
	fi
	cd "apr-iconv-$APR_ICONV_VERSION"
	./configure \
		--prefix="$INSTALL_DIR/libapr-iconv-$APR_ICONV_VERSION" \
		--with-apr="$INSTALL_DIR/libapr-$APR_VERSION/bin/apr-1-config"
	make -j 3
	make install
	cd ..
}

function build_apr_util() {
	if [ "n$APR_UTIL_VERSION" == "n" ]; then
		APR_UTIL_VERSION=1.5.2
	fi
	if [ ! -d "apr-util-$APR_UTIL_VERSION" ]; then
		curl -L -O "http://apache.mirrors.tds.net/apr/apr-util-$APR_UTIL_VERSION.tar.gz"
		tar zxf "apr-util-$APR_UTIL_VERSION.tar.gz"
		rm "apr-util-$APR_UTIL_VERSION.tar.gz"
	fi
	cd "apr-util-$APR_UTIL_VERSION"
	./configure \
		--prefix="$INSTALL_DIR/libapr-util-$APR_UTIL_VERSION" \
		--with-iconv="$INSTALL_DIR/libapr-iconv-$ICONV_VERSION" \
		--with-crypto \
		--with-openssl \
		--with-mysql \
		--with-pgsql \
		--with-gdbm \
		--with-ldap \
		--with-apr="$INSTALL_DIR/libapr-$APR_VERSION"
	make -j 3
	make install
	cd ..
}

function build_required_libs() {
	cd "$BUILD_DIR"
	build_apr
	build_apr_iconv
	build_apr_util
	cd "$BUILD_DIR"
}

function build_httpd_24() {
	cd "$BUILD_DIR"
	if [ "n$HTTPD_VERSION" == "n" ]; then
		HTTPD_VERSION=2.4.6
	fi
	if [ ! -d "httpd-$HTTPD_VERSION" ]; then
		curl -L -O "http://apache.osuosl.org/httpd/httpd-$HTTPD_VERSION.tar.bz2"
		tar jxf "httpd-$HTTPD_VERSION.tar.bz2"
		rm "httpd-$HTTPD_VERSION.tar.bz2"
	fi
	cd "httpd-$HTTPD_VERSION"
	./configure \
		--prefix="$INSTALL_DIR/httpd" \
		--with-apr="$INSTALL_DIR/libapr-$APR_VERSION" \
		--with-apr-util="$INSTALL_DIR/libapr-util-$APR_UTIL_VERSION" \
		--enable-mpms-shared="worker event" \
		--enable-mods-shared=reallyall \
		--disable-isapi \
		--disable-dav \
		--disable-dialup
	make -j 3
	make install
	cd "$BUILD_DIR"
}

function package_module() {
        cd "$INSTALL_DIR"
        NAME=$1
        tar cf "httpd-$NAME-$HTTPD_VERSION.tar" "httpd/modules/$NAME.so"
        if [ $# -gt 1 ]; then
                for FILE in "${@:2}"; do
                        if [[ $FILE == /* ]]; then
                                cp $FILE httpd/lib
                                FILE=`basename $FILE`
                        else
                                cp "/usr/lib/$FILE" httpd/lib/
                        fi
                        tar rf "httpd-$NAME-$HTTPD_VERSION.tar" "httpd/lib/$FILE"
                done
        fi
        gzip -f -9 "httpd-$NAME-$HTTPD_VERSION.tar"
        shasum "httpd-$NAME-$HTTPD_VERSION.tar.gz" > "httpd-$NAME-$HTTPD_VERSION.tar.gz.sha1"
	rm "httpd/modules/$NAME.so"
        cd "$INSTALL_DIR"
}

function package_modules() {
        cd "$INSTALL_DIR"
	for MOD in $(ls httpd/modules/*.so); do
		MOD=`basename "$MOD"`
		package_module "${MOD%%.*}"
	done
}

# clean up previous work
rm -rf "$INSTALL_DIR"

# setup build directory
if [ ! -d "$BUILD_DIR" ]; then
	mkdir "$BUILD_DIR"
fi

# build required libs & httpd
build_required_libs
build_httpd_24
package_modules

# Remove unnecessary files and config
cd "$INSTALL_DIR/httpd"
rm -rf build/ cgi-bin/ error/ icons/ include/ man/ manual/ htdocs/
rm -rf conf/extra/* conf/httpd.conf conf/httpd.conf.bak conf/magic conf/original

# Install required libraries
mkdir "$INSTALL_DIR/httpd/lib"
cp "$INSTALL_DIR/libapr-$APR_VERSION/lib/libapr-1.so.0" "$INSTALL_DIR/httpd/lib"
cp "$INSTALL_DIR/libapr-util-$APR_UTIL_VERSION/lib/libaprutil-1.so.0" "$INSTALL_DIR/httpd/lib"
cp "$INSTALL_DIR/libapr-iconv-$APR_ICONV_VERSION/lib/libapriconv-1.so.0" "$INSTALL_DIR/httpd/lib"

# Fix start scripts
cd "$INSTALL_DIR/httpd/bin"

# fix hard-coded path with env variable
sed 's/\/tmp\/staged\/app/\${HOME}/g' apachectl > apachectl.fixed
mv apachectl.fixed apachectl
chmod 755 apachectl
sed 's/\/tmp\/staged\/app/\${HOME}/g' envvars > envvars.fixed
mv envvars.fixed envvars
chmod 755 envvars
sed 's/\/tmp\/staged\/app/\${HOME}/g' envvars-std > envvars-std.fixed
mv envvars-std.fixed envvars-std
chmod 755 envvars-std

# switch single to double quotes so variable expansion occurs
sed -r "s/HTTPD='(.*)'/HTTPD=\"\1\"/g" apachectl > apachectl.fixed
mv apachectl.fixed apachectl
chmod 755 apachectl

# Package the binary
cd "$INSTALL_DIR"
tar czf "httpd-$HTTPD_VERSION.tar.gz" httpd
shasum "httpd-$HTTPD_VERSION.tar.gz" > "httpd-$HTTPD_VERSION.tar.gz.sha1"

# Move packages to the output directory
cd "$BUILD_DIR/../../"
mkdir -p "output/httpd-$HTTPD_VERSION"
mv /tmp/staged/app/httpd-*.gz "output/httpd-$HTTPD_VERSION"
mv /tmp/staged/app/httpd-*.gz.sha1 "output/httpd-$HTTPD_VERSION"

echo "Done!"
