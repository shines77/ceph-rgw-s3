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

. version.sh
. config.sh
. set_vars.sh

. include/linux_version.sh
. include/ceph_rgw.sh

Get_Linux_Dist_Name

if [ "${DISTRO}" = "unknow" ]; then
    Echo_Red "Error: Unable to get the Linux distribution name, or do NOT support the current distribution."
    exit 1
fi

function Deploy_Confirm()
{
    local deploy_now=0
    ConfirmSelect="No"
    echo ""
    Echo_Yellow "You have 2 options for ceph and rados-gw:"
    echo ""
    echo "Y) Deploy ceph and rados-gw now."
    echo "N) Deploy later and exit. (default)"
    echo ""
    Echo_Red "(Becareful, deploy now will destroy your all osd data, users and keys !!)"
    echo ""
    read -p "Enter your choice: [y/N] ? " ConfirmSelect

    echo ""
    case "${ConfirmSelect}" in
        1|y|Y|Yes|yes)
            Echo_Cyan "It will deploy ceph and rados-gw now."
            deploy_now=1
            ;;
        2|n|N|No|no)
            Echo_Cyan "Don't deploy ceph now, and exit. (Default)"
            deploy_now=0
            ;;
        *)
            Echo_Cyan "Unknown input, Don't deploy ceph now."
            deploy_now=0
            ;;
    esac
    echo ""

    if [ "${deploy_now}" == "1" ]; then
        Deploy_Ceph_RGW
    else
        # do nothing and exit.
        exit
    fi
}

function Menu_Selection()
{
    MenuSelect="2"
    echo ""
    Echo_Yellow "You have 5 options for ceph and rados-gw:"
    echo ""
    echo "1) Deploy ceph and rados-gw."
    echo "2) Start ceph and rados-gw. (Default)"
    echo "3) Stop ceph and rados-gw."
    echo "4) Create ceph users and keys."
    echo "5) Exit."
    echo ""
    read -p "Enter your choice (1-5): [${MenuSelect}] ?" MenuSelect

    echo ""
    case "${MenuSelect}" in
        1)
            Echo_Cyan "It will deploy ceph and rados-gw."
            ;;
        2)
            Echo_Cyan "It will startup ceph and rados-gw. (Default)"
            ;;
        3)
            Echo_Cyan "It will stop ceph and rados-gw."
            ;;
        4)
            Echo_Cyan "It will create ceph users and keys."
            ;;
        5)
            Echo_Cyan "It will do nothing and exit!"
            ;;
        *)
            Echo_Cyan "Unknown input, You must choose a option from (1-5)."
            MenuSelect="2"
            ;;
    esac
    echo ""

    if [ "${MenuSelect}" = "1" ]; then
        Deploy_Ceph_RGW
    elif [ "${MenuSelect}" = "2" ]; then
        Start_Ceph_RGW
    elif [ "${MenuSelect}" = "3" ]; then
        Stop_Ceph_RGW
    elif [ "${MenuSelect}" = "4" ]; then
        Create_Ceph_Users
    elif [ "${MenuSelect}" = "5" ]; then
        # do nothing and exit.
        exit
    else
        # Unknown input, retry again.
        echo ""
        Menu_Selection
    fi
}

Display_Welcome

Show_Ceph_HostInfo

Menu_Selection

echo ""
echo "Ceph and RadosGW have exited!"
echo ""
