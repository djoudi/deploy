server {
	listen	80; ## listen for ipv4; this line is default and implied
	#listen   [::]:8080 default ipv6only=on; ## listen for ipv6
	
	## Make site accessible from world wide.
	server_name wallmuraldepot.com www.wallmuraldepot.com direct.wallmuraldepot.com;

	## Log Settings.
	access_log   /var/log/nginx/wallmuraldepot.com.access.log;
	error_log    /var/log/nginx/wallmuraldepot.com.error.log;
	
	root /home/masedi/wallmuraldepot.com;
	index index.php index.html index.htm;

	## Global directives configuration.
	#include /etc/nginx/conf.vhost/block.conf;
	include /etc/nginx/conf.vhost/staticfiles.conf;
	include /etc/nginx/conf.vhost/restrictions.conf;

	## Vhost directives configuration (WordPress single, multisite, or other default site config. Use only one config).
	#include /etc/nginx/conf.vhost/site_default.conf;
	#include /etc/nginx/conf.vhost/site_wordpress.conf;
	include /etc/nginx/conf.vhost/site_wordpress_cached.conf;
	#include /etc/nginx/conf.vhost/site_wordpress-ms.conf;
	#include /etc/nginx/conf.vhost/site_wordpress-ms_cached.conf;

	## Pass all .php files onto a php-fpm/php-fcgi server.
	location ~ \.php$ {
		# Zero-day exploit defense.
		# http://forum.nginx.org/read.php?2,88845,page=3
		# Won't work properly (404 error) if the file is not stored on this server, which is entirely possible with php-fpm/php-fcgi.
		# Comment the 'try_files' line out if you set up php-fpm/php-fcgi on another machine.  And then cross your fingers that you won't get hacked.
		try_files $uri =404;
		
		fastcgi_split_path_info ^(.+\.php)(/.+)$;
		#NOTE: You should have "cgi.fix_pathinfo = 0;" in php.ini
		
		fastcgi_index index.php;
		fastcgi_pass unix:/var/run/php5-fpm.masedi.sock;
		
		# Include FastCGI Params.
		include /etc/nginx/fastcgi_params;
		
		# Overwrite FastCGI Params here.
		#fastcgi_param SCRIPT_FILENAME	$document_root$fastcgi_script_name;
		fastcgi_param SCRIPT_NAME		$fastcgi_script_name;
		
		# Include FastCGI Configs.
		include /etc/nginx/conf.vhost/fastcgi.conf;

		# Uncomment to Enable PHP FastCGI cache.
		include /etc/nginx/conf.vhost/fastcgi_cache.conf;
	}
}

# PhpMyAdmin
server {
	listen 127.0.0.1:8082;

	server_name db.wallmuraldepot.com;
	
	# Global directives configuration.
	include /etc/nginx/conf.vhost/staticfiles.conf;
	include /etc/nginx/conf.vhost/restrictions.conf;

	# PhpMyAdmin directives configuration.
	location /phpmyadmin {
		root /usr/share/nginx/www/;
		index index.php index.html index.htm;

		location ~ ^/phpmyadmin/(.+\.php)$ {
			root /usr/share/nginx/www/;

			try_files $uri =404;
			fastcgi_split_path_info ^(.+\.php)(/.+)$;
			#NOTE: You should have "cgi.fix_pathinfo = 0;" in php.ini
			
			fastcgi_index index.php;
			fastcgi_pass unix:/var/run/php5-fpm.masedi.sock;
			
			# Include FastCGI Params.
			include /etc/nginx/fastcgi_params;
			
			# Overwrite FastCGI Params here.
			#fastcgi_param	SCRIPT_FILENAME	$document_root$fastcgi_script_name;
			fastcgi_param	SCRIPT_NAME		$fastcgi_script_name;
			
			# Include FastCGI Configs.
			include /etc/nginx/conf.vhost/fastcgi.conf;

			# Uncomment to Enable PHP FastCGI cache.
			#include /etc/nginx/conf.vhost/fastcgi_cache.conf;
		}

		location ~* ^/phpmyadmin/(.+\.(jpg|jpeg|gif|css|png|js|ico|html|xml|txt)) {
			root /usr/share/nginx/www/;
		}
	}

	location /phpMyAdmin {
		rewrite ^/* /phpmyadmin last;
	}
}