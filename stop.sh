#!/bin/bash

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

## stop.sh
killall radosgw
killall ceph-osd
killall ceph-mds
killall ceph-mon

echo ""
echo "All of ceph processes have been killed!"
echo ""
