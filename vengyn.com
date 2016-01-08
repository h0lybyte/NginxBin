		map $http_upgrade $connection_upgrade {
			default upgrade;
			'' close;
		}
		server {
			listen 443 default_server;
			
			server_name panel.vengyn.com;

			add_header Strict-Transport-Security "max-age=31536000; includeSubdomains";
			ssl on;
			ssl_stapling on;
			ssl_stapling_verify on;
			resolver 8.8.8.8 8.8.4.4 [2001:4860:4860::8888] [2001:4860:4860::8844];
			ssl_certificate /var/ssl/ev/ssl-bundle.crt;
			ssl_certificate_key /var/ssl/ev/server.key;
			ssl_session_cache shared:SSL:2m;
			ssl_protocols TLSv1.2;
			ssl_ciphers 'ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!SRP:!DSS';
			ssl_dhparam /var/ssl/ev/dhparams.pem;
			ssl_prefer_server_ciphers on;
			
				access_log off;
				error_log off;
				root /var/www;
				index index.php index.html;
				#server_name kbve.com;
				
				error_page  405     =200 $uri;
                                #if ($http_referrer ~* \.ml$) {
                                #        return 403;
                                #}

			
				location ~ \.php$ {
						if (!-f $request_filename) {
								return 404;
						}
						proxy_set_header X-Real-IP $remote_addr;
						proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
						proxy_set_header Host $host;
						proxy_pass http://127.0.0.1:6081;
				}
				location ~ /\.(ht|git) {
						deny all;
				}
				
				location /c/ {
					try_files $uri $uri/ index.php/$uri;
				}
				
		#	 location ~* \.(html|css|js|xml|json|min.js)$
		#			{
		#				gzip_static on;
		#				expires max;
		#				add_header Cache-Control public;
		#				add_header  Last-Modified "";
		#				add_header  ETag "";
		#			}
			
				
				
			 location ~ ^/(assets|data)/ {
			 
				location ~* \.(html|css|js|xml|json)$
					{
						gzip_static on;
						
					}
				expires max;
				add_header Cache-Control public;
				add_header  Last-Modified "";
				add_header  ETag "";
					
			}
			
				
		
				
		}
