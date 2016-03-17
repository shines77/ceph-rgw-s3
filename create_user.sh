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

Display_Welcome

## Create 8 ceph users and keys
Create_Ceph_Users
