## Wordpress Multisite Mapping for Nginx (Requires Nginx Helper plugin)
map $http_host $blogid {
	default		0;
#	include		/home/masedi/Webs/sample-site.com/wp-content/plugins/nginx-helper/map.conf;
}

server {
	listen   80; ## listen for ipv4; this line is default and implied

	# Make site accessible from world wide
	server_name sample-site.com *.sample-site.com;

	root /home/masedi/Webs/sample-site.com;
	index index.php index.html index.htm;

	# Log
	access_log   /var/log/nginx/sample-site.com.access.log;
	error_log    /var/log/nginx/sample-site.com.error.log;

	# Global directives configuration.
	include /etc/nginx/conf.vhost/block.conf;
	include /etc/nginx/conf.vhost/staticfiles.conf;
	include /etc/nginx/conf.vhost/restrictions.conf;
	
	# Custom Nginx directives
	#include /home/masedi/Webs/sample-site.com/.ngxaccess;

	# Vhost directives configuration (WordPress single, multisite, or other default site config. Use only one config).
	#include /etc/nginx/conf.vhost/site_wordpress-ms.conf;
	include /etc/nginx/conf.vhost/site_wordpress-ms_cached.conf;

	# Directive to avoid php readfile() for WordPress Multisite.
	location ^~ /blogs.dir {
		internal;
		alias /home/masedi/Webs/sample-site.com/wp-content/blogs.dir;
		access_log off;
		log_not_found off;
		expires max;
	}

	# Pass all .php files onto a php-fpm/php-fcgi server.
	location ~ \.php$ {
		try_files $uri =404;
		
		fastcgi_split_path_info ^(.+\.php)(/.+)$;
		#NOTE: You should have "cgi.fix_pathinfo = 0;" in php.ini
		
		fastcgi_index index.php;
		fastcgi_pass unix:/var/run/php5-fpm.masedi.sock;
		
		# Include FastCGI Params.
		include /etc/nginx/fastcgi_params;
		
		# Overwrite FastCGI Params here.
		fastcgi_param SCRIPT_FILENAME	$document_root$fastcgi_script_name;
		fastcgi_param SCRIPT_NAME		$fastcgi_script_name;
		
		# Include FastCGI Configs.
		include /etc/nginx/conf.vhost/fastcgi.conf;

		# Uncomment to Enable PHP FastCGI cache.
		include /etc/nginx/conf.vhost/fastcgi_cache.conf;
	}
}
