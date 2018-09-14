#!/usr/bin/env bash

#this script creates NFS CAM directories for ICP,CAM DevOps demo


set -e

#create for NFS directories
__nfs_dir=/nfs

function createDir {
    __dir=${__nfs_dir}/$1
    mkdir -p ${__dir}
    chmod 777 ${__dir}
}

createDir CAM_db
createDir CAM_logs
createDir CAM_terraform
createDir CAM_BPD_appdata

echo "${__nfs_dir}/CAM_logs *(rw,nohide,insecure,no_subtree_check,async,no_root_squash)" >> /etc/exports
echo "${__nfs_dir}/CAM_db *(rw,nohide,insecure,no_subtree_check,async,no_root_squash)" >> /etc/exports
echo "${__nfs_dir}/CAM_terraform *(rw,nohide,insecure,no_subtree_check,async,no_root_squash)" >> /etc/exports
echo "${__nfs_dir}/CAM_BPD_appdata *(rw,nohide,insecure,no_subtree_check,async,no_root_squash)" >> /etc/exports

systemctl restart nfs-server
