#!/bin/bash

#install app

__app_download_url=$1

echo "Downloading Docker image from URL: " ${__app_download_url}

wget ${__app_download_url}

filename=$(basename ${__app_download_url})

sudo docker load -i ${filename}

echo "Starting Docker container"
#image name is hardcoded
sudo docker run -d -p 80:9082 -p 443:9443 daytrader7

