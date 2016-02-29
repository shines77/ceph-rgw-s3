#!/bin/bash

# Your ceph cluster directory
MY_CLUSTER_DIR='/home/skyinno/my-cluster/'

# You can settings your ceph binary directory, example "/home/git/ceph/src",
# if you want to use the ceph install on the system folder(/usr/bin, /usr/local/bin),
# you can set the value to a empty string, it's the default value.
# You also can set the value same to MY_CLUSTER_DIR, if the ceph binary dir is same to MY_CLUSTER_DIR.
CEPH_BIN_DIR=''

# You can 
CEPH_LOCAL_HOSTNAME=""
CEPH_LOCAL_HOSTIP=""
CEPH_LOCAL_PORT=""

CEPH_RADOSGW_HOST=""

# Radosgw's http server port, default is 8000.
CIVETWEB_PORT="8080"
