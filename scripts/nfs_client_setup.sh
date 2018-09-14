#!/usr/bin/env bash

#this script installs and tests NFS client for ICP,CAM DevOps demo
#based on https://help.ubuntu.com/community/SettingUpNFSHowTo

__nfs_server=$1
if [[ "${__nfs_server}" == "" ]] ; then
    echo "NFS server not specified."
    echo "Usage $0 <nfs_server>"
    echo "For example: $0 10.31.10.123"
    exit 1
fi 

set -e

apt-get install nfs-common 

__nfs_test_dir=/tmp/nfs_test
mkdir -p ${__nfs_test_dir}
mount -t nfs -o proto=tcp,port=2049 ${__nfs_server}:/nfs ${__nfs_test_dir}
touch ${__nfs_test_dir}/test_file_$(hostname)

echo "Check if test_file exists in NFS server."

