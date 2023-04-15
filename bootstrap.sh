#!/usr/bin/env bash
sudo apt-get update
sudo apt-get install -y apache2 apache2-utils
sudo chown www-data:www-data /var/www/html/ -R
sudo echo "ServerName localhost" > /etc/apache2/conf-available/servername.conf
sudo a2enconf servername.conf
sudo systemctl reload apache2

sudo apt-get install -y mariadb-server mariadb-client
sudo apt-get install php7.4 libapache2-mod-php7.4 php7.4-mysql php-common php7.4-cli php7.4-common php7.4-json php7.4-opcache php7.4-readline

sudo apt-get install php7.4-fpm
sudo a2dismod php7.4
sudo a2enmod proxy_fcgi setenvif
sudo a2enconf php7.4-fpm

if ! [ -L /etc/php/7.4/fpm ]; then
   sudo rm -f /etc/php/7.4/fpm/php.ini
   sudo ln -fs /vagrant/configs/etc/php/7.4/fpm/php.ini /etc/php/7.4/fpm/php.ini
fi

sudo apt-get install -y php-bcmath
sudo systemctl restart php7.4-fpm
sudo systemctl restart apache2
sudo apache2ctl configtest

sudo a2enmod rewrite
sudo systemctl restart apache2

if ! [ -L /var/www ]; then
    sudo rm -rf /var/www/html
    sudo ln -fs /vagrant/sites /var/www/html
fi

sudo a2dissite 000-default.conf
sudo systemctl restart apache2

# if ! [ -L /etc/apache2/sites-available ]; then
#     sudo rm -rf /etc/apache2/sites-available
#     sudo ln -fs /vagrant/etc/apache2/sites-available /etc/apache2/sites-available
# fi

apt-get install -y npm
apt-get install -y composer

root_password=teamhrmo2019
# Make sure that NOBODY can access the server without a password
sudo mysql -e "DROP USER IF EXISTS 'admin'@'localhost'"
sudo mysql -e "CREATE USER admin@localhost IDENTIFIED BY '$root_password'"
# sudo mysql -e "UPDATE mysql.user SET Password = PASSWORD('vagrant') WHERE User = 'root'"
sudo mysql -e "GRANT ALL PRIVILEGES ON *.* to admin@localhost WITH GRANT OPTION"
# Kill the anonymous users
sudo mysql -e "DROP USER IF EXISTS ''@'localhost'"
# Because our hostname varies we'll use some Bash magic here.
sudo mysql -e "DROP USER IF EXISTS ''@'$(hostname)'"
# Kill off the demo database
sudo mysql -e "DROP DATABASE IF EXISTS test"
# Make our changes take effect
sudo mysql -e "FLUSH PRIVILEGES"

