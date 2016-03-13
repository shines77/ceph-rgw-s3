# ceph-rgw-s3

A shell script that is used to deploy Ceph, and configure for rados-rgw used to support S3 API environment.

# 说明

这是一个部署ceph和rados-gw的shell脚本, 可以在自己的虚拟机里配置成调用S3服务.

# 使用方法

直接执行

	./deploy.sh

即可部署和配置 ceph 和 rados-gw.

如果要启动 ceph 和 rados-gw, 可使用:

	./start.sh

类似的, 要停止 ceph 和 rados-gw, 可使用:

	./stop.sh

要创建用户的话, 可使用:

	./create_user.sh

然后可以看到 access_key 和 secret_key.

	{
		"user_id": "mona",
		"display_name": "Monika Singh",
		"email": "mona@example.com",
		"suspended": 0,
		"max_buckets": 1000,
		"auid": 0,
		"subusers": [],
		"keys": [
			{
				"user": "mona",
				"access_key": "TS1IUAJU5W3ZM2QVF8XB",
				"secret_key": "5N0CiXZmr0cyxzt3wKfmpv0G6XzwEeoZLJFBOOUV"
			}
		],
		"swift_keys": [],
		"caps": [],
		"op_mask": "read, write, delete",
		"default_placement": "",
		"placement_tags": [],
		"bucket_quota": {
			"enabled": false,
			"max_size_kb": -1,
			"max_objects": -1
		},
		"user_quota": {
			"enabled": false,
			"max_size_kb": -1,
			"max_objects": -1
		},
		"temp_url_keys": []
	}

RadosGW 的 civetweb 端口默认是8080.

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
