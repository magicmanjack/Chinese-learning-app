# Chinese-learning-app
An web application that speeds up a Chinese language learners experience. The goal of the tool is to present learners with practice challenges to rapidly increase their rate of learning.

## Attributions
This project uses the publicly available node.js pinyin module to serve pinyin suggestions: https://pinyin.js.org/en-US



## Inner workings
The application is spread accross 3 servers:
1. A web server to serve the website content. (Apache2 and php)
2. A database to store user information. (MySQL)
3. An API server which provides extra services such as pinyin suggestions. (Node.js and Express)

Vagrant virtual machines are used to develope the app as they can host all three servers locally.

## To get started with deploying the application
In order to get the three servers up and running locally for testing, you must first install vagrant. (information at https://developer.hashicorp.com/vagrant/install). Then you can start the servers by a simple shell command in the project root directory:
```
vagrant up
```
This will take a small while. Once the command has finished, you can test if the app is working by navigating to (http://127.0.0.1:8080/) in your web browser. The sites login page should appear.

## Extending functionality
To make permanent changes to the project that happen at boot time, add the bash script commands to one of corrosponding bash scripts:
- provision-apiserver.sh
- provision-dbserver.sh
- provision-webserver.sh

Where apiserver, dbserver, and webserver are the names of the vagrant machines. To affect changes, restart the corrosponding vagrant vm. E.g:
```
vagrant destroy dbserver
vagrant up dbserver
```