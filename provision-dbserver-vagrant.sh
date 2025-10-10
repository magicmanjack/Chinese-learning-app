#!/bin/bash

apt-get update

#TODO: root user name and password. Insecure?
export MYSQL_PWD='testrootpassword'

#prepopulate debconf database with answers to questions.
echo "mysql-server mysql-server/root_password password $MYSQL_PWD" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password $MYSQL_PWD" | debconf-set-selections

apt-get -y install mysql-server

service mysql start

echo "CREATE DATABASE testdb;" | mysql

echo "CREATE USER 'testuser'@'%' IDENTIFIED BY 'testuserpassword';" | mysql

echo "GRANT ALL PRIVILEGES ON testdb.* TO 'testuser'@'%';" | mysql

#Changing mysql config so that it listens to incoming connections from any port.
sed -i'' -e '/bind-address/s/127.0.0.1/0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf

#Affect changes.
service mysql restart

export MYSQL_PWD='testuserpassword'
#provision database
cat /vagrant/db/setup-database.sql | mysql -u testuser testdb

#create testuser with password 
wget -O /dev/null --post-data="username=testuser&password=testuserpassword&confirm_password=testuserpassword" 192.168.2.11:80/register.php

# and add words to account.
cat /vagrant/db/test-populate.sql | mysql -u testuser testdb
