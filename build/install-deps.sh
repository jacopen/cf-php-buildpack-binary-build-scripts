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
OS=$1
VERSION=$2

if [ "$OS" == "" ] || [ "$VERSION" == "" ]; then
	echo "Usage:"
	echo "./install-deps.sh <os> <version>"
	echo "   <os>  One of these:  ubunbu"
	echo "   <version>  OS Version: 10.04, 12.04, 14.04"
	exit -1
fi

if [ "$OS" == "ubuntu" ]; then
	# update repo and packages
	sudo apt-get update
	sudo apt-get -y upgrade
	if [ "$VERSION" == "10.04" ]; then
		sudo apt-get -y install build-essential autoconf automake git-core libssl-dev libsnmp-dev mercurial libbz2-dev libldap2-dev libpcre3-dev libxml2-dev libpq-dev libzip-dev libcurl4-openssl-dev libgdbm-dev libmysqlclient-dev libgmp3-dev libjpeg-dev libpng12-dev libc-client2007e-dev libsasl2-dev libmcrypt-dev libaspell-dev libpspell-dev libexpat1-dev imagemagick libmagickwand-dev libmagickcore-dev
	elif [ "$VERSION" == "12.04" ]; then
		sudo apt-get -y install build-essential autoconf automake git-core libssl-dev libsnmp-dev mercurial libbz2-dev libldap2-dev libpcre3-dev libxml2-dev libpq-dev libzip-dev libcurl4-openssl-dev libgdbm-dev libmysqlclient-dev libgmp3-dev libjpeg-dev libpng12-dev libc-client2007e-dev libsasl2-dev libmcrypt-dev libaspell-dev libpspell-dev libexpat1-dev imagemagick libmagickwand-dev libmagickcore-dev
	elif [ "$VERSION" == "14.04" ]; then
		sudo apt-get -y install build-essential autoconf automake git-core libssl-dev libsnmp-dev mercurial libbz2-dev libldap2-dev libpcre3-dev libxml2-dev libpq-dev libzip-dev libcurl4-openssl-dev libgdbm-dev libmysqlclient-dev libgmp3-dev libjpeg-dev libpng12-dev libc-client2007e-dev libsasl2-dev libmcrypt-dev libaspell-dev libpspell-dev libexpat1-dev imagemagick libmagickwand-dev libmagickcore-dev
	else
		echo "Version [$VERSION] of Ubuntu is not supported"
		exit -1
	fi
fi # Add support for other OS's here
