#!/bin/bash

apt-get update
apt-get install -y apache2 libapache2-mod-php php php-mysql

cp /vagrant/webserver/website.conf /etc/apache2/sites-available/

a2ensite website
a2dissite 000-default

service apache2 restart