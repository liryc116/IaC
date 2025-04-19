#!/bin/bash -eu

sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get -y update
sudo apt-get -y install docker-ce
usermod -aG docker ${SSH_USERNAME}

mv /tmp/docker.service /lib/systemd/system/docker.service
chmod 644 /lib/systemd/system/docker.service
systemctl daemon-reload
systemctl restart docker
