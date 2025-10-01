#!/bin/bash

apt-get update

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

nvm install 22

mkdir api_server

cd api_server

cp /vagrant/api/apiserver.js .

npm init -y

npm install express

npm install pinyin

node apiserver.js &