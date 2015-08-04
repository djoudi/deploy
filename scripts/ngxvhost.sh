#!/usr/bin/env bash

#  +------------------------------------------------------------------------+
#  | NgxVhost - Simple Nginx vHost Configs File Generator                   |
#  +------------------------------------------------------------------------+
#  | Copyright (c) 2014-2015 NgxTools (http://www.ngxtools.cf)              |
#  +------------------------------------------------------------------------+
#  | This source file is subject to the New BSD License that is bundled     |
#  | with this package in the file docs/LICENSE.txt.                        |
#  |                                                                        |
#  | If you did not receive a copy of the license and are unable to         |
#  | obtain it through the world-wide-web, please send an email             |
#  | to license@ngxtools.cf so we can send you a copy immediately.          |
#  +------------------------------------------------------------------------+
#  | Authors: Edi Septriyanto <hi@masedi.net>                               |
#  |          Fideloper <https://gist.github.com/fideloper/9063376>         |
#  +------------------------------------------------------------------------+

# Version Control
Versi='1.1.2-beta'
InstallDir=$(pwd)

# May need to run this as sudo!
# I have it in /usr/local/bin and run command 'ngxvhost' from anywhere, using sudo.
if [ $EUID -ne 0 ]; then
	echo "You must be root: \"sudo ngxvhost\""
	exit 1
fi

# Check prerequisite packages
Unzip=$(which unzip)
Git=$(which git)
if [[ ! -f $Unzip || ! -f $Git ]]; then
	echo "Ngxvhost requires unzip and git, please install it first"
	echo "help: sudo apt-get install unzip git"
	exit 1;
fi

#
# Show Usage, Output to STDERR
#
function show_usage {
cat <<- _EOF_
ngxvhost $Versi, creates a new Nginx vHost config file in Ubuntu Server.
Requirements: /etc/nginx/sites-available and /etc/nginx/sites-enabled setup used.
Usage: ngxvhost [OPTION]...

  -d    DocumentRoot - i.e. /var/www/yoursite
  -h    Help - Show this menu
  -s    ServerName - i.e. example.com or sub.example.com
  -t    Type of website (platform) - i.e. default. Supported platform: default, laravel, phalcon, wordpress, wordpress-ms
  -u    UserName - Use username added from adduser/useradd

Example:
ngxvhost -u username -s example.com -t default -d /home/username/Webs/example.com

Mail bug reports and suggestions to <hi@masedi.net>.
_EOF_
exit 1
}

#
# Output Default vHost skeleton, fill with userinput
# To be outputted into new file
# Work for default and WordPress site
#
function create_vhost {
cat <<- _EOF_
server {
    listen 80;
    #listen [::]:80 default_server ipv6only=on;

    ## Make site accessible from world web.
    server_name $ServerName www.$ServerName *.$ServerName;

    ## Log Settings.
    access_log /var/log/nginx/${ServerName}_access.log;
    error_log  /var/log/nginx/${ServerName}_error.log error;

    #charset utf-8;

    ## Vhost root directory
    set \$root_path '$DocumentRoot';
    root \$root_path;
    index index.php index.html index.htm;

    ## Global directives configuration.
    include /etc/nginx/conf.vhost/block.conf;
    include /etc/nginx/conf.vhost/staticfiles.conf;
    include /etc/nginx/conf.vhost/restrictions.conf;

    ## Default vhost directives configuration, use only one config.
    include /etc/nginx/conf.vhost/site_${Platform}.conf;

    ## pass the PHP scripts to php5-fpm
    location ~ \.php$ {
        try_files \$uri =404;

        fastcgi_split_path_info ^(.+\.php)(/.+)$;

        fastcgi_index index.php;

        # Include FastCGI Params.
        include /etc/nginx/fastcgi_params;

        # Include FastCGI Configs.
        include /etc/nginx/conf.vhost/fastcgi.conf;

        # Uncomment to Enable PHP FastCGI cache.
        #include /etc/nginx/conf.vhost/fastcgi_cache.conf;

        # FastCGI socket, change to fits your own socket!
        fastcgi_pass unix:/var/run/php5-fpm.${UserName}.sock;
    }

    ## Uncomment to enable error page directives configuration.
    #include /etc/nginx/conf.vhost/errorpage.conf;

    ## Add your custom site directives here.
}
_EOF_
}


#
# Output Laravel vHost skeleton, fill with userinput
# To be outputted into new file
#
function create_laravel_vhost {
cat <<- _EOF_
server {
    listen 80;
    #listen [::]:80 default_server ipv6only=on;

    ## Make site accessible from world web.
    server_name $ServerName www.$ServerName;

    ## Log Settings.
    access_log /var/log/nginx/${ServerName}_access.log;
    error_log  /var/log/nginx/${ServerName}_error.log error;

    #charset utf-8;

    ## Vhost root directory
    set \$root_path '${DocumentRoot}';
    root \$root_path;
    index index.php index.html index.htm;

    ## Global directives configuration.
    include /etc/nginx/conf.vhost/block.conf;
    include /etc/nginx/conf.vhost/staticfiles.conf;
    include /etc/nginx/conf.vhost/restrictions.conf;

    ## Default vhost directives configuration, use only one config.
    include /etc/nginx/conf.vhost/site_${Platform}.conf;

    ## pass the PHP scripts to php5-fpm
    location ~ \.php$ {
        fastcgi_index index.php;

        fastcgi_split_path_info		^(.+\.php)(/.+)$;

        # Include FastCGI Params.
        include /etc/nginx/fastcgi_params;

        # Overwrite FastCGI Params here.
        #fastcgi_param PATH_INFO			\$fastcgi_path_info;
        fastcgi_param SCRIPT_FILENAME	\$document_root\$fastcgi_script_name;
        #fastcgi_param SCRIPT_NAME		\$fastcgi_script_name;

        # Include FastCGI Configs.
        include /etc/nginx/conf.vhost/fastcgi.conf;

        # Uncomment to Enable PHP FastCGI cache.
        #include /etc/nginx/conf.vhost/fastcgi_cache.conf;

        # FastCGI socket, change to fits your own socket!
        fastcgi_pass unix:/var/run/php5-fpm.${UserName}.sock;
    }

    ## Uncomment to enable error page directives configuration.
    #include /etc/nginx/conf.vhost/errorpage.conf;

    ## Add your custom site directives here.
}
_EOF_
}

#
# Output PhalconPHP vHost skeleton, fill with userinput
# To be outputted into new file
#
function create_phalcon_vhost {
cat <<- _EOF_
server {
    listen 80;
    #listen [::]:80 default_server ipv6only=on;

    ## Make site accessible from world web.
    server_name $ServerName www.$ServerName;

    ## Log Settings.
    access_log /var/log/nginx/${ServerName}_access.log;
    error_log  /var/log/nginx/${ServerName}_error.log error;

    #charset utf-8;

    ## Vhost root directory
    set \$root_path '${DocumentRoot}/public';
    root \$root_path;
    index index.php index.html index.htm;

    ## Global directives configuration.
    include /etc/nginx/conf.vhost/block.conf;
    include /etc/nginx/conf.vhost/staticfiles.conf;
    include /etc/nginx/conf.vhost/restrictions.conf;

    ## Default vhost directives configuration, use only one config.
    include /etc/nginx/conf.vhost/site_${Platform}.conf;

    ## pass the PHP scripts to php5-fpm
    location ~ \.php {
        fastcgi_index index.php;

        fastcgi_split_path_info		^(.+\.php)(/.+)$;

        # Include FastCGI Params.
        include /etc/nginx/fastcgi_params;

        # Overwrite FastCGI Params here.
        fastcgi_param PATH_INFO			\$fastcgi_path_info;
        fastcgi_param SCRIPT_FILENAME	\$document_root\$fastcgi_script_name;
        fastcgi_param SCRIPT_NAME		\$fastcgi_script_name;

        # Phalcon PHP custom params.
        fastcgi_param APPLICATION_ENV	development;

        # Include FastCGI Configs.
        include /etc/nginx/conf.vhost/fastcgi.conf;

        # Uncomment to Enable PHP FastCGI cache.
        #include /etc/nginx/conf.vhost/fastcgi_cache.conf;

        # FastCGI socket, change to fits your own socket!
        fastcgi_pass unix:/var/run/php5-fpm.${UserName}.sock;
    }

    ## Uncomment to enable error page directives configuration.
    #include /etc/nginx/conf.vhost/errorpage.conf;

    ## Add your custom site directives here.
}
_EOF_
}

#
# Output Wordpress Multisite vHost header
#
function prepare_wpms_vhost {
cat <<- _EOF_
# Wordpress Multisite Mapping for Nginx.
map \$http_host \$blogid {
    default		0;
    #include	${DocumentRoot}/wp-content/uploads/nginx-helper/map.conf;
}

_EOF_
}

#
# Output index.html skeleton for default index page
# To be outputted into new index.html file in document root
#
function create_indexfile {
cat <<- _EOF_
<!DOCTYPE html>
<html>
  <head>
    <title>It Works!</title>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />	
    <meta name="robots" content="index, follow" />
    <meta name="description" content="This is a default index page for Nginx server generated with ngxvhost tool from http://masedi.net" />
  </head>
  <body>
    <h1>It Works!</h1>
    <div class="content">
        <p>If you are site owner or administrator of this website, please upload your page or update this index page.</p>
        <p style="font-size:90%;">Generated using <em>ngxvhost</em> from <a href="http://ngxtools.cf/">ngxtools</a>, simple <a href="http://nginx.org/" rel="nofollow">Nginx</a> web server management tool.</p>
    </div>
  </body>
</html>	
_EOF_
}

function create_fpm_pool_conf {
	cat <<- _EOF_
	[$UserName]
	user = $UserName
	group = $UserName

	listen = /var/run/php5-fpm.\$pool.sock
	listen.owner = $UserName
	listen.group = $UserName
	listen.mode = 0666
	;listen.allowed_clients = 127.0.0.1

	pm = dynamic
	pm.max_children = 5
	pm.start_servers = 1
	pm.min_spare_servers = 1
	pm.max_spare_servers = 3
	pm.process_idle_timeout = 30s;
	pm.max_requests = 500

	slowlog = /var/log/php5-fpm_slow.\$pool.log
	request_slowlog_timeout = 1
	 
	chdir = /

	security.limit_extensions = .php .php3 .php4 .php5
	 
	;php_admin_value[sendmail_path] = /usr/sbin/sendmail -t -i -f you@yourmail.com
	php_flag[display_errors] = on
	php_admin_value[error_log] = /var/log/php5-fpm.\$pool.log
	php_admin_flag[log_errors] = on
	;php_admin_value[memory_limit] = 32M
	_EOF_
}

# Sanity Check - are there four arguments with 4 values?
if [ $# -ne 8 ]; then
	show_usage
fi

# Parse flags
while getopts "hu:d:s:t:" OPTION; do
	case $OPTION in
		h)
			show_usage
		;;
		u)
			UserName=$OPTARG
		;;
		d)
			DocumentRoot=$OPTARG
		;;
		s)
			ServerName=$OPTARG
		;;
		t)
			Platform=$OPTARG
		;;
		*)
			show_usage
		;;
	esac
done

# Additional Check - are user already exist?
UserExists=$(getent passwd $UserName)
if [ "x${UserExists}" = "x" ]; then
	echo "The user '$UserName' does not exist, please add new user first! Aborting..."
	echo "Command: adduser UserName, try ngxvhost -h for more helps"
	exit 0;
fi

# Additional check - is FPM user's pool already exist?
if [ ! -f "/etc/php5/fpm/pool.d/${UserName}.conf" ]; then
	echo "The FPM pool configuration for user ${UserName} doesn't exist, attempting to add new pool configuration..."

	create_fpm_pool_conf > /etc/php5/fpm/pool.d/$UserName.conf
	touch /var/log/php5-fpm_slow.$UserName.log

	# Restart FPM
	service php5-fpm restart
fi

# Additional Check - ensure that Nginx's configuration meets the requirement
if [ ! -d "/etc/nginx/sites-available" ]; then
	echo "It seems that your Nginx installation doesn't meet ngxvhost requirement. Aborting..."
	exit 0;
fi

# Check if vhost already exists.
if [ -f "/etc/nginx/sites-available/${ServerName}.conf" ]; then
	echo "vHost config for ${ServerName} already exists. Aborting..."
	show_usage
else
	# Creates document root
	if [ ! -d $DocumentRoot ]; then 
		mkdir -p $DocumentRoot
		#chown USER:USER $DocumentRoot #POSSIBLE IMPLEMENTATION, new flag -u ?
		chown -R $UserName:$UserName $DocumentRoot
		chmod 755 $DocumentRoot
	fi

	# Ugly hacks for custom Platform-specific configs + Skeleton auto installer.
	case $Platform in
		laravel)
			# create vhost			
			create_laravel_vhost > /etc/nginx/sites-available/${ServerName}.conf

			# TODO: Auto install Laravel framework skeleton
			if [ ! -f "${DocumentRoot}/server.php" ]; then
				echo ""
				echo "Copying Laravel skeleton into document root..."
				echo ""

				# Clone new WordPress files
				git clone https://github.com/laravel/laravel.git $DocumentRoot/	
			fi
		;;

		phalcon)
			# create vhost			
			create_phalcon_vhost > /etc/nginx/sites-available/${ServerName}.conf

			# TODO: Auto install Phalcon PHP framework skeleton
		;;

		wordpress)
			# check WordPress install
			if [ ! -d "${DocumentRoot}/wp-content/plugins" ]; then
				echo ""
				echo "Copying WordPress skeleton into document root..."
				echo ""

				# Clone new WordPress files
				git clone https://github.com/WordPress/WordPress.git $DocumentRoot/
			fi

			# TODO: Pre-install nginx helper plugin
			if [ ! -d "${DocumentRoot}/wp-content/plugins/nginx-helper" ]; then
				echo ""
				echo "Copying Nginx Helper plugin into WordPress install..."
				echo "CAUTION! Please activate after WordPress installation."
				echo ""

				#wget --no-check-certificate https://downloads.wordpress.org/plugin/nginx-helper.1.8.7.zip -O nginx-helper.zip
				#unzip nginx-helper.zip
				#mv nginx-helper $DocumentRoot/wp-content/plugins/
				#rm -f nginx-helper.zip
				git clone https://github.com/rtCamp/nginx-helper.git $DocumentRoot/wp-content/plugins/nginx-helper
			fi

			# create vhost
			create_vhost >> /etc/nginx/sites-available/$ServerName.conf
		;;

		wordpress-ms)
			# check WordPress install
			if [ ! -d "${DocumentRoot}/wp-content/plugins" ]; then
				echo ""
				echo "Installing WordPress skeleton into document root..."
				echo ""

				# Clone new WordPress files
				git clone https://github.com/WordPress/WordPress.git $DocumentRoot/
			fi

			# TODO: Pre-install nginx helper plugin
			if [ ! -d "${DocumentRoot}/wp-content/plugins/nginx-helper" ]; then
				echo ""
				echo "Copying Nginx Helper plugin into WordPress install..."
				echo "CAUTION! Please activate after WordPress installation."
				echo ""

				#wget --no-check-certificate https://downloads.wordpress.org/plugin/nginx-helper.1.8.7.zip -O nginx-helper.zip
				#unzip nginx-helper.zip
				#mv nginx-helper $DocumentRoot/wp-content/plugins/
				#rm -f nginx-helper.zip
				git clone https://github.com/rtCamp/nginx-helper.git $DocumentRoot/wp-content/plugins/nginx-helper

				# Pre-populate blogid map, used by Nginx vhost conf
				mkdir $DocumentRoot/wp-content/uploads/nginx-helper/
				touch $DocumentRoot/wp-content/uploads/nginx-helper/map.conf
			fi

			# prepare vhost header specific to WordPress Multisite
			prepare_wpms_vhost > /etc/nginx/sites-available/$ServerName.conf

			# create vhost
			create_vhost >> /etc/nginx/sites-available/$ServerName.conf
		;;

		*)
			# create vhost			
			create_vhost > /etc/nginx/sites-available/$ServerName.conf

			# create default index file
			create_indexfile >> $DocumentRoot/index.html
			chown $UserName:$UserName $DocumentRoot/index.html
		;;	
	esac

	# Fix docroot ownership
	chown -R $UserName:$UserName $DocumentRoot
	# Fix docroot permission
	find $DocumentRoot -type d -print0 | xargs -0 chmod 755
	find $DocumentRoot -type f -print0 | xargs -0 chmod 644

	# Enable site
	cd /etc/nginx/sites-enabled/
	ln -s /etc/nginx/sites-available/$ServerName.conf $ServerName.conf

	# Reload Nginx
	echo "Reload Nginx configuration..."
	service nginx reload #Optional implementation
	
	if [ "${Platform}" = "wordpress-ms" ]; then
		echo ""
		echo "Note: You're installing Wordpress Multisite, please activate Nginx Helper plugin to work properly."
		echo ""
	fi
fi
