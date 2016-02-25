#!/bin/bash

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# For Check_Is_Root_Account(), Echo_Color()
. include/echo_color.sh
. include/common.sh
. include/network.sh

# Check whether the logon user is a root account?
Check_Is_Root_Account

cur_dir=$(pwd)

# Process $MY_CLUSTER_DIR
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

. version.sh
. config.sh

. include/linux_version.sh

Get_Linux_Dist_Name

if [ "${DISTRO}" = "unknow" ]; then
    Echo_Red "Error: Unable to get the Linux distribution name, or do NOT support the current distribution."
    exit 1
fi

. include/path.sh
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

# Echo_Color_Test
# Echo_Color_Ex_Test

echo "MY_CLUSTER_DIR = ${MY_CLUSTER_DIR}"
echo ""

function Config_Ceph_RGW_for_S3()
{
    mkdir -p ${MY_CLUSTER_DIR}
    cd ${MY_CLUSTER_DIR}
    ceph-authtool --create-keyring ${MY_CLUSTER_DIR}/keyring --gen-key -n mon. --cap mon 'allow *'
    ceph-authtool --gen-key --name=client.admin --set-uid=0 --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow *' ${MY_CLUSTER_DIR}/keyring
    monmaptool --create --clobber --add a ${CEPH_LOCAL_HOSTIP}:6789 --print ${MY_CLUSTER_DIR}/ceph_monmap.17607

    mkdir -p ${MY_CLUSTER_DIR}/dev
    rm -rf ${MY_CLUSTER_DIR}/dev/mon.a
    mkdir -p ${MY_CLUSTER_DIR}/dev/mon.a

    # generate the "fsid" use in ceph.conf
    local fsid=$(Get_UUID)

    echo "fsid = ${fsid}"
    echo ""
}

## Test_Random
## echo ""

Test_Local_HostInfo
echo ""

echo "CEPH_LOCAL_HOSTNAME = ${CEPH_LOCAL_HOSTNAME}"
echo "CEPH_LOCAL_HOSTIP   = ${CEPH_LOCAL_HOSTIP}"

Test_CheckPathName
echo ""

Config_Ceph_RGW_for_S3
echo ""
