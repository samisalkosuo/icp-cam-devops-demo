#!/usr/bin/env bash

#this script logs to ICP cluster and sets up kubectl, ibmcloud and helm CLI env.
#uses default admin/admin credentials

__icp_ip=$1
if [[ "${__icp_ip}" == "" ]] ; then
    echo "ICP IP not specified."
    echo "Usage $0 <icp_ip>"
    exit 1
fi 

ibmcloud pr login -a https://${__icp_ip}:8443 --skip-ssl-validation -u admin -p admin -c id-mycluster-account
