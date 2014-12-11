#!/bin/sh
# simpleLNMPinstaller.sh - Simple LNMP Installer for Ubuntu OS
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

# Install pre-requirements 
apt-get update && apt-get install -y software-properties-common python-software-properties git

# Add Nginx latest stable from PPA repo
# Source: https://launchpad.net/~nginx/+archive/ubuntu/stable
#add-apt-repository ppa:nginx/stable
# install nginx custom with ngx cache purge
# https://rtcamp.com/wordpress-nginx/tutorials/single-site/fastcgi-cache-with-purging/
add-apt-repository ppa:rtcamp/nginx

# Add PHP5 (5.5 latest stable) from PPA repo
# Source: https://launchpad.net/~ondrej/+archive/ubuntu/php5
add-apt-repository ppa:ondrej/php5

# Add PhpMyAdmin from PPA repo
# Replace phpmyadmin with adminer (simple, lighter, as powerful as phpMyAdmin)
#add-apt-repository ppa:nijel/phpmyadmin

# Add MariaDB repo from MariaDB repo configuration tool
apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
echo -e "# MariaDB 10.0 repository list - created 2014-11-30 14:04 UTC\n# http://mariadb.org/mariadb/repositories/\ndeb http://ftp.osuosl.org/pub/mariadb/repo/10.0/ubuntu trusty main\ndeb-src http://ftp.osuosl.org/pub/mariadb/repo/10.0/ubuntu trusty main" > /etc/apt/sources.list.d/MariaDB.list

# Update repo/packages
apt-get update

# Remove Apache2 if exist
apt-get remove apache2*

# Remove mysql if exist
apt-get remove mysql*

# Install Nginx - PHP5 - MariaDB - PhpMyAdmin
#apt-get install -y nginx-full 
apt-get install -y nginx-custom
apt-get install -y php5-fpm php5-cli php5-mysql php5-curl php5-geoip php5-gd php5-intl php5-mcrypt php5-memcache php5-imap php5-ming php5-ps php5-pspell php5-recode php5-snmp php5-sqlite php5-tidy php5-xmlrpc php5-xsl php-pear spawn-fcgi openssl geoip-database snmp memcached
apt-get install -y mariadb-server-10.0 mariadb-client-10.0 mariadb-server-core-10.0 mariadb-common mariadb-server libmariadbclient18 mariadb-client-core-10.0
#apt-get install -y phpmyadmin

# Install Adminer
wget http://downloads.sourceforge.net/adminer/adminer-4.1.0-en.php -O /usr/share/nginx/html/phpminiadmin.php

# Install PHP Info
wget --no-check-certificate https://github.com/joglomedia/deploy/raw/master/phpinfo.php -O /usr/share/nginx/html/phpinfo.php

# Install ionCube Loader
wget "http://downloads2.ioncube.com/loader_downloads/ioncube_loaders_lin_$arch.tar.gz"
tar xzf ioncube_loaders_lin_$arch.tar.gz
mv ioncube /usr/local
rm -f ioncube_loaders_lin_$arch.tar.gz

# Enable ionCube Loader
echo -e "zend_extension=/usr/local/ioncube/ioncube_loader_lin_5.5.so" > /etc/php5/mods-available/ioncube.ini

### Additional Settings ###
# Fix cgi.fix_pathinfo
sed -i "s/cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php5/fpm/php.ini

# Clone the deployment server config
git clone https://github.com/joglomedia/deploy.git deploy

# Copy the optimized-version of php5-fpm config file
mv /etc/php5/fpm/php-fpm.conf /etc/php5/fpm/php-fpm.conf.save
cp deploy/php5/fpm/php-fpm.conf /etc/php5/fpm/

# Copy the optimized-version of php5-fpm default pool
mv /etc/php5/fpm/pool.d/www.conf /etc/php5/fpm/pool.d/www.conf.save
cp deploy/php5/fpm/pool.d/www.conf /etc/php5/fpm/pool.d/

# Restart php5-fpm server
service php5-fpm restart

# Copy custom Nginx Config
mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.save
cp -f deploy/nginx/fastcgi_cache /etc/nginx/
cp -f deploy/nginx/fastcgi_https_map /etc/nginx/
cp -f deploy/nginx/fastcgi_params /etc/nginx/
cp -f deploy/nginx/http_proxy_ips /etc/nginx/
cp -f deploy/nginx/proxy_cache /etc/nginx/
cp -f deploy/nginx/proxy_params /etc/nginx/
cp -f deploy/nginx/upstream.conf /etc/nginx/
cp -f deploy/nginx/conf.vhost /etc/nginx/
cp -f deploy/nginx/nginx.conf /etc/nginx/
mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.save
cp -f deploy/nginx/sites-available/default /etc/nginx/sites-available/
cp -f deploy/nginx/sites-available/phpmyadmin /etc/nginx/sites-available/
cp -f deploy/nginx/sites-available/sample-wordpress.site /etc/nginx/sites-available/

# Remove Apache2 if exist ( automatic installed by phpmyadmin? :( )
apt-get remove apache2

# Restart nginx server, restart nginx from previosuley crashed with apache2
service nginx restart

# MySQL error
# https://serverfault.com/questions/104014/innodb-error-log-file-ib-logfile0-is-of-different-size
service mysql stop
mv /var/lib/mysql/ib_logfile0 /var/lib/mysql/ib_logfile0.save
mv /var/lib/mysql/ib_logfile1 /var/lib/mysql/ib_logfile1.save
service mysql start

# MySQL Secure Install
mysql_secure_installation

# MySQL Install DB 
#mysql_install_db

# Restart MariaDB MySQL server
service mysql restart

# Cleanup
rm -fr deploy

clear

echo "Thanks for installing LNMP stack using SimpleLNMPInstaller..."
echo "Found any bugs / errors / suggestions? please let me know...."
echo "If you think this script is useful, don't forget to buy me a coffee or milk... My PayPal is always open for donation :D send your tips here hi@masedi.net"
echo ""
echo "Thankz & Greetz: MasEDI - http://masedi.net ;)"