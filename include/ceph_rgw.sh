#!/bin/bash

function Kill_Ceph_Processes()
{
    ## stop.sh
    killall -SIGKILL radosgw
    killall -SIGKILL ceph-osd
    killall -SIGKILL ceph-mds
    killall -SIGKILL ceph-mon
}

function Deploy_Ceph_RGW()
{
    ## stop.sh
    Kill_Ceph_Processes

    mkdir -p ${MY_CLUSTER_DIR}
    cd ${MY_CLUSTER_DIR}

    mkdir -p ${MY_CLUSTER_DIR}/dev
    rm -rf ${MY_CLUSTER_DIR}/dev/mon.a
    mkdir -p ${MY_CLUSTER_DIR}/dev/mon.a

    cd ${MY_CLUSTER_DIR}

    ${CEPH_BIN_DIR}ceph-authtool --create-keyring ${MY_CLUSTER_DIR}/keyring --gen-key -n mon. --cap mon 'allow *'
    ${CEPH_BIN_DIR}ceph-authtool --gen-key --name=client.admin --set-uid=0 --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow *' ${MY_CLUSTER_DIR}/keyring
    ${CEPH_BIN_DIR}monmaptool --create --clobber --add a ${CEPH_LOCAL_HOSTIP}:${CEPH_MON_PORT} --print ${MY_CLUSTER_DIR}/ceph_monmap.17607    

    # Generate the "fsid" use in ceph.conf.
    local fsid=$(Get_UUID)

    # Generate ceph.conf configuration file.
    cat > ${MY_CLUSTER_DIR}/ceph.conf<<EOF
[global]
    fsid = ${fsid}
    osd_pg_bits = 6
    osd_pgp_bits = 7
    mon_pg_warn_max_per_osd = 1000
    osd_crush_chooseleaf_type = 0
    osd_pool_default_min_size = 1
    osd_failsafe_full_ratio = .99
    mon_osd_full_ratio = .99
    mon_data_avail_warn = 10
    mon_data_avail_crit = 1
    erasure_code_dir = ${ERASURE_CODE_DIR}
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

[mon.a]
    host = ${CEPH_LOCAL_HOSTNAME}
    mon_data = ${MY_CLUSTER_DIR}/dev/mon.a
    mon_addr = ${CEPH_LOCAL_HOSTIP}:${CEPH_MON_PORT}

[osd.0]
    host = ${CEPH_LOCAL_HOSTNAME}
    ms_bind_port_min = 6800
    ms_bind_port_max = 7100

[osd.1]
    host = ${CEPH_LOCAL_HOSTNAME}
    ms_bind_port_min = 6800
    ms_bind_port_max = 7100

[osd.2]
    host = ${CEPH_LOCAL_HOSTNAME}
    ms_bind_port_min = 6800
    ms_bind_port_max = 7100

[client.radosgw.gateway]
    host = ${CEPH_RADOSGW_HOST}
    keyring = ${MY_CLUSTER_DIR}/dev/rgw/keyring
    rgw_socket_path = /tmp/\$cluster/radosgw.sock
    log_file = /var/log/radosgw/\$cluster/radosgw.log
    rgw_frontends = "civetweb port=${CIVETWEB_PORT}"
EOF

    ############################################################

    ${CEPH_BIN_DIR}ceph-mon --mkfs -c ${MY_CLUSTER_DIR}/ceph.conf -i a --monmap=${MY_CLUSTER_DIR}/ceph_monmap.17607 --keyring=${MY_CLUSTER_DIR}/keyring
    ${CEPH_BIN_DIR}ceph-mon -i a -c ${MY_CLUSTER_DIR}/ceph.conf

    ############################################################

    ## For osd 0
    rm -rf ${MY_CLUSTER_DIR}/dev/osd0
    mkdir -p ${MY_CLUSTER_DIR}/dev/osd0

    ## Generate uuid for osd 0
    local osd_uuid=$(Get_UUID)
    ${CEPH_BIN_DIR}ceph -c ${MY_CLUSTER_DIR}/ceph.conf -k ${MY_CLUSTER_DIR}/keyring osd create ${osd_uuid}
    ${CEPH_BIN_DIR}ceph -c ${MY_CLUSTER_DIR}/ceph.conf -k ${MY_CLUSTER_DIR}/keyring osd crush add osd.0 1.0 host=${CEPH_LOCAL_HOSTNAME} root=default
    ${CEPH_BIN_DIR}ceph-osd -i 0 -c ${MY_CLUSTER_DIR}/ceph.conf --mkfs --mkkey --osd-uuid ${osd_uuid}
    ${CEPH_BIN_DIR}ceph -c ${MY_CLUSTER_DIR}/ceph.conf -k ${MY_CLUSTER_DIR}/keyring -i ${MY_CLUSTER_DIR}/dev/osd0/keyring auth add osd.0 osd 'allow *' mon 'allow profile osd'
    ${CEPH_BIN_DIR}ceph-osd -i 0 -c ${MY_CLUSTER_DIR}/ceph.conf

    ## For osd 1
    rm -rf ${MY_CLUSTER_DIR}/dev/osd1
    mkdir -p ${MY_CLUSTER_DIR}/dev/osd1

    ## Generate uuid for osd 1
    osd_uuid=$(Get_UUID)
    ${CEPH_BIN_DIR}ceph -c ${MY_CLUSTER_DIR}/ceph.conf -k ${MY_CLUSTER_DIR}/keyring osd create ${osd_uuid}
    ${CEPH_BIN_DIR}ceph -c ${MY_CLUSTER_DIR}/ceph.conf -k ${MY_CLUSTER_DIR}/keyring osd crush add osd.1 1.0 host=${CEPH_LOCAL_HOSTNAME} root=default
    ${CEPH_BIN_DIR}ceph-osd -i 1 -c ${MY_CLUSTER_DIR}/ceph.conf --mkfs --mkkey --osd-uuid ${osd_uuid}
    ${CEPH_BIN_DIR}ceph -c ${MY_CLUSTER_DIR}/ceph.conf -k ${MY_CLUSTER_DIR}/keyring -i ${MY_CLUSTER_DIR}/dev/osd1/keyring auth add osd.1 osd 'allow *' mon 'allow profile osd'
    ${CEPH_BIN_DIR}ceph-osd -i 1 -c ${MY_CLUSTER_DIR}/ceph.conf

    ## For osd 2
    rm -rf ${MY_CLUSTER_DIR}/dev/osd2
    mkdir -p ${MY_CLUSTER_DIR}/dev/osd2

    ## Generate uuid for osd 2
    osd_uuid=$(Get_UUID)
    ${CEPH_BIN_DIR}ceph -c ${MY_CLUSTER_DIR}/ceph.conf -k ${MY_CLUSTER_DIR}/keyring osd create ${osd_uuid}
    ${CEPH_BIN_DIR}ceph -c ${MY_CLUSTER_DIR}/ceph.conf -k ${MY_CLUSTER_DIR}/keyring osd crush add osd.2 1.0 host=${CEPH_LOCAL_HOSTNAME} root=default
    ${CEPH_BIN_DIR}ceph-osd -i 2 -c ${MY_CLUSTER_DIR}/ceph.conf --mkfs --mkkey --osd-uuid ${osd_uuid}
    ${CEPH_BIN_DIR}ceph -c ${MY_CLUSTER_DIR}/ceph.conf -k ${MY_CLUSTER_DIR}/keyring -i ${MY_CLUSTER_DIR}/dev/osd2/keyring auth add osd.2 osd 'allow *' mon 'allow profile osd'
    ${CEPH_BIN_DIR}ceph-osd -i 2 -c ${MY_CLUSTER_DIR}/ceph.conf

    ############################################################

    ## For RadosGW
    mkdir -p ${MY_CLUSTER_DIR}/dev/rgw/
    ${CEPH_BIN_DIR}ceph-authtool --create-keyring ${MY_CLUSTER_DIR}/dev/rgw/keyring
    ${CEPH_BIN_DIR}ceph-authtool ${MY_CLUSTER_DIR}/dev/rgw/keyring -n client.radosgw.gateway --gen-key
    ${CEPH_BIN_DIR}ceph-authtool -n client.radosgw.gateway --cap osd 'allow rwx' --cap mon 'allow rw' ${MY_CLUSTER_DIR}/dev/rgw/keyring
    ${CEPH_BIN_DIR}ceph -k ${MY_CLUSTER_DIR}/keyring auth add client.radosgw.gateway -i ${MY_CLUSTER_DIR}/dev/rgw/keyring

    ## ${CEPH_BIN_DIR}radosgw --id=radosgw.gateway
    ${CEPH_BIN_DIR}radosgw -c ${MY_CLUSTER_DIR}/ceph.conf --keyring=${MY_CLUSTER_DIR}/dev/rgw/keyring --id=radosgw.gateway -d

    ## ${CEPH_BIN_DIR}radosgw-admin user create --uid=s3_test --display-name="S3 test user" --email=admin@example.com

    ############################################################
}

function Start_Ceph_RGW()
{
    ## stop.sh
    Kill_Ceph_Processes

    mkdir -p ${MY_CLUSTER_DIR}
    cd ${MY_CLUSTER_DIR}

    # ${CEPH_BIN_DIR}ceph-authtool --create-keyring ${MY_CLUSTER_DIR}/keyring --gen-key -n mon. --cap mon 'allow *'
    # ${CEPH_BIN_DIR}ceph-authtool --gen-key --name=client.admin --set-uid=0 --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow *' ${MY_CLUSTER_DIR}/keyring
    ${CEPH_BIN_DIR}monmaptool --create --clobber --add a ${CEPH_LOCAL_HOSTIP}:${CEPH_LOCAL_PORT} --print ${MY_CLUSTER_DIR}/ceph_monmap.17607

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

function Stop_Ceph_RGW()
{
    ## stop.sh
    Kill_Ceph_Processes
}

function Create_Ceph_1_Users()
{
    mkdir -p ${MY_CLUSTER_DIR}
    cd ${MY_CLUSTER_DIR}

    ${CEPH_BIN_DIR}radosgw-admin -c ${MY_CLUSTER_DIR}/ceph.conf user create --uid=test1 --display-name="test1" --email=test1@example.com
}

function Create_Ceph_4_Users()
{
    mkdir -p ${MY_CLUSTER_DIR}
    cd ${MY_CLUSTER_DIR}

    ${CEPH_BIN_DIR}radosgw-admin -c ${MY_CLUSTER_DIR}/ceph.conf user create --uid=test1 --display-name="test1" --email=test1@example.com
    ${CEPH_BIN_DIR}radosgw-admin -c ${MY_CLUSTER_DIR}/ceph.conf user create --uid=test2 --display-name="test2" --email=test2@example.com
    ${CEPH_BIN_DIR}radosgw-admin -c ${MY_CLUSTER_DIR}/ceph.conf user create --uid=test3 --display-name="test3" --email=test3@example.com
    ${CEPH_BIN_DIR}radosgw-admin -c ${MY_CLUSTER_DIR}/ceph.conf user create --uid=test4 --display-name="test4" --email=test4@example.com    
}

function Create_Ceph_6_Users()
{
    mkdir -p ${MY_CLUSTER_DIR}
    cd ${MY_CLUSTER_DIR}

    ${CEPH_BIN_DIR}radosgw-admin -c ${MY_CLUSTER_DIR}/ceph.conf user create --uid=test1 --display-name="test1" --email=test1@example.com
    ${CEPH_BIN_DIR}radosgw-admin -c ${MY_CLUSTER_DIR}/ceph.conf user create --uid=test2 --display-name="test2" --email=test2@example.com
    ${CEPH_BIN_DIR}radosgw-admin -c ${MY_CLUSTER_DIR}/ceph.conf user create --uid=test3 --display-name="test3" --email=test3@example.com
    ${CEPH_BIN_DIR}radosgw-admin -c ${MY_CLUSTER_DIR}/ceph.conf user create --uid=test4 --display-name="test4" --email=test4@example.com
    ${CEPH_BIN_DIR}radosgw-admin -c ${MY_CLUSTER_DIR}/ceph.conf user create --uid=test5 --display-name="test5" --email=test5@example.com
    ${CEPH_BIN_DIR}radosgw-admin -c ${MY_CLUSTER_DIR}/ceph.conf user create --uid=test6 --display-name="test6" --email=test6@example.com
}

function Create_Ceph_8_Users()
{
    mkdir -p ${MY_CLUSTER_DIR}
    cd ${MY_CLUSTER_DIR}

    ${CEPH_BIN_DIR}radosgw-admin -c ${MY_CLUSTER_DIR}/ceph.conf user create --uid=test1 --display-name="test1" --email=test1@example.com
    ${CEPH_BIN_DIR}radosgw-admin -c ${MY_CLUSTER_DIR}/ceph.conf user create --uid=test2 --display-name="test2" --email=test2@example.com
    ${CEPH_BIN_DIR}radosgw-admin -c ${MY_CLUSTER_DIR}/ceph.conf user create --uid=test3 --display-name="test3" --email=test3@example.com
    ${CEPH_BIN_DIR}radosgw-admin -c ${MY_CLUSTER_DIR}/ceph.conf user create --uid=test4 --display-name="test4" --email=test4@example.com
    ${CEPH_BIN_DIR}radosgw-admin -c ${MY_CLUSTER_DIR}/ceph.conf user create --uid=test5 --display-name="test5" --email=test5@example.com
    ${CEPH_BIN_DIR}radosgw-admin -c ${MY_CLUSTER_DIR}/ceph.conf user create --uid=test6 --display-name="test6" --email=test6@example.com
    ${CEPH_BIN_DIR}radosgw-admin -c ${MY_CLUSTER_DIR}/ceph.conf user create --uid=test7 --display-name="test7" --email=test7@example.com
    ${CEPH_BIN_DIR}radosgw-admin -c ${MY_CLUSTER_DIR}/ceph.conf user create --uid=test8 --display-name="test8" --email=test8@example.com
}

function Create_Ceph_10_Users()
{
    mkdir -p ${MY_CLUSTER_DIR}
    cd ${MY_CLUSTER_DIR}

    ${CEPH_BIN_DIR}radosgw-admin -c ${MY_CLUSTER_DIR}/ceph.conf user create --uid=test1 --display-name="test1" --email=test1@example.com
    ${CEPH_BIN_DIR}radosgw-admin -c ${MY_CLUSTER_DIR}/ceph.conf user create --uid=test2 --display-name="test2" --email=test2@example.com
    ${CEPH_BIN_DIR}radosgw-admin -c ${MY_CLUSTER_DIR}/ceph.conf user create --uid=test3 --display-name="test3" --email=test3@example.com
    ${CEPH_BIN_DIR}radosgw-admin -c ${MY_CLUSTER_DIR}/ceph.conf user create --uid=test4 --display-name="test4" --email=test4@example.com
    ${CEPH_BIN_DIR}radosgw-admin -c ${MY_CLUSTER_DIR}/ceph.conf user create --uid=test5 --display-name="test5" --email=test5@example.com
    ${CEPH_BIN_DIR}radosgw-admin -c ${MY_CLUSTER_DIR}/ceph.conf user create --uid=test6 --display-name="test6" --email=test6@example.com
    ${CEPH_BIN_DIR}radosgw-admin -c ${MY_CLUSTER_DIR}/ceph.conf user create --uid=test7 --display-name="test7" --email=test7@example.com
    ${CEPH_BIN_DIR}radosgw-admin -c ${MY_CLUSTER_DIR}/ceph.conf user create --uid=test8 --display-name="test8" --email=test8@example.com
    ${CEPH_BIN_DIR}radosgw-admin -c ${MY_CLUSTER_DIR}/ceph.conf user create --uid=test9 --display-name="test9" --email=test7@example.com
    ${CEPH_BIN_DIR}radosgw-admin -c ${MY_CLUSTER_DIR}/ceph.conf user create --uid=test10 --display-name="test10" --email=test8@example.com    
}

function Create_User_Select()
{
    local deploy_now=0
    echo ""
    Echo_Yellow "You have 7 options for ceph and rados-gw:"
    echo ""
    echo "  1) Create  1 ceph users and keys."
    echo "  2) Create  2 ceph users and keys."
    echo "  3) Create  4 ceph users and keys."
    echo "  4) Create  6 ceph users and keys."
    echo "  5) Create  8 ceph users and keys."
    echo "  6) Create 10 ceph users and keys."
    Echo_Cyan "* 7) Exit. (default)"
    echo ""
    read -p "Enter your choice: [1-7] ? " CreateUserSelect

    echo ""
    case "${CreateUserSelect}" in
        1)
            Echo_Cyan "It will create 1 ceph users and keys."
            ;;
        2)
            Echo_Cyan "It will create 4 ceph users and keys."
            ;;
        3)
            Echo_Cyan "It will create 4 ceph users and keys."
            ;;
        4)
            Echo_Cyan "It will create 6 ceph users and keys."
            ;;
        5)
            Echo_Cyan "It will create 8 ceph users and keys."
            ;;
        6)
            Echo_Cyan "It will create 10 ceph users and keys."
            ;;
        *)
            Echo_Cyan "Don't create ceph users and key, and exit."
            CreateUserSelect=7
            ;;
    esac
    echo ""

    if [ "${CreateUserSelect}" == "1" ]; then
        Create_Ceph_1_Users
    elif [ "${CreateUserSelect}" == "2" ]; then
        Create_Ceph_2_Users
    elif [ "${CreateUserSelect}" == "3" ]; then
        Create_Ceph_4_Users
    elif [ "${CreateUserSelect}" == "4" ]; then
        Create_Ceph_6_Users
    elif [ "${CreateUserSelect}" == "5" ]; then
        Create_Ceph_8_Users
    elif [ "${CreateUserSelect}" == "6" ]; then
        Create_Ceph_10_Users
    else
        # do nothing and exit.
        exit
    fi
}

function Create_Ceph_Users()
{
    Create_User_Select
}
