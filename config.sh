#!/bin/bash

# Your ceph cluster directory, default value is "/home/skyinno/my-cluster".
MY_CLUSTER_DIR="/home/skyinno/my-cluster"

# You can settings your ceph binary directory, example: "/home/git/ceph/src",
# if the value is empty, it is indicated that use the install path of ceph on the system dir, example: "/usr/local/bin" or "/usr/bin".
# You also can set the value that same to MY_CLUSTER_DIR, if the ceph binary dir is same to MY_CLUSTER_DIR.
CEPH_BIN_DIR=''

# The earsure code plugin dir, if the value is empty,
# it will use default value: "${CEPH_BIN_DIR}/lib/ceph/erasure-code".
ERASURE_CODE_DIR=""

# Ceph host name, example: "localhost",
# if the value is empty, it is indicated that use local hostname
CEPH_LOCAL_HOSTNAME=""
# Ceph host ip, example: "192.168.1.1",
# if the value is empty, it is indicated that use local host ip.
CEPH_LOCAL_HOSTIP=""
# Ceph port, default is: "6789",
CEPH_LOCAL_PORT=""

# Radosgw host, example: "localhost" or "192.168.1.1",
# if the value is empty, it is indicated that use local host ip.
CEPH_RADOSGW_HOST=""

# Radosgw's http server port, default is 8000, or example: "18000;18001;18002".
CIVETWEB_PORT="18000"
