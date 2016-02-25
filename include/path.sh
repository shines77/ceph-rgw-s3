#!/bin/bash

#
# Mkdir full path recursive
#
#   See: http://cloudmail.iteye.com/blog/1520560
#
# or
#   mkdir -p project/{bin,demo/stat/a,doc/{html,info,pdf},lib/ext,src}
#
#   See: http://khaozi.blog.51cto.com/952782/1113888
#
function Mkdir_Recur()
{
    local sDirName=$1
    if [[ -z ${sDirName} || "${sDirName}" = "/" ]]; then
        return
    fi

    local sParentDir=`dirname ${sDirName}`
    Mkdir_Recur $sParentDir

    if [ ! -d ${sDirName} ]; then
        Echo_Cyan "mkdir ${sDirName}"
        mkdir ${sDirName} || exit -1
    else
        Echo_Magenta "dir [${sDirName}] has exists."
    fi
}

function Test_Mkdir_Recur()
{
    echo ""
    Mkdir_Recur /home/guozi/git/lnmp_shell/
    echo ""
    Mkdir_Recur /home/guozi/git_tmp/lnmp_shell_test
    echo ""

    rm -r -f /home/guozi/git/lnmp_shell
    rm -r -f /home/guozi/git_tmp/lnmp_shell_test
}

# Check the path, if the last char is '/', remove the last char '/'.
function Check_PathName()
{
    local sPathName=$1
    if [[ -z ${sPathName} || "${sPathName}" = "/" ]]; then
        sPathName="/"
    else
        local sLength=${#sPathName}
        local sLastChar=""
        let sLength-=1
        sLastChar=${sPathName:${sLength}:1}
        # If the last char is '/', remove the '/'.
        while [ "${sLastChar}" = "/" ];
        do
            sPathName=${sPathName:0:${sLength}}
            sLength=${#sPathName}
            if [ ${sLength} -ge 1 ]; then
                # If the sPathName length is greater or equal 1, remove last char.
                let sLength-=1
                sLastChar=${sPathName:${sLength}:1}
            else
                # If the sPathName length is lesser 1, the end.
                sLastChar=""
            fi
        done
    fi
    echo ${sPathName}
}

# Check the path, if the last char is '/', remove the last char '/'.
function Check_PathName2()
{
    local sPathName=$1
    if [[ -z ${sPathName} || "${sPathName}" = "/" ]]; then
        sPathName="/"
    else
        local sParentPath=`dirname ${sPathName}`
        local sBaseName=`basename ${sPathName}`
        if [ "${sParentPath}" = "/" ]; then
            if [ "/${sBaseName}" != "${sPathName}" ]; then
                sPathName="/${sBaseName}"
            fi
        else
            if [ "${sParentPath}/${sBaseName}" != "${sPathName}" ]; then
                sPathName="${sParentPath}/${sBaseName}"
            fi
        fi
    fi   
    echo ${sPathName}
}

# Check the path, if the first char is not '/', add '/' to it.
function Check_PathName_Head()
{
    local sPathName=$1
    if [[ -z ${sPathName} || "${sPathName}" = "/" ]]; then
        sPathName="/"
    else
        sPathName=$1
    fi
    echo "Check_PathName_Head() result is:"
    echo ${sPathName}
}

function Test_CheckPathName()
{
    echo "------------------------------------------------"
    echo ""
    echo "Check_PathName() Test:"
    echo ""
    Check_PathName "/home/wwwroot/default"
    Check_PathName "/home/wwwroot/default/"
    Check_PathName "/home/wwwroot/default//"
    Check_PathName "/usr"
    Check_PathName "/"
    Check_PathName ""
    echo ""
    echo "------------------------------------------------"
    echo ""
    echo "Check_PathName2() Test:"
    echo ""
    Check_PathName2 "/home/wwwroot/default"
    Check_PathName2 "/home/wwwroot/default/"
    Check_PathName2 "/home/wwwroot/default//"
    Check_PathName2 "/usr"
    Check_PathName2 "/"
    Check_PathName2 ""
    echo ""
    echo "------------------------------------------------"
}
