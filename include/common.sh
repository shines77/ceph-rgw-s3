#!/bin/bash

##
## Check whether the logon user is a root account?
##
function Check_Is_Root_Account()
{
    if [ $(id -u) != "0" ]; then
        Echo_Red "Error: You must logon a root account to run this lnamp script, please try again."
        exit 1
    fi
}

## Return a uuid string
function Get_UUID()
{
    echo "`uuidgen`"
}

## Get a char input
function Press_Start()
{
    echo ""
    echo "Press any key to start or Press Ctrl + C to cancel ..."
    OLDCONFIG=`stty -g`
    stty -icanon -echo min 1 time 0
    dd count=1 2>/dev/null
    stty ${OLDCONFIG}
    echo ""
}
