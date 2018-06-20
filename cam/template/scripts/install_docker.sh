#!/bin/bash

#get docker install script
curl -fsSL get.docker.com -o get-docker.sh

#execute install script
sudo sh get-docker.sh

#add current user to docker group
sudo usermod -aG docker $(whoami)
