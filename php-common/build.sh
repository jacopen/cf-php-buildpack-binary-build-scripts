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

build_external_extension() {
	cd "$BUILD_DIR"
	NAME=$1
	VERSION="${MODULES["$NAME"]}"
	# Build required libraries
	if [ "$NAME" == "amqp" ]; then
		build_librabbit
	fi
	if [ "$NAME" == "phalcon" ]; then
		build_phpalcon $VERSION
		return # has it's own build script, so we just run it and return
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
                --disable-memcached-sasl \
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
