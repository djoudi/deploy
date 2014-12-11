# Wordpress Multisite Mapping for Nginx.
map $http_host $blogid {
	default		0;
	#include	/home/masedi/aweshomedesign.com/wp-content/plugins/nginx-helper/map.conf;
}

server {
	listen   80; ## listen for ipv4; this line is default and implied
	#listen   [::]:80 default ipv6only=on; ## listen for ipv6

	# Make site accessible from world wide
	server_name aweshomedesign.com www.aweshomedesign.com direct.aweshomedesign.com;

	root /home/masedi/Webs/aweshomedesign.com;
	index index.php index.html index.htm;

	# Log
	access_log   /var/log/nginx/aweshomedesign.com.access.log;
	error_log    /var/log/nginx/aweshomedesign.com.error.log;

	## Global directives configuration.
	include /etc/nginx/conf.vhost/block.conf;
	include /etc/nginx/conf.vhost/staticfiles.conf;
	include /etc/nginx/conf.vhost/restrictions.conf;

	## Vhost directives configuration (WordPress single, multisite, or other default site config. Use only one config).
	#include /etc/nginx/conf.vhost/site_default.conf;
	#include /etc/nginx/conf.vhost/site_wordpress.conf;
	include /etc/nginx/conf.vhost/site_wordpress_cached.conf;

	## Pass all .php files onto a php-fpm/php-fcgi server.
	location ~ \.php$ {
		#try_files $uri =404;
		try_files $uri /index.php;
		
		fastcgi_split_path_info ^(.+\.php)(/.+)$;
		#NOTE: You should have "cgi.fix_pathinfo = 0;" in php.ini
		
		fastcgi_index index.php;
		fastcgi_pass unix:/var/run/php5-fpm.masedi.sock;
		
		# Include FastCGI Params.
		include /etc/nginx/fastcgi_params;
		
		# Overwrite FastCGI Params here.
		#fastcgi_param SCRIPT_FILENAME	$document_root$fastcgi_script_name;
		fastcgi_param SCRIPT_NAME	$fastcgi_script_name;
		
		# Include FastCGI Configs.
		include /etc/nginx/conf.vhost/fastcgi.conf;

		# Uncomment to Enable PHP FastCGI cache.
		include /etc/nginx/conf.vhost/fastcgi_cache.conf;
		
		# Uncomment to enable Nginx proxy cache.
		#include /etc/nginx/conf.vhost/proxy_cache.conf;
	}
}

# Redirect database access to PhpMyAdmin
server {
	listen		80;
	server_name	db.aweshomedesign.com;
	return		301 http://$server_name:8082/phpmyadmin/$request_uri;
}

# PhpMyAdmin
server {
	listen 127.0.0.1:8082;

	server_name db.aweshomedesign.com;
	
	# Global directives configuration.
	include /etc/nginx/conf.vhost/staticfiles.conf;
	include /etc/nginx/conf.vhost/restrictions.conf;

	# PhpMyAdmin directives configuration.
	location /phpmyadmin {
		root /usr/share/phpmyadmin;
		index index.php index.html index.htm;

		location ~ ^/phpmyadmin/(.+\.php)$ {
			root /usr/share/phpmyadmin;

			try_files $uri =404;
			fastcgi_split_path_info ^(.+\.php)(/.+)$;
			#NOTE: You should have "cgi.fix_pathinfo = 0;" in php.ini
			
			fastcgi_index index.php;
			fastcgi_pass unix:/var/run/php5-fpm.masedi.sock;
			
			# Include FastCGI Params.
			include /etc/nginx/fastcgi_params;
			
			# Overwrite FastCGI Params here.
			#fastcgi_param	SCRIPT_FILENAME	$document_root$fastcgi_script_name;
			fastcgi_param	SCRIPT_NAME	$fastcgi_script_name;
			
			# Include FastCGI Configs.
			include /etc/nginx/conf.vhost/fastcgi.conf;

			# Uncomment to Enable PHP FastCGI cache.
			include /etc/nginx/conf.vhost/fastcgi_cache.conf;
		}

		location ~* ^/phpmyadmin/(.+\.(jpg|jpeg|gif|css|png|js|ico|html|xml|txt)) {
			root /usr/share/phpmyadmin;
		}
	}

	location /phpMyAdmin {
		rewrite ^/* /phpmyadmin last;
	}
}
