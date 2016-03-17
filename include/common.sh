#!/bin/bash

##
## Check whether the logon user is a root account?
##
function Check_Is_Root_Account()
{
    if [ $(id -u) != "0" ]; then
        Echo_Red "Error: You must logon a root account to run this script, please use [sudo ./xxxx.sh] try again."
        exit 1
    fi
}

##
## Return a uuid string
##
function Get_UUID()
{
    echo "`uuidgen`"
}

##
## Get a char input
##
function Press_Start()
{
    echo ""
    echo "Press any key to start or Press Ctrl + C to cancel ..."
    OLDCONFIG=`stty -g`
    stty -icanon -echo min 1 time 0
    dd count=1 2>/dev/null
    stty ${OLDCONFIG}
    echo ""
}

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
    echo "|          A tool to auto-deploy & config Ceph RGW S3 on Linux           |"
    echo "+------------------------------------------------------------------------+"
    echo "|       For more information please visit http://rgws3.skyinno.com       |"
    echo "+------------------------------------------------------------------------+"
    echo ""
}

function Show_Ceph_HostInfo()
{
    echo "CEPH_LOCAL_HOSTNAME = ${CEPH_LOCAL_HOSTNAME}"
    echo "CEPH_LOCAL_HOSTIP   = ${CEPH_LOCAL_HOSTIP}"
    echo "CEPH_LOCAL_PORT     = ${CEPH_LOCAL_PORT}"
}
