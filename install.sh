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

# Process $CEPH_LOCAL_HOSTNAME
if [ -z "${CEPH_LOCAL_HOSTNAME}" ]; then
    CEPH_LOCAL_HOSTNAME=$(Get_Local_HostName)
fi

# Process $CEPH_LOCAL_HOSTIP
if [ -z "${CEPH_LOCAL_HOSTIP}" ]; then
    CEPH_LOCAL_HOSTIP=$(Get_Local_HostIP)
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

    # Generate the "fsid" use in ceph.conf.
    local fsid=$(Get_UUID)

    echo "fsid = ${fsid}"
    echo ""

    # Generate ceph.conf configuration file.
    cat >>${MY_CLUSTER_DIR}/ceph.conf<<EOF
[global]
    fsid = ${fsid}
    osd_pg_bits = 6
    mon_pg_warn_max_per_osd = 1000
    osd_crush_chooseleaf_type = 0
    osd_pool_default_min_size = 1
    osd_failsafe_full_ratio = .99
    mon_osd_full_ratio = .99
    mon_data_avail_warn = 10
    mon_data_avail_crit = 1
    osd_pool_default_erasure_code_profile = plugin=jerasure technique=reed_sol_van k=2 m=1 ruleset-failure-domain=osd
    rgw_frontends = fastcgi, civetweb_port=${CIVETWEB_PORT}
    rgw_dns_name = localhost
    filestore_fd_cache_size = 32
    run_dir = ${MY_CLUSTER_DIR}/out
    enable_experimental_unrecoverable_data_corrupting_features = *
    auth_supported = cephx

[client]
    keyring = ${MY_CLUSTER_DIR}/keyring
    log_file = ${MY_CLUSTER_DIR}/out/$name.$pid.log
    admin_socket = ${MY_CLUSTER_DIR}/out/$name.$pid.asok

[mds]
    log_file = ${MY_CLUSTER_DIR}/out/$name.log
    admin_socket = ${MY_CLUSTER_DIR}/out/$name.asok
    chdir_= ""
    pid_file = ${MY_CLUSTER_DIR}/out/$name.pid
    heartbeat_file = ${MY_CLUSTER_DIR}/out/$name.heartbeat

    debug_ms = 1
    mds_debug_frag = true
    mds_debug_auth_pins = true
    mds_debug_subtrees = true
    mds_data = ${MY_CLUSTER_DIR}/dev/mds.$id

[osd]
    log_file = ${MY_CLUSTER_DIR}/out/$name.log
    admin_socket = ${MY_CLUSTER_DIR}/out/$name.asok
    chdir = ""
    pid_file = ${MY_CLUSTER_DIR}/out/$name.pid
    heartbeat_file = ${MY_CLUSTER_DIR}/out/$name.heartbeat

    osd_data = ${MY_CLUSTER_DIR}/dev/osd$id
    osd_journal = ${MY_CLUSTER_DIR}/dev/osd$id.journal
    osd_journal_size = 1000
    osd_scrub_load_threshold = 5.0
    osd_debug_op_order = true
    filestore_wbthrottle_xfs_ios_start_flusher = 10
    filestore_wbthrottle_xfs_ios_hard_limit = 20
    filestore_wbthrottle_xfs_inodes_hard_limit = 30
    filestore_wbthrottle_btrfs_ios_start_flusher = 10
    filestore_wbthrottle_btrfs_ios_hard_limit = 20
    filestore_wbthrottle_btrfs_inodes_hard_limit = 30

    debug_ms = 1

[mon]
    mon_pg_warn_min_per_osd = 3
    mon_osd_allow_primary_affinity = true
    mon_reweight_min_pgs_per_osd = 4
    mon_osd_prime_pg_temp = true
    crushtool = crushtool

    log_file = ${MY_CLUSTER_DIR}/out/$name.log
    admin_socket = ${MY_CLUSTER_DIR}/out/$name.asok
    chdir = ""
    pid_file = ${MY_CLUSTER_DIR}/out/$name.pid
    heartbeat_file = ${MY_CLUSTER_DIR}/out/$name.heartbeat

    debug_mon = 10
    debug_ms = 1

    mon_cluster_log_file = ${MY_CLUSTER_DIR}/out/cluster.mon.$id.log

[global]

[mon.a]
    host = ${CEPH_LOCAL_HOSTNAME}
    mon_data = ${MY_CLUSTER_DIR}/dev/mon.a
    mon_addr = ${CEPH_LOCAL_HOSTIP}:6789

[osd.0]
    host = ${CEPH_LOCAL_HOSTNAME}
[osd.1]
    host = ${CEPH_LOCAL_HOSTNAME}
[osd.2]
    host = ${CEPH_LOCAL_HOSTNAME}

[client.radosgw.gateway]
    host = ${CEPH_LOCAL_HOSTNAME}
    keyring = ${MY_CLUSTER_DIR}/dev/rgw/keyring
    rgw_socket_path = /tmp/radosgw.sock
    log_file = /var/log/radosgw/radosgw.log
    rgw_frontends = "civetweb port=80"
EOF
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
