#!/bin/bash

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

nvm install 22

cd api

npm init -y

npm install express

npm install pinyin

echo "$(which node) /home/ubuntu/api/apiserver.js" > apiserver.sh
sudo chmod 764 apiserver.sh

#Start a service which runs the api server.
cat << EOF >> apiserver.service
[Unit]
Description=API server

[Service]
ExecStart=/bin/bash /home/ubuntu/api/apiserver.sh
Restart=always
EOF

sudo mv apiserver.service /etc/systemd/system/

sudo systemctl daemon-reload
sudo systemctl start apiserver


