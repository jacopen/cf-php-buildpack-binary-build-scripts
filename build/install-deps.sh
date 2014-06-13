#!/bin/bash
#
# Install dependencies for building the build pack binaries.
#
#  Usage:
#    ./install-deps.sh <os> <version>
#      <os>  One of these:  ubunbu
#      <version>  OS Version: 10.04, 12.04, 14.04
#
#  Date: 6-9-2014
#  Author:  Daniel Mikusa <dmikusa@gopivotal.com
#
OS=$(cat /etc/issue | cut -d ' ' -f 1)
VERSION=$(cat /etc/issue | cut -d ' ' -f 2)

if [ "$OS" == "Ubuntu" ]; then
	# update repo and packages
	sudo apt-get update
	sudo apt-get -y upgrade
	if [[ "$VERSION" == "10.04"* ]]; then
		sudo apt-get -y install build-essential autoconf automake libssl-dev libsnmp-dev mercurial libbz2-dev libldap2-dev libpcre3-dev libxml2-dev libpq-dev libzip-dev libcurl4-openssl-dev libgdbm-dev libmysqlclient-dev libgmp3-dev libjpeg-dev libpng12-dev libc-client2007e-dev libsasl2-dev libmcrypt-dev libaspell-dev libpspell-dev libexpat1-dev imagemagick libmagickwand-dev libmagickcore-dev
	elif [[ "$VERSION" == "12.04"* ]]; then
		sudo apt-get -y install build-essential autoconf automake libssl-dev libsnmp-dev mercurial libbz2-dev libldap2-dev libpcre3-dev libxml2-dev libpq-dev libzip-dev libcurl4-openssl-dev libgdbm-dev libmysqlclient-dev libgmp3-dev libjpeg-dev libpng12-dev libc-client2007e-dev libsasl2-dev libmcrypt-dev libaspell-dev libpspell-dev libexpat1-dev imagemagick libmagickwand-dev libmagickcore-dev
	elif [[ "$VERSION" == "14.04"* ]]; then
		sudo apt-get -y install build-essential autoconf automake libssl-dev libsnmp-dev mercurial libbz2-dev libldap2-dev libpcre3-dev libxml2-dev libpq-dev libzip-dev libcurl4-openssl-dev libgdbm-dev libmysqlclient-dev libgmp-dev libgmp-dev:i386 libjpeg-dev libpng12-dev libc-client2007e-dev libsasl2-dev libmcrypt-dev libaspell-dev libpspell-dev libexpat1-dev imagemagick libmagickwand-dev libmagickcore-dev
	else
		echo "Version [$VERSION] of [$OS] is not supported"
		exit -1
	fi
else
	echo "Version [$VERSION] of [$OS] is not supported"
	exit -1
fi # Add support for other OS's here
