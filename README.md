# ceph-rgw-s3

A shell script is used to install or configure Ceph RGW, and configuration for used to support S3 API environment.

# 说明

这是一个配置ceph和radosgw的shell脚本, 可以在自己的虚拟机里配置成调用S3服务.

# 使用方法

直接执行

	./install.sh

即可.

要创建用户的话, 可执行:

	./create_user.sh

然后可以看到 access_key 和 secret_key.

RadosGW的vivetweb端口是8080.

相关的配置查看 ./config.sh 里的定义:

	#!/bin/bash

	MY_CLUSTER_DIR='/home/skyinno/my-cluster/'

	CEPH_LOCAL_HOSTNAME=""
	CEPH_LOCAL_HOSTIP=""
	CEPH_LOCAL_PORT=""

	CEPH_RADOSGW_HOST=""
	CIVETWEB_PORT="8080"

然后在cmd终端里执行:

	export S3_ACCESS_KEY_ID={access_key}
	export S3_SECRET_ACCESS_KEY={secret_key}
	export S3_HOSTNAME={你的虚拟机IP}:8080

然后运行s3客户端:

	./s3 -u list

即可.
