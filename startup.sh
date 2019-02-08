#!/bin/bash
apt-get update
apt-get upgrade -y
# Install Apache2
apt-get install apache2 -y
# Install MySQL Server
apt-get install -o Dpkg::Options::="--force-confold" mysql-server -y
# Start MySQL service
systemctl start mysql
# Enable MySQL service on boot
systemctl enable mysql
# Install WordPress
apt-get install wordpress

#Store external IP as a variable
hostname="$(curl ifconfig.me)"

# If wordpress config exists (which it wont), then create file and print configuration.
if [ ! -e "/etc/apache2/sites-available/wordpress.conf" ]; then
  echo "Alias /blog /usr/share/wordpress
        <Directory /usr/share/wordpress>
            Options FollowSymLinks
            AllowOverride Limit Options FileInfo
            DirectoryIndex index.php
            Order allow,deny
            Allow from all
        </Directory>
        <Directory /usr/share/wordpress/wp-content>
            Options FollowSymLinks
            Order allow,deny
            Allow from all
        </Directory>" >> "/etc/apache2/sites-available/wordpress.conf" 
fi 

# Enable WordPress Site
a2ensite wordpress
# Restart Apache
systemctl restart apache2.service

# If WordPress DB Config exists (which it also wont), create the file and print contents.
if [ ! -e "/etc/wordpress/config-$hostname.php" ]; then
  echo "<?php
define('DB_NAME', 'wordpress');
define('DB_USER', 'wordpress');
define('DB_PASSWORD', '52854fd6ed9a2fa158e17e959aede4ea');
define('DB_HOST', 'localhost');
define('WP_CONTENT_DIR', '/usr/share/wordpress/wp-content');
?>" >> "/etc/wordpress/config-$hostname.php"
fi

# If temp db file exists (which also definitely wont), create the file and print the contents.
if [ ! -e "/etc/wordpress/wordpress.sql" ]; then
  echo "CREATE DATABASE wordpress; GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER ON wordpress.* TO 'wordpress'@'%' IDENTIFIED BY '52854fd6ed9a2fa158e17e959aede4ea'; FLUSH PRIVILEGES;" >> "/etc/wordpress/wordpress.sql"
fi

cat /etc/wordpress/wordpress.sql | mysql --defaults-extra-file=/etc/mysql/debian.cnf
systemctl restart mysql.service