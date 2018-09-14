#!/usr/bin/env bash

#this script install NFS server for ICP,CAM DevOps demo
#based on https://help.ubuntu.com/community/SettingUpNFSHowTo


__network_range=$1
if [[ "${__network_range}" == "" ]] ; then
    echo "Network range not specified."
    echo "Usage $0 <network_range>"
    echo "For example: $0 10.31.10.0/24"
    exit 1
fi 

apt-get install nfs-kernel-server

set -e

#directory for NFS directories
__nfs_dir=/nfs
mkdir -p ${__nfs_dir}
chmod 777 ${__nfs_dir}
echo "${__nfs_dir} ${__network_range}(rw,sync,no_root_squash,no_all_squash)" >> /etc/exports
systemctl restart nfs-server

echo "NFS directory ${__nfs_dir} created and shared."
