#!/bin/bash

# Check the variant whether is a number?
function Check_Integer()
{
    if [ $# -lt 1 ]; then
        echo "Error: No input args."
        exit 1
    else
        # Filter integer numbers [0-9]
        local tmp=`echo $1 | sed 's/[0-9]//g'`
        # Filter integer sign
        tmp=`echo ${tmp} | sed 's/-//g'`
        tmp=`echo ${tmp} | sed 's/+//g'`
        [ -n "${tmp}" ] && { echo "Error: Args '"$1"' must be a integer!"; exit 1; }
    fi
}

# If the input argument is not a integer, will be return 0.
function Get_Integer()
{
    if [ $# -lt 1 ]; then
        echo "0"
        exit 1
    else
        # Filter integer numbers [0-9]
        local tmp=`echo $1 | sed 's/[0-9]//g'`
        # Filter integer sign
        tmp=`echo ${tmp} | sed 's/-//g'`
        tmp=`echo ${tmp} | sed 's/+//g'`
        [ -n "${tmp}" ] && { echo "0"; exit 1; }
        [ ! -n "${tmp}" ] && { echo $1; exit 0; }
    fi
}

# Get a integer ABS() value
function Integer_ABS()
{
    if [ $# -lt 1 ]; then
        echo "0"
    else
        local tmp=`echo $1 | sed 's/-//g'`
        tmp=`echo ${tmp} | sed 's/+//g'`
        echo ${tmp}
    fi
}

# Randomize number and randomize password
function Random_Number()
{
    local Min=$1
    local Max=$2
    local Temp=${Max}
    local RndNum=${RANDOM}*32768+${RANDOM}
    local RetNum=0
    Min=$(Get_Integer ${Min})
    if [ ${Min} -lt 0 ]; then
        Min=${Min}
        # Min=$(Integer_ABS ${Min})
    fi
    Max=$(Get_Integer ${Max})
    if [ ${Max} -lt 0 ]; then
        Max=${Max}
        # Max=$(Integer_ABS ${Max})
    fi
    if [ ${Min} -gt ${Max} ]; then
        Temp=${Max}
        Max=${Min}
        Min=${Temp}
    fi
    if [ $# -ge 3 ]; then
        echo "["${Min},${Max}"]:"
    fi
    if [ ${Min} -eq ${Max} ]; then
        ((RetNum=Min));
    else
        ((RetNum=RndNum%(Max-Min+1)+Min));
    fi
    echo ${RetNum}
}

# Generate the randomize password of specified length
function Generate_Random_Password()
{
    local Password_Chars_Default="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789~#=!@$"
    local Password_Chars=$1
    local Length_Min=14
    local Length_Max=14
    local Chars_Length=14
    local Len=1
    local Password=""
    if [ $# -eq 0 ]; then
        # When args = 0
        Password_Chars=${Password_Chars_Default}
    elif [ $# -eq 2 ]; then
        # When args = 2
        Length_Min=$2
        Length_Max=$2
        Chars_Length=$2
    elif [ $# -ge 3 ]; then
        # When args >= 3
        Length_Min=$2
        Length_Max=$3
        Chars_Length=$(Random_Number $Length_Min $Length_Max)
    fi
    # The password minimum length is 4.
    if [ ${Chars_Length} -lt 4 ]; then
        Chars_Length=4
    fi
    while [ "${Len}" -le "${Chars_Length}" ];
    do
        Password="${Password}${Password_Chars:$((${RANDOM}%${#Password_Chars})):1}"
        let Len+=1
    done

    if [ $# -ge 4 ]; then
        # When args >= 4
        Password="${Chars_Length}|${Password}"
    fi

    echo "${Password}"
}

function Random_Password_Base64()
{
    local Password_Chars="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789~#"
    local Password=$(Generate_Random_Password ${Password_Chars} $@)
    echo "${Password}"
}

function Random_Password_Wide()
{
    local Password_Chars="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz~!@#$%^&*()+="
    local Password=$(Generate_Random_Password ${Password_Chars} $@)
    echo "${Password}"
}

function Random_Password()
{
    local Password=$(Random_Password_Base64 $@)
    echo "${Password}"
}

function Test_System_Random_Number()
{
    local i=0
    local out=""
    for i in {1..10};
    do
        out=$RANDOM;
        echo $i,"System RANDOM [1-100000]",$out;
    done;
}

function Test_Random_Number()
{
    local i=0
    local out=""
    local RndRange=$(Random_Number 0 1000)
    echo "Random Number is [0-1000]: "$RndRange
    echo ""
    for i in {1..10};
    do
        out=$(Random_Number 2 "9999");
        echo $i,"Random_Number [2-9999]",$out;
    done;
}

function Test_Random_Password()
{
    local RndPassword=""
    echo "Random_Password_Base64():"
    echo ""
    RndPassword=$(Random_Password)
    echo "Random Password is [length = default]: "$RndPassword
    RndPassword=$(Random_Password 12)
    echo "Random Password is [length = 12]:      "$RndPassword
    RndPassword=$(Random_Password 12 14 1)
    echo "Random Password is [length = 12-14]:   "$RndPassword
    echo ""

    echo "Random_Password_Wide():"
    echo ""
    RndPassword=$(Random_Password_Wide)
    echo "Random Password is [length = default]: "$RndPassword
    RndPassword=$(Random_Password_Wide 12)
    echo "Random Password is [length = 12]:      "$RndPassword
    RndPassword=$(Random_Password_Wide 12 14 1)
    echo "Random Password is [length = 12-14]:   "$RndPassword
}

##
## Test Random functions
##
function Test_Random()
{
    Test_System_Random_Number
    echo ""
    Test_Random_Number
    echo ""
    Test_Random_Password
    echo ""
}
