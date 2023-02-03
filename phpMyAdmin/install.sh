
echo -e "${YELLOW}default phpMyAdmin path /phpMyAdmin...${NC}"

PHPMYADMIN=$(dpkg-query -W -f='${Status}' phpmyadmin 2>/dev/null | grep -c "ok installed")
  if [ ${PHPMYADMIN} -eq 0 ]; then echo -e "${YELLOW}Installing phpmyadmin${NC}" && apt-get install phpmyadmin --yes;
    elif [ ${PHPMYADMIN} -eq 1 ]; then echo -e "${GREEN}phpmyadmin is installed!${NC}"
  fi;
  
# apt-get install fail2ban  --yes;
# apt-get install apache2 php5  --yes;
# apt-get install php5-curl --yes;
# apt-get install mysql-server --yes;


PHPVersion=""
if [ -f "$Root_Path/server/php/52/bin/php" ];then
	PHPVersion="52"
fi
if [ -f "$Root_Path/server/php/53/bin/php" ];then
	PHPVersion="53"
fi
if [ -f "$Root_Path/server/php/54/bin/php" ];then
	PHPVersion="54"
fi
if [ -f "$Root_Path/server/php/55/bin/php" ];then
	PHPVersion="55"
fi
if [ -f "$Root_Path/server/php/56/bin/php" ];then
	PHPVersion="56"
fi
if [ -f "$Root_Path/server/php/70/bin/php" ];then
	PHPVersion="70"
fi
if [ -f "$Root_Path/server/php/71/bin/php" ];then
	PHPVersion="71"
fi
if [ -f "$Root_Path/server/php/72/bin/php" ];then
	PHPVersion="72"
fi



#========================================================================
#            phpMyAdmin default NGINX configuration
#========================================================================


#sudo nano /etc/nginx/sites-enabled/default
PHPVersion='7.2m'

cat >>/etc/nginx/nginx.conf<< EOL
# phpMyAdmin default NGINX configuration
location /phpmyadmin {
	   root /usr/share/;
	   index index.php index.html index.htm;
	   location ~ ^/phpmyadmin/(.+\.php)$ {
			   try_files $uri =404;
			   root /usr/share/;
			   fastcgi_pass unix:/run/php/php${PHPVersion}-fpm.sock;
			   fastcgi_index index.php;
			   fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
			   include /etc/nginx/fastcgi_params;
	   }
	   location ~* ^/phpmyadmin/(.+\.(jpg|jpeg|gif|css|png|js|ico|html|xml|txt))$ {
			   root /usr/share/;
	   }
}

EOL

sudo nginx -t
sudo systemctl restart nginx



#========================================================================
#            phpMyAdmin default Apache configuration
#========================================================================
#   phpmyadmin default path

APACHE_CONF='/etc/phpmyadmin/apache.conf'
cat >>${APACHE_CONF}<< EOL
# phpMyAdmin default Apache configuration

Alias /phpMyAdmin /usr/share/phpmyadmin

<Directory /usr/share/phpmyadmin>
    Options FollowSymLinks
    DirectoryIndex index.php

    <IfModule mod_php5.c>
        <IfModule mod_mime.c>
            AddType application/x-httpd-php .php
        </IfModule>
        <FilesMatch ".+\.php$">
            SetHandler application/x-httpd-php
        </FilesMatch>

        php_flag magic_quotes_gpc Off
        php_flag track_vars On
        php_flag register_globals Off
        php_admin_flag allow_url_fopen Off
        php_value include_path .
        php_admin_value upload_tmp_dir /var/lib/phpmyadmin/tmp
        php_admin_value open_basedir /usr/share/phpmyadmin/:/etc/phpmyadmin/:/var/lib/phpmyadmin/:/usr/share/php/php-gettext/:/usr/share/javascript/:/usr/share/php/tcpdf/
    </IfModule>

</Directory>

# Authorize for setup
<Directory /usr/share/phpmyadmin/setup>
    <IfModule mod_authz_core.c>
        <IfModule mod_authn_file.c>
            AuthType Basic
            AuthName "phpMyAdmin Setup"
            AuthUserFile /etc/phpmyadmin/htpasswd.setup
        </IfModule>
        Require valid-user
    </IfModule>
</Directory>

# Disallow web access to directories that don't need it
<Directory /usr/share/phpmyadmin/libraries>
    Require all denied
</Directory>
<Directory /usr/share/phpmyadmin/setup/lib>
    Require all denied
</Directory>
EOL

echo -en "${GREEN}Was succesfully!\n phpMyAdmin path is: /phpMyAdmin (i.e.: yourwebsite.com/phpMyAdmin)${NC}";;



