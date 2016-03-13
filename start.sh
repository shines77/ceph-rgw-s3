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

# Process $MY_CLUSTER_DIR
if [[ -z "${MY_CLUSTER_DIR}" || "${MY_CLUSTER_DIR}" = "../" ]]; then
    MY_CLUSTER_DIR="${cur_dir}/../"
else
    if [ "${MY_CLUSTER_DIR}" = "./" ]; then
        MY_CLUSTER_DIR="${cur_dir}"
    fi
fi
MY_CLUSTER_DIR=$(Check_PathName ${MY_CLUSTER_DIR})

# Process $CEPH_BIN_DIR
if [ -z "${CEPH_BIN_DIR}" ]; then
    CEPH_BIN_DIR=""
else
    if [ "${CEPH_BIN_DIR}" = "../" ]; then
        CEPH_BIN_DIR="${cur_dir}/../"
    else
        CEPH_BIN_DIR=$(Check_PathName ${CEPH_BIN_DIR})
        CEPH_BIN_DIR="${CEPH_BIN_DIR}/"
    fi
fi

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

function Start_Ceph_RGW_for_S3()
{
    ## stop.sh
    killall radosgw
    killall ceph-osd
    killall ceph-mds
    killall ceph-mon

    mkdir -p ${MY_CLUSTER_DIR}
    cd ${MY_CLUSTER_DIR}

    # ${CEPH_BIN_DIR}ceph-authtool --create-keyring ${MY_CLUSTER_DIR}/keyring --gen-key -n mon. --cap mon 'allow *'
    # ${CEPH_BIN_DIR}ceph-authtool --gen-key --name=client.admin --set-uid=0 --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow *' ${MY_CLUSTER_DIR}/keyring
    ${CEPH_BIN_DIR}monmaptool --create --clobber --add a ${CEPH_LOCAL_HOSTIP}:6789 --print ${MY_CLUSTER_DIR}/ceph_monmap.17607

    ## start.sh
    ${CEPH_BIN_DIR}ceph-mon --mkfs -c ${MY_CLUSTER_DIR}/ceph.conf -i a --monmap=${MY_CLUSTER_DIR}/ceph_monmap.17607 --keyring=${MY_CLUSTER_DIR}/keyring
    ${CEPH_BIN_DIR}ceph-mon -i a -c ${MY_CLUSTER_DIR}/ceph.conf

    mkdir -p ${MY_CLUSTER_DIR}/dev/osd0
    ${CEPH_BIN_DIR}ceph -c ${MY_CLUSTER_DIR}/ceph.conf -k ${MY_CLUSTER_DIR}/keyring osd crush add osd.0 1.0 host=${CEPH_LOCAL_HOSTNAME} root=default
    ${CEPH_BIN_DIR}ceph -c ${MY_CLUSTER_DIR}/ceph.conf -k ${MY_CLUSTER_DIR}/keyring -i ${MY_CLUSTER_DIR}/dev/osd0/keyring auth add osd.0 osd 'allow *' mon 'allow profile osd'
    ${CEPH_BIN_DIR}ceph-osd -i 0 -c ${MY_CLUSTER_DIR}/ceph.conf

    mkdir -p ${MY_CLUSTER_DIR}/dev/osd1
    ${CEPH_BIN_DIR}ceph -c ${MY_CLUSTER_DIR}/ceph.conf -k ${MY_CLUSTER_DIR}/keyring osd crush add osd.1 1.0 host=${CEPH_LOCAL_HOSTNAME} root=default
    ${CEPH_BIN_DIR}ceph -c ${MY_CLUSTER_DIR}/ceph.conf -k ${MY_CLUSTER_DIR}/keyring -i ${MY_CLUSTER_DIR}/dev/osd1/keyring auth add osd.1 osd 'allow *' mon 'allow profile osd'
    ${CEPH_BIN_DIR}ceph-osd -i 1 -c ${MY_CLUSTER_DIR}/ceph.conf

    mkdir -p ${MY_CLUSTER_DIR}/dev/osd2
    ${CEPH_BIN_DIR}ceph -c ${MY_CLUSTER_DIR}/ceph.conf -k ${MY_CLUSTER_DIR}/keyring osd crush add osd.2 1.0 host=${CEPH_LOCAL_HOSTNAME} root=default
    ${CEPH_BIN_DIR}ceph -c ${MY_CLUSTER_DIR}/ceph.conf -k ${MY_CLUSTER_DIR}/keyring -i ${MY_CLUSTER_DIR}/dev/osd2/keyring auth add osd.2 osd 'allow *' mon 'allow profile osd'
    ${CEPH_BIN_DIR}ceph-osd -i 2 -c ${MY_CLUSTER_DIR}/ceph.conf

    ## radosgw startup
    mkdir -p ${MY_CLUSTER_DIR}/dev/rgw/
    # ${CEPH_BIN_DIR}ceph-authtool --create-keyring ${MY_CLUSTER_DIR}/dev/rgw/keyring
    # ${CEPH_BIN_DIR}ceph-authtool ${MY_CLUSTER_DIR}/dev/rgw/keyring -n client.radosgw.gateway --gen-key
    # ${CEPH_BIN_DIR}ceph-authtool -n client.radosgw.gateway --cap osd 'allow rwx' --cap mon 'allow rw' ${MY_CLUSTER_DIR}/dev/rgw/keyring
    # ${CEPH_BIN_DIR}ceph -k ${MY_CLUSTER_DIR}/keyring auth add client.radosgw.gateway -i ${MY_CLUSTER_DIR}/dev/rgw/keyring

    # ${CEPH_BIN_DIR}radosgw --id=radosgw.gateway
    ${CEPH_BIN_DIR}radosgw -c ${MY_CLUSTER_DIR}/ceph.conf --keyring=${MY_CLUSTER_DIR}/dev/rgw/keyring --id=radosgw.gateway -d
}

Start_Ceph_RGW_for_S3
echo ""

echo "Ceph and RadosGW have exited!"
echo ""
