
#!/bin/bash

. include/path.sh

# Set $MY_CLUSTER_DIR
if [[ -z "${MY_CLUSTER_DIR}" || "${MY_CLUSTER_DIR}" = "../" ]]; then
    MY_CLUSTER_DIR="${cur_dir}/../"
else
    if [ "${MY_CLUSTER_DIR}" = "./" ]; then
        MY_CLUSTER_DIR="${cur_dir}"
    fi
fi
MY_CLUSTER_DIR=$(Check_PathName ${MY_CLUSTER_DIR})

# Set $CEPH_BIN_DIR
if [ -z "${CEPH_BIN_DIR}" ]; then
    CEPH_BIN_DIR=""
    ERASURE_CODE_DIR="/usr/local/lib/ceph/erasure-code"
else
    if [ "${CEPH_BIN_DIR}" = "../" ]; then
        CEPH_BIN_DIR="${cur_dir}/../"
    else
        CEPH_BIN_DIR=$(Check_PathName ${CEPH_BIN_DIR})
        CEPH_BIN_DIR="${CEPH_BIN_DIR}/"
    fi
    ERASURE_CODE_DIR="${CEPH_BIN_DIR}lib/ceph/erasure-code"
fi

# Set $CEPH_LOCAL_HOSTNAME
if [ -z "${CEPH_LOCAL_HOSTNAME}" ]; then
    CEPH_LOCAL_HOSTNAME=$(Get_Local_HostName)
fi

# Set $CEPH_LOCAL_HOSTIP
if [ -z "${CEPH_LOCAL_HOSTIP}" ]; then
    CEPH_LOCAL_HOSTIP=$(Get_Local_HostIP)
fi

# Set $CEPH_LOCAL_PORT
if [ -z "${CEPH_LOCAL_PORT}" ]; then
    CEPH_LOCAL_PORT="6000"
fi

# Set $CEPH_MON_PORT
if [ -z "${CEPH_MON_PORT}" ]; then
    CEPH_MON_PORT="6789"
fi

# Set CEPH_RADOSGW_HOST
if [ -z "${CEPH_RADOSGW_HOST}" ]; then
    CEPH_RADOSGW_HOST=$(Get_Local_HostName)
fi

# Set CIVETWEB_PORT
if [ -z "${CIVETWEB_PORT}" ]; then
    CIVETWEB_PORT="8000"
fi
