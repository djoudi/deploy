Simple LNMP Installer
=====

My personal server deployment scripts for GNU/Linux Ubuntu. Tested in GNU/Linux Ubuntu 12.04 & 14.04.

Features
=====
* Nginx custom build from RtCamp optimized for Wordpress site, Laravel, and Phalcon PHP Framework
* Nginx with FastCGI cache enable & disable feature
* Nginx pre-configured optimization for low-end VPS
* MariaDB 10 (MySQL drop-in replacement)
* PHP 5.x latest build
* PHP5-FPM sets as user running the PHP script (pool)
* Zend Opcache
* Memcached 1.4
* IonCube Loader
* Adminer (PhpMyAdmin replacement)

Usage
=====
```bash
git clone https://github.com/joglomedia/deploy.git
```

# Install Nginx. PHP 5 &amp; MariaDB
```bash
cd deploy/scripts
sudo ./simpleLNMPinstaller.sh
```

or

```bash
wget --no-check-certificate https://raw.githubusercontent.com/joglomedia/deploy/master/scripts/simpleLNMPinstaller.sh
sudo ./simpleLNMPinstaller.sh
```

Nginx vHost Configuration Tool (Ngxvhost)
=====
This script also include Nginx vHost configuration tool to help you add new site easily. 
The Ngxvhost must be run as root (try using sudo).

# Ngxvhost Usage
```bash
sudo ngxvhost -u someone -s example.com -t default -d /home/user/Webs/example.com
```

Note: Ngxvhost will automagically add new FPM user's pool config file if it doesn't exists.

Found bug? Have any suggestions?
=====
Please send your PR on the Github repository.

(c) 2015
<a href="http://masedi.net/">MasEDI.Net</a>
