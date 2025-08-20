#!/bin/bash

apt-get update

#TODO: root user name and password. Insecure?
export MYSQL_PWD='insecure_mysqlroot_pw'
#export MYSQL_USER='webuser'

#prepopulate debconf database with answers to questions.
echo "mysql-server mysql-server/root_password password $MYSQL_PWD" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password $MYSQL_PWD" | debconf-set-selections

apt-get -y install mysql-server

service mysql start

echo "CREATE DATABASE test;" | mysql

echo "CREATE USER 'webuser'@'%' IDENTIFIED BY 'db_tobechanged'" | mysql

echo "GRANT ALL PRIVILEGES ON test.* TO 'webuser'@'%';" | mysql

export MYSQL_PWD='db_tobechanged'

cat /vagrant/setup-database.sql | mysql -u webuser test

#Changing mysql config so that it listens to incoming connections from any port.
sed -i'' -e '/bind-address/s/127.0.0.1/0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf

#Affect changes.
service mysql restart