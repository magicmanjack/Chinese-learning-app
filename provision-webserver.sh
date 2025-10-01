#!/bin/bash

sudo apt-get update
sudo apt-get install -y apache2 libapache2-mod-php php php-mysql

sudo mv webserver/website.conf /etc/apache2/sites-available/
sudo mv webserver/chinese-tool-site /var/www/
rm webserver
sudo a2ensite website
sudo a2dissite 000-default

sudo service apache2 restart