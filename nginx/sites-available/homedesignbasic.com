server {
	listen	80; ## listen for ipv4; this line is default and implied
	
	# Make site accessible from world wide.
	server_name homedesignbasic.com www.homedesignbasic.com direct.homedesignbasic.com;

	# Log Settings.
	access_log   /var/log/nginx/homedesignbasic.com.access.log;
	error_log    /var/log/nginx/homedesignbasic.com.error.log;
	
	root /home/masedi/homedesignbasic.com;
	index index.php index.html index.htm;

	# Global directives configuration.
	include /etc/nginx/conf.vhost/block.conf;
	include /etc/nginx/conf.vhost/staticfiles.conf;
	include /etc/nginx/conf.vhost/restrictions.conf;
	
	# Custom Nginx directives
	#include /home/masedi/homedesignbasic.com/.ngxaccess;

	# Vhost directives configuration (WordPress single, multisite, or other default site config. Use only one config).
	#include /etc/nginx/conf.vhost/site_default.conf;
	#include /etc/nginx/conf.vhost/site_wordpress.conf;
	include /etc/nginx/conf.vhost/site_wordpress_cached.conf;
	#include /etc/nginx/conf.vhost/site_wordpress-ms.conf;
	#include /etc/nginx/conf.vhost/site_wordpress-ms_cached.conf;

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
		fastcgi_param SCRIPT_NAME		$fastcgi_script_name;
		
		# Include FastCGI Configs.
		include /etc/nginx/conf.vhost/fastcgi.conf;

		# Uncomment to Enable PHP FastCGI cache.
		include /etc/nginx/conf.vhost/fastcgi_cache.conf;
		
		# Uncomment to enable Nginx proxy cache.
		#include /etc/nginx/conf.vhost/proxy_cache.conf;
	}
	
	## Error page directives configuration.
	#include /etc/nginx/conf.vhost/errorpage.conf;
}

# Redirect database access to PhpMyAdmin
server {
	listen		80;
	server_name	db.homedesignbasic.com;
	return		301 http://$server_name:8082/phpmyadmin/$request_uri;
}

# PhpMyAdmin
server {
	listen 8082;

	server_name db.homedesignbasic.com;
	
	# Global directives configuration.
	include /etc/nginx/conf.vhost/staticfiles.conf;
	include /etc/nginx/conf.vhost/restrictions.conf;

	# PhpMyAdmin directives configuration.
	location /phpmyadmin {
		root /usr/share/nginx/www;
		index index.php index.html index.htm;

		location ~ ^/phpmyadmin/(.+\.php)$ {
			root /usr/share/nginx/www;

			try_files $uri =404;
			fastcgi_split_path_info ^(.+\.php)(/.+)$;
			#NOTE: You should have "cgi.fix_pathinfo = 0;" in php.ini
			
			fastcgi_index index.php;
			fastcgi_pass unix:/var/run/php5-fpm.masedi.sock;
			
			# Include FastCGI Params.
			include /etc/nginx/fastcgi_params;
			
			# Overwrite FastCGI Params here.
			fastcgi_param	SCRIPT_FILENAME	$document_root$fastcgi_script_name;
			fastcgi_param	SCRIPT_NAME		$fastcgi_script_name;
			
			# Include FastCGI Configs.
			include /etc/nginx/conf.vhost/fastcgi.conf;

			# Uncomment to Enable PHP FastCGI cache.
			include /etc/nginx/conf.vhost/fastcgi_cache.conf;
			
			# Uncomment to enable Nginx proxy cache.
			#include /etc/nginx/conf.vhost/proxy_cache.conf;
		}

		location ~* ^/phpmyadmin/(.+\.(jpg|jpeg|gif|css|png|js|ico|html|xml|txt)) {
			root /usr/share/nginx/www;
		}
	}

	location /phpMyAdmin {
		rewrite ^/* /phpmyadmin last;
	}
}
