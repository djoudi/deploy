#!/usr/bin/env bash

# Phalcon PHP extension installer
# Min requirement	: GNU/Linux Ubuntu 14.04
# Last Build		: 21/2/2015
# Author			: MasEDI.Net (hi@masedi.net)

# Make sure only root can run this installer script
if [ "$(id -u)" != "0" ]; then
	echo "This script must be run as root..." 1>&2
	exit 1
fi

# Prerequisite packages
apt-get install php5-dev libpcre3-dev gcc make

git clone http://github.com/phalcon/cphalcon.git
cd cphalcon/build
./install
