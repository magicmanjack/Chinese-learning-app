#!/bin/bash

apt-get update
apt-get install -y apache2 libapache2-mod-php php php-mysql

cp /vagrant/webserver/website.conf /etc/apache2/sites-available/
cp -r /vagrant/webserver/chinese-tool-site /var/www

mkdir /etc/systemd/system/apache2.service.d

echo "[Service]" | sudo tee -a /etc/systemd/system/apache2.service.d/override.conf > /dev/null
echo "Environment='DB_NAME=testdb'" | sudo tee -a /etc/systemd/system/apache2.service.d/override.conf > /dev/null
echo "Environment='DB_HOSTNAME=192.168.2.12'" | sudo tee -a /etc/systemd/system/apache2.service.d/override.conf > /dev/null
echo "Environment='API_HOSTNAME=192.168.2.13'" | sudo tee -a /etc/systemd/system/apache2.service.d/override.conf > /dev/null
echo "Environment='DB_USERNAME=testuser'" | sudo tee -a /etc/systemd/system/apache2.service.d/override.conf > /dev/null
echo "Environment='DB_PASSWORD=testuserpassword'" | sudo tee -a /etc/systemd/system/apache2.service.d/override.conf > /dev/null
systemctl daemon-reload

a2ensite website
a2dissite 000-default

service apache2 restart