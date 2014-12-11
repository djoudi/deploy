#!/bin/sh
# simpleLNMPinstaller.sh - Simple LNMP Installer remover for Ubuntu OS
#	- Nginx 1.6
#	- MariaDB 10.0.15
#	- PHP 5.5
#	- Memcached
#	- PhpMyAdmin
#	- ionCube Loader
# Min requirement	: Ubuntu 14.04
# Build Date		: 30/11/2014
# Author		: MasEDI.Net (hi@masedi.net)

# Make sure only root can run this installer script
if [ "$(id -u)" != "0" ]; then
	echo "This script must be run as root..." 1>&2
	exit 1
fi

# Variables
arch=$(uname -p)

# Stop Nginx web server
service nginx stop

# Stop php5-fpm server
service php5-fpm stop

# Stop MariaDB mysql server
service mysql stop

# Remove Apache2 if exist
apt-get remove apache2*

# Remove mysql if exist
apt-get remove mysql*

# Remove Nginx - PHP5 - MariaDB - PhpMyAdmin
apt-get remove nginx-full
apt-get remove php-pear php5-fpm php5-cli php5-mysql php5-curl php5-geoip php5-gd php5-intl php5-mcrypt php5-memcache php5-imap php5-ming php5-ps php5-pspell php5-recode php5-snmp php5-sqlite php5-tidy php5-xmlrpc php5-xsl spawn-fcgi openssl geoip-database snmp memcached
apt-get remove php*
apt-get remove mariadb-server-10.0 mariadb-client-10.0 mariadb-server-core-10.0 mariadb-common mariadb-server libmariadbclient18 mariadb-client-core-10.0
apt-get remove phpmyadmin

apt-get autoremove

clear

echo "Thanks for installing LNMP stack using SimpleLNMPInstaller..."
echo "Found any bugs / errors / suggestions? please let me know...."
echo "If you think this script is useful, don't forget to buy me a coffee or milk... My PayPal is always open for donation :D send your tips here hi@masedi.net"
echo ""
echo "Thankz & Greetz: MasEDI - http://masedi.net ;)"
