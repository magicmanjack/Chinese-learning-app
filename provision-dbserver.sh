#!/bin/bash

apt-get update

#TODO: root user name and password. Insecure?
export MYSQL_PWD='insecure_mysqlroot_pw'

#prepopulate debconf database with answers to questions.
echo "mysql-server mysql-server/root_password password $MYSQL_PWD" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password $MYSQL_PWD" | debconf-set-selections

apt-get -y install mysql-server

service mysql start

echo "CREATE DATABASE test;" | mysql

echo "CREATE USER 'webuser'@'%' IDENTIFIED BY 'aaftwup123!';" | mysql

echo "GRANT ALL PRIVILEGES ON test.* TO 'webuser'@'%';" | mysql

#Changing mysql config so that it listens to incoming connections from any port.
sed -i'' -e '/bind-address/s/127.0.0.1/0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf

#Affect changes.
service mysql restart

export MYSQL_PWD='aaftwup123!'
#provision database
cat /vagrant/setup-database.sql | mysql -u webuser test

#create testuser with password 
wget -O /dev/null --post-data="username=testuser&password=testuser&confirm_password=testuser" 192.168.2.11:80/register.php

# and add words to account.
cat /vagrant/test-populate.sql | mysql -u webuser test
