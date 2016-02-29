#!/bin/bash

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# For Check_Is_Root_Account(), Echo_Color()
. include/echo_color.sh
. include/common.sh
. include/network.sh
. include/path.sh

# Check whether the logon user is a root account?
Check_Is_Root_Account

cur_dir=$(pwd)

. version.sh
. config.sh

# Process ${MY_CLUSTER_DIR}_DIR
if [[ -z "${MY_CLUSTER_DIR}" || "${MY_CLUSTER_DIR}" = "../" ]]; then
    MY_CLUSTER_DIR="${cur_dir}/../"
else
    if [ "${MY_CLUSTER_DIR}" = "./" ]; then
        MY_CLUSTER_DIR="${cur_dir}"
    fi
fi
MY_CLUSTER_DIR=$(Check_PathName ${MY_CLUSTER_DIR})

# Process $CEPH_LOCAL_HOSTNAME
if [ -z "${CEPH_LOCAL_HOSTNAME}" ]; then
    CEPH_LOCAL_HOSTNAME=$(Get_Local_HostName)
fi

# Process $CEPH_LOCAL_HOSTIP
if [ -z "${CEPH_LOCAL_HOSTIP}" ]; then
    CEPH_LOCAL_HOSTIP=$(Get_Local_HostIP)
fi

# Process CEPH_RADOSGW_HOST
if [ -z "${CEPH_RADOSGW_HOST}" ]; then
    CEPH_RADOSGW_HOST=$(Get_Local_HostName)
fi

# Process CIVETWEB_PORT
if [ -z "${CIVETWEB_PORT}" ]; then
    CIVETWEB_PORT="8000"
fi

. include/linux_version.sh

Get_Linux_Dist_Name

if [ "${DISTRO}" = "unknow" ]; then
    Echo_Red "Error: Unable to get the Linux distribution name, or do NOT support the current distribution."
    exit 1
fi

. include/random.sh

function Display_Welcome()
{
    clear
    echo ""
    echo "+------------------------------------------------------------------------+"
    echo "|                                                                        |"
    Echo_Cyan_Ex "|" "               Ceph RGW S3 Shell Script for Linux Server                " "|"
    echo "|                                                                        |"
    echo "|                           Version: ${CEPH_RGW_S3_Version}                               |"
    echo "|                           Host OS: ${DISTRO}                            "
    echo "|                                                                        |"
    echo "|                         Author by: shines77                            |"
    echo "|                     Last Modified: ${CEPH_RGW_S3_LastModified}                          |"
    echo "|                                                                        |"
    echo "+------------------------------------------------------------------------+"
    echo "|         A tool to auto-compile & install Ceph RGW S3 on Linux          |"
    echo "+------------------------------------------------------------------------+"
    echo "|     For more information please visit http://cephrgws3.skyinno.com     |"
    echo "+------------------------------------------------------------------------+"
    echo ""
}

Display_Welcome

function Show_Ceph_HostInfo()
{
    echo "CEPH_LOCAL_HOSTNAME = ${CEPH_LOCAL_HOSTNAME}"
    echo "CEPH_LOCAL_HOSTIP   = ${CEPH_LOCAL_HOSTIP}"    
}

function Run_Ceph_RGW_for_S3()
{
    ## stop.sh
	killall radosgw
    killall ceph-osd
    killall ceph-mon

    mkdir -p ${MY_CLUSTER_DIR}
    cd ${MY_CLUSTER_DIR}

    ceph-authtool --create-keyring ${MY_CLUSTER_DIR}/keyring --gen-key -n mon. --cap mon 'allow *'
    ceph-authtool --gen-key --name=client.admin --set-uid=0 --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow *' ${MY_CLUSTER_DIR}/keyring
    monmaptool --create --clobber --add a ${CEPH_LOCAL_HOSTIP}:6789 --print ${MY_CLUSTER_DIR}/ceph_monmap.17607

    ## start.sh
	ceph-mon --mkfs -c ${MY_CLUSTER_DIR}/ceph.conf -i a --monmap=${MY_CLUSTER_DIR}/ceph_monmap.17607 --keyring=${MY_CLUSTER_DIR}/keyring
    ceph-mon -i a -c ${MY_CLUSTER_DIR}/ceph.conf
    ceph-osd -i 0 -c ${MY_CLUSTER_DIR}/ceph.conf
    ceph-osd -i 1 -c ${MY_CLUSTER_DIR}/ceph.conf
    ceph-osd -i 2 -c ${MY_CLUSTER_DIR}/ceph.conf

    ## radosgw startup
    # mkdir -p ${MY_CLUSTER_DIR}/dev/rgw/
    # ceph-authtool --create-keyring ${MY_CLUSTER_DIR}/dev/rgw/keyring
    # ceph-authtool ${MY_CLUSTER_DIR}/dev/rgw/keyring -n client.radosgw.gateway --gen-key
    # ceph-authtool -n client.radosgw.gateway --cap osd 'allow rwx' --cap mon 'allow rw' ${MY_CLUSTER_DIR}/dev/rgw/keyring
	ceph -k ${MY_CLUSTER_DIR}/keyring auth add client.radosgw.gateway -i ${MY_CLUSTER_DIR}/dev/rgw/keyring

    radosgw --id=radosgw.gateway
    radosgw -c ${MY_CLUSTER_DIR}/ceph.conf --keyring=${MY_CLUSTER_DIR}/dev/rgw/keyring --id=radosgw.gateway -d
}

Run_Ceph_RGW_for_S3
echo ""

echo "Ceph RadosGW for S3 have running!"
echo ""
