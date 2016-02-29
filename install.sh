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

# Echo_Color_Test
# Echo_Color_Ex_Test

# echo "MY_CLUSTER_DIR = ${MY_CLUSTER_DIR}"
# echo ""

function Show_Ceph_HostInfo()
{
    echo "CEPH_LOCAL_HOSTNAME = ${CEPH_LOCAL_HOSTNAME}"
    echo "CEPH_LOCAL_HOSTIP   = ${CEPH_LOCAL_HOSTIP}"    
}

function Config_Ceph_RGW_for_S3()
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

    mkdir -p ${MY_CLUSTER_DIR}/dev
    rm -rf ${MY_CLUSTER_DIR}/dev/mon.a
    mkdir -p ${MY_CLUSTER_DIR}/dev/mon.a

    # Generate the "fsid" use in ceph.conf.
    local fsid=$(Get_UUID)

    # Generate ceph.conf configuration file.
    cat > ${MY_CLUSTER_DIR}/ceph.conf<<EOF
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
    log_file = ${MY_CLUSTER_DIR}/out/\$name.\$pid.log
    admin_socket = ${MY_CLUSTER_DIR}/out/\$name.\$pid.asok

[mds]
    log_file = ${MY_CLUSTER_DIR}/out/\$name.log
    admin_socket = ${MY_CLUSTER_DIR}/out/\$name.asok
    chdir_= ""
    pid_file = ${MY_CLUSTER_DIR}/out/\$name.pid
    heartbeat_file = ${MY_CLUSTER_DIR}/out/\$name.heartbeat

    debug_ms = 1
    mds_debug_frag = true
    mds_debug_auth_pins = true
    mds_debug_subtrees = true
    mds_data = ${MY_CLUSTER_DIR}/dev/mds.\$id

[osd]
    log_file = ${MY_CLUSTER_DIR}/out/\$name.log
    admin_socket = ${MY_CLUSTER_DIR}/out/\$name.asok
    chdir = ""
    pid_file = ${MY_CLUSTER_DIR}/out/\$name.pid
    heartbeat_file = ${MY_CLUSTER_DIR}/out/\$name.heartbeat

    osd_data = ${MY_CLUSTER_DIR}/dev/osd\$id
    osd_journal = ${MY_CLUSTER_DIR}/dev/osd\$id.journal
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

    log_file = ${MY_CLUSTER_DIR}/out/\$name.log
    admin_socket = ${MY_CLUSTER_DIR}/out/\$name.asok
    chdir = ""
    pid_file = ${MY_CLUSTER_DIR}/out/\$name.pid
    heartbeat_file = ${MY_CLUSTER_DIR}/out/\$name.heartbeat

    debug_mon = 10
    debug_ms = 1

    mon_cluster_log_file = ${MY_CLUSTER_DIR}/out/cluster.mon.\$id.log

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
    host = ${CEPH_RADOSGW_HOST}
    keyring = ${MY_CLUSTER_DIR}/dev/rgw/keyring
    rgw_socket_path = /tmp/radosgw.sock
    log_file = /var/log/radosgw/radosgw.log
    rgw_frontends = "civetweb port=${CIVETWEB_PORT}"
EOF

    ############################################################

    ceph-mon --mkfs -c ${MY_CLUSTER_DIR}/ceph.conf -i a --monmap=${MY_CLUSTER_DIR}/ceph_monmap.17607 --keyring=${MY_CLUSTER_DIR}/keyring
    ceph-mon -i a -c ${MY_CLUSTER_DIR}/ceph.conf

    ############################################################

    ## For osd 0
    rm -rf ${MY_CLUSTER_DIR}/dev/osd0
    mkdir -p ${MY_CLUSTER_DIR}/dev/osd0

    ## Generate uuid for osd 0
    local osd_uuid=$(Get_UUID)
    ceph -c ${MY_CLUSTER_DIR}/ceph.conf -k ${MY_CLUSTER_DIR}/keyring osd create ${osd_uuid}
    ceph -c ${MY_CLUSTER_DIR}/ceph.conf -k ${MY_CLUSTER_DIR}/keyring osd crush add osd.0 1.0 host=${CEPH_LOCAL_HOSTNAME} root=default
    ceph-osd -i 0 -c ${MY_CLUSTER_DIR}/ceph.conf --mkfs --mkkey --osd-uuid ${osd_uuid}
    ceph -c ${MY_CLUSTER_DIR}/ceph.conf -k ${MY_CLUSTER_DIR}/keyring -i ${MY_CLUSTER_DIR}/dev/osd0/keyring auth add osd.0 osd 'allow *' mon 'allow profile osd'
    ceph-osd -i 0 -c ${MY_CLUSTER_DIR}/ceph.conf

    ## For osd 1
    rm -rf ${MY_CLUSTER_DIR}/dev/osd1
    mkdir -p ${MY_CLUSTER_DIR}/dev/osd1

    ## Generate uuid for osd 1
    osd_uuid=$(Get_UUID)
    ceph -c ${MY_CLUSTER_DIR}/ceph.conf -k ${MY_CLUSTER_DIR}/keyring osd create ${osd_uuid}
    ceph -c ${MY_CLUSTER_DIR}/ceph.conf -k ${MY_CLUSTER_DIR}/keyring osd crush add osd.1 1.0 host=${CEPH_LOCAL_HOSTNAME} root=default
    ceph-osd -i 1 -c ${MY_CLUSTER_DIR}/ceph.conf --mkfs --mkkey --osd-uuid ${osd_uuid}
    ceph -c ${MY_CLUSTER_DIR}/ceph.conf -k ${MY_CLUSTER_DIR}/keyring -i ${MY_CLUSTER_DIR}/dev/osd1/keyring auth add osd.1 osd 'allow *' mon 'allow profile osd'
    ceph-osd -i 1 -c ${MY_CLUSTER_DIR}/ceph.conf

    ## For osd 2
    rm -rf ${MY_CLUSTER_DIR}/dev/osd2
    mkdir -p ${MY_CLUSTER_DIR}/dev/osd2

    ## Generate uuid for osd 2
    osd_uuid=$(Get_UUID)
    ceph -c ${MY_CLUSTER_DIR}/ceph.conf -k ${MY_CLUSTER_DIR}/keyring osd create ${osd_uuid}
    ceph -c ${MY_CLUSTER_DIR}/ceph.conf -k ${MY_CLUSTER_DIR}/keyring osd crush add osd.2 1.0 host=${CEPH_LOCAL_HOSTNAME} root=default
    ceph-osd -i 2 -c ${MY_CLUSTER_DIR}/ceph.conf --mkfs --mkkey --osd-uuid ${osd_uuid}
    ceph -c ${MY_CLUSTER_DIR}/ceph.conf -k ${MY_CLUSTER_DIR}/keyring -i ${MY_CLUSTER_DIR}/dev/osd2/keyring auth add osd.2 osd 'allow *' mon 'allow profile osd'
    ceph-osd -i 2 -c ${MY_CLUSTER_DIR}/ceph.conf

    ############################################################

    ## For RadosGW
    mkdir -p ${MY_CLUSTER_DIR}/dev/rgw/
    ceph-authtool --create-keyring ${MY_CLUSTER_DIR}/dev/rgw/keyring
    ceph-authtool ${MY_CLUSTER_DIR}/dev/rgw/keyring -n client.radosgw.gateway --gen-key
    ceph-authtool -n client.radosgw.gateway --cap osd 'allow rwx' --cap mon 'allow rw' ${MY_CLUSTER_DIR}/dev/rgw/keyring
    ceph -k ${MY_CLUSTER_DIR}/keyring auth add client.radosgw.gateway -i ${MY_CLUSTER_DIR}/dev/rgw/keyring

    radosgw --id=radosgw.gateway
    radosgw -c ${MY_CLUSTER_DIR}/ceph.conf --keyring=${MY_CLUSTER_DIR}/dev/rgw/keyring --id=radosgw.gateway -d

    ## radosgw-admin user create --uid=s3_test --display-name="S3 test user" --email=admin@example.com

    echo ""
    Press_Start
    echo ""

    ############################################################

    ## stop.sh
	killall radosgw
    killall ceph-osd
    killall ceph-mon

    ## start.sh
    ceph-mon -i a -c ${MY_CLUSTER_DIR}/ceph.conf
    ceph-osd -i 0 -c ${MY_CLUSTER_DIR}/ceph.conf
    ceph-osd -i 1 -c ${MY_CLUSTER_DIR}/ceph.conf
    ceph-osd -i 2 -c ${MY_CLUSTER_DIR}/ceph.conf
}

## Test_Random
## echo ""

# Test_Local_HostInfo
# echo ""

# Show_Ceph_HostInfo
# echo ""

# Test_CheckPathName
# echo ""

Config_Ceph_RGW_for_S3
echo ""

echo "Config Ceph RadosGW for S3 have done!"
echo ""
