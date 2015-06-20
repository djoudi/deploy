Simple LNMP Installer
=====

Simple server deployment scripts for GNU/Linux Ubuntu. 
Tested in GNU/Linux Ubuntu 12.04 & 14.04, and Linux Mint 17 (Rebecca).

Features
=====
* Nginx custom build from RtCamp repository, already optimized for Wordpress site, Laravel, and Phalcon PHP Framework
* Nginx with FastCGI cache enable & disable feature
* Nginx pre-configured optimization for low-end VPS
* MariaDB 10 (MySQL drop-in replacement)
* PHP 5.x latest build
* PHP5-FPM sets as user running the PHP script (pool)
* Zend OPcache
* Memcached 1.4
* ionCube PHP Loader
* Adminer (PhpMyAdmin replacement)

Usage
=====

# Install Nginx, PHP 5 &amp; MariaDB

```bash
wget --no-check-certificate https://raw.githubusercontent.com/joglomedia/deploy/master/scripts/simpleLNMPinstaller.sh

sudo ./simpleLNMPinstaller.sh
```

Nginx vHost Configuration Tool (Ngxvhost)
=====
This script also include Nginx vHost configuration tool to help you add new website (domain) easily. 
The Ngxvhost must be run as root (recommended using sudo).

# Ngxvhost Usage

```bash
sudo ngxvhost -u username -s example.com -t default -d /home/username/Webs/example.com
```
Ngxvhost Parameters:

* -u your username
* -s your site / domain name
* -t site type, available options: default, wordpress, wordpress-ms, phalcon, laravel
* -d path to your site directory containing the index file

for more helps
```bash
sudo ngxvhost --help
```

Note: Ngxvhost will automagically add new FPM user's pool configuration file if it doesn't exists.

Web-based Administration
=====
You can access pre-installed web-based administration tools here
```bash
http://YOUR_IP_ADDRESS/tools/
```

Found bug or have any suggestions?
=====
Please send your PR on the Github repository.

(c) 2015
<a href="http://masedi.net/">MasEDI.Net</a>
