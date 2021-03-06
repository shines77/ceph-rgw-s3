#!/bin/bash

##
## See: http://www.jb51.net/article/56585.htm
##
function Get_Local_HostName()
{
    local local_hostname="`hostname --fqdn`"
    echo "${local_hostname}"
}

function Get_Local_HostIP()
{
    local local_hostip="`/sbin/ifconfig -a | grep inet | grep -v 127.0.0.1 | grep -v inet6 | awk '{print $2}' | tr -d "addr:"`"
    echo "${local_hostip}"
}

function Get_Local_HostIP2()
{
    local local_hostip="`/sbin/ifconfig | grep -v 127.0.0.1 | sed -n '/inet addr/s/^[^:]*:\([0-9.]\{7,15\}\) .*/\1/p'`"
    echo "${local_hostip}"
}

function Test_Local_HostInfo()
{
    local local_hostname=$(Get_Local_HostName)
    local local_hostip=$(Get_Local_HostIP)

    echo "Get_Local_HostName = ${local_hostname}"
    echo "Get_Local_HostIP   = ${local_hostip}"
}
