#!/bin/bash
#
##################################################################
#
# Common functions for building PHP
#
#   Author:  Daniel Mikusa
#     Date:  11-17-2013
#
##################################################################
build_librabbit() {
    echo "----------------------  Building [librabbit-c] ---------------------------"
	cd "$BUILD_DIR"
	if [ ! -d "rabbitmq-c-$RABBITMQ_C_VERSION" ]; then
                curl -L -O "https://github.com/alanxz/rabbitmq-c/releases/download/v$RABBITMQ_C_VERSION/rabbitmq-c-$RABBITMQ_C_VERSION.tar.gz"
                tar zxf "rabbitmq-c-$RABBITMQ_C_VERSION.tar.gz"
                rm "rabbitmq-c-$RABBITMQ_C_VERSION.tar.gz"
		cd "rabbitmq-c-$RABBITMQ_C_VERSION"
		./configure --prefix="$INSTALL_DIR/librmq-$RABBITMQ_C_VERSION"
		make -j 5
	else
		cd "rabbitmq-c-$RABBITMQ_C_VERSION"
	fi
	if [ ! -d "$INSTALL_DIR/librmq-$RABBITMQ_C_VERSION" ]; then
		make install
	fi
	cd "$BUILD_DIR"
}

build_codizy() {
	cd "$BUILD_DIR"
	if [ ! -d "codizy-extension" ]; then
		git clone https://github.com/codizy-software/codizy-extension
		cd codizy-extension
	else
		cd codizy-extension
		git pull
	fi
	"$INSTALL_DIR/php/bin/phpize"
	./configure --with-php-config="$INSTALL_DIR/php/bin/php-config" 
	make -j 5
	make install
	cd "$BUILD_DIR"
}

build_hiredis() {
    echo "----------------------  Building [hiredis] ---------------------------"
	cd "$BUILD_DIR"
	if [ ! -d "hiredis-$HIREDIS_VERSION" ]; then
		curl -L -O "https://github.com/redis/hiredis/archive/v$HIREDIS_VERSION.tar.gz"
		tar zxf "v$HIREDIS_VERSION.tar.gz"
		rm "v$HIREDIS_VERSION.tar.gz"
		cd "hiredis-$HIREDIS_VERSION"
		make -j 5
	else
		cd "hiredis-$HIREDIS_VERSION"
	fi
	if [ ! -d "$INSTALL_DIR/hiredis-$HIREDIS_VERSION" ]; then
		PREFIX="$INSTALL_DIR/hiredis-$HIREDIS_VERSION" make install
	fi
	cd "$BUILD_DIR"
}

build_ioncube() {
    cd "$BUILD_DIR"
	if [ ! -d "ioncube" ]; then
		curl -L -O "http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz"
		tar zxf "ioncube_loaders_lin_x86-64.tar.gz"
		rm "ioncube_loaders_lin_x86-64.tar.gz"
		cd "ioncube"
	else
		cd "ioncube"
	fi
    cp "LICENSE.txt" "$INSTALL_DIR/php/lib/php/extensions/no-debug-non-zts-$ZTS_VERSION/"
    PHP_MAJOR_VERSION=$(echo "$PHP_VERSION" | cut -c1-3)
    cp "ioncube_loader_lin_$PHP_MAJOR_VERSION.so" "$INSTALL_DIR/php/lib/php/extensions/no-debug-non-zts-$ZTS_VERSION/ioncube.so"
	cd "$BUILD_DIR"

}

build_phpiredis() {
	cd "$BUILD_DIR"
	if [ ! -d "phpiredis" ]; then
		git clone https://github.com/nrk/phpiredis.git
		cd phpiredis
	else
		cd phpiredis
		git pull
	fi
	"$INSTALL_DIR/php/bin/phpize"
	./configure --with-php-config="$INSTALL_DIR/php/bin/php-config" --enable-phpiredis --with-hiredis-dir="$INSTALL_DIR/hiredis-$HIREDIS_VERSION"
	make -j 5
	make install
	cd "$BUILD_DIR"
}

build_phpalcon() {
	cd "$BUILD_DIR"
	PHALCON_VERSION=$1
	if [ ! -d "cphalcon-phalcon-v$PHALCON_VERSION" ]; then
                curl -L -O "https://github.com/phalcon/cphalcon/archive/phalcon-v$PHALCON_VERSION.zip"
                unzip -q "phalcon-v$PHALCON_VERSION.zip"
                rm "phalcon-v$PHALCON_VERSION.zip"
        fi
	cd "cphalcon-phalcon-v$PHALCON_VERSION/build"
	sed -i "s|./configure --enable-phalcon|./configure --with-php-config=\"$INSTALL_DIR/php/bin/php-config\" --enable-phalcon|g" install
	sed -i "s|^phpize |$INSTALL_DIR/php/bin/phpize |g" install
	./install
	cd "$BUILD_DIR"
}

build_suhosin() {
       cd "$BUILD_DIR"
       SUHOSIN_VERSION=$1
       if [ ! -d "suhosin-$SUHOSIN_VERSION" ]; then
               curl -L -O "http://download.suhosin.org/suhosin-$SUHOSIN_VERSION.tgz"
               tar zxf "suhosin-$SUHOSIN_VERSION.tgz"
               rm "suhosin-$SUHOSIN_VERSION.tgz"
       fi
       cd "suhosin-$SUHOSIN_VERSION"
       "$INSTALL_DIR/php/bin/phpize"
       ./configure --with-php-config="$INSTALL_DIR/php/bin/php-config"
       make -j 5
       make install
       cd "$BUILD_DIR"
}

build_twig() {
       cd "$BUILD_DIR"
       TWIG_VERSION=$1
       if [ ! -d "Twig-$TWIG_VERSION" ]; then
               curl -L -O "https://github.com/fabpot/Twig/archive/v$TWIG_VERSION.tar.gz"
               tar zxf "v$TWIG_VERSION.tar.gz"
               rm "v$TWIG_VERSION.tar.gz"
       fi
       cd "Twig-$TWIG_VERSION/ext/twig"
       "$INSTALL_DIR/php/bin/phpize"
       ./configure --with-php-config="$INSTALL_DIR/php/bin/php-config"
       make -j 5
       make install
       cd "$BUILD_DIR"
}

build_xcache() {
       cd "$BUILD_DIR"
       XCACHE_VERSION=$1
       if [ ! -d "xcache-$XCACHE_VERSION" ]; then
               curl -L -O "http://xcache.lighttpd.net/pub/Releases/$XCACHE_VERSION/xcache-$XCACHE_VERSION.tar.gz"
               tar zxf "xcache-$XCACHE_VERSION.tar.gz"
               rm "xcache-$XCACHE_VERSION.tar.gz"
       fi
       cd "xcache-$XCACHE_VERSION/"
       "$INSTALL_DIR/php/bin/phpize"
       ./configure --with-php-config="$INSTALL_DIR/php/bin/php-config" --enable-xcache
       make -j 5
       make install
       cd "$BUILD_DIR"
}

build_xhprof() {
	cd "$BUILD_DIR"
	if [ ! -d "xhprof" ]; then
		git clone https://github.com/codizy-software/xhprof
		cd xhprof
	else
		cd xhprof
		git pull
	fi
    cd extension
	"$INSTALL_DIR/php/bin/phpize"
	./configure --with-php-config="$INSTALL_DIR/php/bin/php-config" 
	make -j 5
	make install
	cd "$BUILD_DIR"
}

build_libmemcached() {
	cd "$BUILD_DIR"
	if [ ! -d "libmemcached-$LIBMEMCACHED_VERSION" ]; then
		curl -L -O "https://launchpad.net/libmemcached/1.0/$LIBMEMCACHED_VERSION/+download/libmemcached-$LIBMEMCACHED_VERSION.tar.gz"
                tar zxf "libmemcached-$LIBMEMCACHED_VERSION.tar.gz"
                rm "libmemcached-$LIBMEMCACHED_VERSION.tar.gz"
		cd "libmemcached-$LIBMEMCACHED_VERSION"
		./configure --prefix="$INSTALL_DIR/libmemcached-$LIBMEMCACHED_VERSION"
		make -j 5
	else
		cd "libmemcached-$LIBMEMCACHED_VERSION"
	fi
	if [ ! -d "$INSTALL_DIR/libmemcached-$LIBMEMCACHED_VERSION" ]; then
		make install
	fi
	cd "$BUILD_DIR"
}

build_external_extension() {
	cd "$BUILD_DIR"
	NAME=$1
	VERSION="${MODULES["$NAME"]}"
	# Build required libraries
	if [ "$NAME" == "amqp" ]; then
		build_librabbit
	fi
    if [ "$NAME" == "codizy" ]; then
        build_codizy
        return # not part of PECL, on github
    fi
    if [ "$NAME" == "ioncube" ]; then
        build_ioncube
        return # commercial, but redistributable
    fi
	if [ "$NAME" == "memcached" ]; then
		build_libmemcached
	fi
	if [ "$NAME" == "phalcon" ]; then
		build_phpalcon $VERSION
		return # has it's own build script, so we just run it and return
	fi
	if [ "$NAME" == "phpiredis" ]; then
		build_hiredis
		build_phpiredis
		return # not part of PECL
	fi
	if [ "$NAME" == "suhosin" ]; then
        build_suhosin $VERSION
        return # not part of PECL
    fi
    if [ "$NAME" == "twig" ]; then
        build_twig $VERSION
        return # not part of PECL
    fi
	if [ "$NAME" == "xcache" ]; then
		build_xcache $VERSION
		return # not part of PECL
	fi
    if [ "$NAME" == "xhprof" ]; then
        build_xhprof
        return # PECL version is buggy, get from trunk
    fi
	# Download and build extension from PECL
	if [ ! -d "$NAME-$VERSION" ]; then
                curl -L -O "http://pecl.php.net/get/$NAME-$VERSION.tgz"
                tar zxf "$NAME-$VERSION.tgz"
                rm "$NAME-$VERSION.tgz"
		rm package.xml
		cd "$NAME-$VERSION"
		"$INSTALL_DIR/php/bin/phpize"
		# specify custom ./configure arguments
		if [ "$NAME" == "amqp" ]; then
			./configure --with-php-config="$INSTALL_DIR/php/bin/php-config" --with-librabbitmq-dir="$INSTALL_DIR/librmq-$RABBITMQ_C_VERSION"
		elif [ "$NAME" == "memcached" ]; then
			./configure --with-php-config="$INSTALL_DIR/php/bin/php-config" \
				--with-libmemcached-dir="$INSTALL_DIR/libmemcached-$LIBMEMCACHED_VERSION" \
				--enable-memcached-msgpack \
				--enable-memcached-igbinary \
				--enable-memcached-json
		else
			./configure --with-php-config="$INSTALL_DIR/php/bin/php-config"
		fi
		make -j 5
	else
		cd "$NAME-$VERSION"
        fi
	make install
	cd "$BUILD_DIR"
}

build_external_extensions() {
	for MODULE in "${!MODULES[@]}"; do
        echo "----------------------  Building [$MODULE] ---------------------------"
		build_external_extension "$MODULE"
	done
}

package_php_extension() {
	cd "$INSTALL_DIR"
	NAME=$1
	tar cf "php-$NAME-$PHP_VERSION.tar" "php/lib/php/extensions/no-debug-non-zts-$ZTS_VERSION/$NAME.so"
	if [ $# -gt 1 ]; then
		for FILE in "${@:2}"; do
			if [[ $FILE == /* ]]; then
				cp $FILE php/lib
				FILE=`basename $FILE`
			else
				cp "/usr/lib/$FILE" php/lib/
			fi
			tar rf "php-$NAME-$PHP_VERSION.tar" "php/lib/$FILE"
		done
	fi
	gzip -f -9 "php-$NAME-$PHP_VERSION.tar"
	shasum "php-$NAME-$PHP_VERSION.tar.gz" > "php-$NAME-$PHP_VERSION.tar.gz.sha1"
	cd "$INSTALL_DIR"
}

package_php_extension_snmp() {
       cd "$INSTALL_DIR"
       NAME=snmp
       tar cf "php-$NAME-$PHP_VERSION.tar" "php/lib/php/extensions/no-debug-non-zts-$ZTS_VERSION/$NAME.so"
       cp "/usr/lib/libnetsnmp.so.15" php/lib/
       tar rf "php-$NAME-$PHP_VERSION.tar" "php/lib/libnetsnmp.so.15"
       mkdir -p php/mibs
       cp /usr/share/snmp/mibs/* php/mibs
       tar rf "php-$NAME-$PHP_VERSION.tar" "php/mibs"
       gzip -f -9 "php-$NAME-$PHP_VERSION.tar"
        shasum "php-$NAME-$PHP_VERSION.tar.gz" > "php-$NAME-$PHP_VERSION.tar.gz.sha1"
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

package_php_cgi() {
	cd "$INSTALL_DIR"
	tar czf "php-cgi-$PHP_VERSION.tar.gz" php/bin/php-cgi
	shasum "php-cgi-$PHP_VERSION.tar.gz" > "php-cgi-$PHP_VERSION.tar.gz.sha1"
	rm php/bin/php-cgi
	cd "$INSTALL_DIR"
}

package_php_cli() {
	cd "$INSTALL_DIR"
	rm php/bin/phar
	ln -s /home/vcap/app/php/bin/phar.phar php/bin/phar
	tar czf "php-cli-$PHP_VERSION.tar.gz" php/bin/php php/bin/phar php/bin/phar.phar 
	shasum "php-cli-$PHP_VERSION.tar.gz" > "php-cli-$PHP_VERSION.tar.gz.sha1"
	rm php/bin/php php/bin/phar php/bin/phar.phar
	cd "$INSTALL_DIR"
}

package_php_pear() {
	cd "$INSTALL_DIR"
	tar czf "php-pear-$PHP_VERSION.tar.gz" \
		--exclude=php/lib/php/extensions \
			php/bin/pear \
			php/bin/pecl \
			php/bin/peardev \
			php/etc/pear.conf \
			php/lib/php
	shasum "php-pear-$PHP_VERSION.tar.gz" > "php-pear-$PHP_VERSION.tar.gz.sha1"
	rm php/bin/pear php/bin/pecl php/bin/peardev php/etc/pear.conf
	# remove everything except 'extensions' dir
	mv php/lib/php/extensions /tmp/staged/extensions
	rm -rf php/lib/php
	mkdir php/lib/php
	mv /tmp/staged/extensions php/lib/php/extensions
	cd "$INSTALL_DIR"
}

package_php() {
	cd "$INSTALL_DIR"
	tar czf "php-$PHP_VERSION.tar.gz" "php"
	shasum "php-$PHP_VERSION.tar.gz" > "php-$PHP_VERSION.tar.gz.sha1"
	cd "$INSTALL_DIR"
}

rename_with_postfix() {
	cd "$BUILD_DIR/../../output"
	if [ "n$VERSION_POSTFIX" != "n" ]; then
		echo "Renaming with version postfix [$VERSION_POSTFIX]"
		mv "php-$PHP_VERSION" "php-$PHP_VERSION$VERSION_POSTFIX"
		cd "php-$PHP_VERSION$VERSION_POSTFIX"
		for f in `ls *.gz`; do
			mv $f "`basename $f $PHP_VERSION.tar.gz`$PHP_VERSION$VERSION_POSTFIX.tar.gz"
		done
		for f in `ls *.sha1`; do
			mv $f "`basename $f $PHP_VERSION.tar.gz.sha1`$PHP_VERSION$VERSION_POSTFIX.tar.gz.sha1"
		done
	fi
	cd "$BUILD_DIR/../"
}
##################################################################
