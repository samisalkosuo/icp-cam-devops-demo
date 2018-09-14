#!/bin/bash

#create CAM volumes using kubectl
#https://www.ibm.com/support/knowledgecenter/en/SS2L37_2.1.0.2/cam_create_pv.html

__nfs_server_ip=$1
if [[ "${__nfs_server_ip}" == "" ]] ; then
    echo "NFS server IP not specified."
    echo "Usage $0 <nfs_server_ip> <nfs_dir> <have you create directories>"
    exit 1
fi 

#create directory to NFS server shared directory
__nfs_dir=$2
if [[ "${__nfs_dir}" == "" ]] ; then
    echo "NFS root directory not specified."
    echo "Usage $0 <nfs_server_ip> <nfs_dir> <have you create directories>"
    exit 1
fi 

__confirmation=$3
if [[ "${__confirmation}" == "" ]] ; then
    echo "Have you created directories in NFS server="
    echo "Usage $0 <nfs_server_ip> <nfs_dir> <have you create directories>"
    exit 1
fi 


#change occurrences of string in file
function changeString {
	if [[ $# -ne 3 ]]; then
    	echo "$FUNCNAME ERROR: Wrong number of arguments. Requires FILE FROMSTRING TOSTRING."
    	return 1
	fi

	local SED_FILE=$1
	local FROMSTRING=$2
	local TOSTRING=$3
	local TMPFILE=$SED_FILE.tmp

	#get file owner and permissions
	local USER=$(stat -c %U $SED_FILE)
	local GROUP=$(stat -c %G $SED_FILE)
	local PERMISSIONS=$(stat -c %a $SED_FILE)

	#escape to and from strings
	FROMSTRINGESC=$(echo $FROMSTRING | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')
	TOSTRINGESC=$(echo $TOSTRING | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')

	sed -e "s/$FROMSTRINGESC/$TOSTRINGESC/g" $SED_FILE  > $TMPFILE && mv $TMPFILE $SED_FILE

  #set original owner and permissions
	chown $USER:$GROUP $SED_FILE
	chmod $PERMISSIONS $SED_FILE
	if [ ! -f $TMPFILE ]; then
	    return 0
 	else
	 	echo "$FUNCNAME ERROR: Something went wrong."
	 	return 2
	fi
}

changeString cam-bpd-pv.yaml /export ${__nfs_dir}
changeString cam-logs-pv.yaml /export ${__nfs_dir}
changeString cam-mongo-pv.yaml /export ${__nfs_dir}
changeString cam-terraform-pv.yaml /export ${__nfs_dir}

changeString cam-bpd-pv.yaml mycluster.icp ${__nfs_server_ip}
changeString cam-logs-pv.yaml mycluster.icp ${__nfs_server_ip}
changeString cam-mongo-pv.yaml mycluster.icp ${__nfs_server_ip}
changeString cam-terraform-pv.yaml mycluster.icp ${__nfs_server_ip}

kubectl create -f ./cam-mongo-pv.yaml
kubectl create -f ./cam-logs-pv.yaml
kubectl create -f ./cam-terraform-pv.yaml
kubectl create -f ./cam-bpd-pv.yaml 
