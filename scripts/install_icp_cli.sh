#!/usr/bin/env bash

#this script has been tested using ICP 3.1.1

set -e

__icp_ip=$1
if [[ "${__icp_ip}" == "" ]] ; then
    echo "ICP IP and port not specified."
    echo "Usage $0 <icp__ip:port>"
    exit 1
fi 

__install_dir=/usr/local/bin

echo "install cloudctl..."
curl -kLo cloudctl-linux-amd64-3.1.1-973 https://${__icp_ip}/api/cli/cloudctl-linux-amd64
__bin=$(ls -1 cloudctl*)
chmod 755 ${__bin}
mv ${__bin} ${__install_dir}/cloudctl

echo "install kubectl..."
curl -kLo kubectl-linux-amd64-v1.11.1 https://${__icp_ip}/api/cli/kubectl-linux-amd64
__bin=$(ls -1 kubectl*)
chmod 755 ${__bin}
mv ${__bin} ${__install_dir}/kubectl

echo "install helm..."
curl -kLo helm-linux-amd64-v2.9.1.tar.gz https://${__icp_ip}/api/cli/helm-linux-amd64.tar.gz
__bin=$(ls -1 helm*)
tar -xf ${__bin}
mv linux-amd64/helm ${__install_dir}/helm
rm -rf linux-amd64
rm -f ${__bin}

echo "install istioctl..."
curl -kLo istioctl-linux-amd64-v1.0.2 https://${__icp_ip}/api/cli/istioctl-linux-amd64
__bin=$(ls -1 istio*)
chmod 755 ${__bin}
mv ${__bin} ${__install_dir}/istioctl

echo "install calicoctl..."
curl -kLo calicoctl-linux-amd64-v3.1.3.tar.gz https://${__icp_ip}/api/cli/calicoctl-linux-amd64.tar.gz
__bin=$(ls -1 calico*)
chmod 755 ${__bin}
mv ${__bin} ${__install_dir}/calicoctl
