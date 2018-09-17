#!/usr/bin/env bash

# Installs OpenJDK8, Jenkins and does some configuration for the demo

__icp_console_ip=$1
if [[ "${__icp_console_ip}" == "" ]] ; then
    echo "ICP console IP not specified."
    echo "Usage $0 <icp_console_ip>"
    exit 1
fi 

# install java
apt-get update
apt-get -y install default-jdk

# install jenkins
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | apt-key add -
sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
apt-get update
apt-get -y install jenkins

# Add jenkins user to docker users
usermod -aG docker jenkins
systemctl stop jenkins && systemctl start jenkins

# Install ICP CLI plugin for Jenkins user
su - jenkins -c "curl -k -O https://${__icp_console_ip}:8443/api/cli/icp-linux-amd64; ibmcloud  plugin install icp-linux-amd64"

