#!/bin/bash

# About shell Echo_RGBs()
Color_Text()
{
    echo -e "\e[0;$2m$1\e[0m"
}

Echo_Red()
{
    Color_Text "$1" "31"
}

Echo_Green()
{
    Color_Text "$1" "32"
}

Echo_Yellow()
{
    Color_Text "$1" "33"
}

Echo_Blue()
{
    Color_Text "$1" "34"
}

Echo_Magenta()
{
    Color_Text "$1" "35"
}

Echo_Cyan()
{
    Color_Text "$1" "36"
}

# About shell Echo_RGBs_Ex()
Color_Text_Ex()
{
    echo -e "$1\e[0;$4m$2\e[0m$3"
}

Echo_Red_Ex()
{
    Color_Text_Ex "$1" "$2" "$3" "31"
}

Echo_Green_Ex()
{
    Color_Text_Ex "$1" "$2" "$3" "32"
}

Echo_Yellow_Ex()
{
    Color_Text_Ex "$1" "$2" "$3" "33"
}

Echo_Blue_Ex()
{
    Color_Text_Ex "$1" "$2" "$3" "34"
}

Echo_Magenta_Ex()
{
    Color_Text_Ex "$1" "$2" "$3" "35"
}

Echo_Cyan_Ex()
{
    Color_Text_Ex "$1" "$2" "$3" "36"
}

# About shell Echo_RGBs_Blod()
Color_Text_Blod()
{
    echo -e "\e[1;$2m$1\e[0m"
}

Echo_Red_Blod()
{
    Color_Text_Blod "$1" "31"
}

Echo_Green_Blod()
{
    Color_Text_Blod "$1" "32"
}

Echo_Yellow_Blod()
{
    Color_Text_Blod "$1" "33"
}

Echo_Blue_Blod()
{
    Color_Text_Blod "$1" "34"
}

Echo_Magenta_Blod()
{
    Color_Text_Blod "$1" "35"
}

Echo_Cyan_Blod()
{
    Color_Text_Blod "$1" "36"
}

# About shell Echo_RGBs_Blod_Ex()
Color_Text_Blod_Ex()
{
    echo -e "$1\e[1;$4m$2\e[0m$3"
}

Echo_Red_Blod_Ex()
{
    Color_Text_Blod_Ex "$1" "$2" "$3" "31"
}

Echo_Green_Blod_Ex()
{
    Color_Text_Blod_Ex "$1" "$2" "$3" "32"
}

Echo_Yellow_Blod_Ex()
{
    Color_Text_Blod_Ex "$1" "$2" "$3" "33"
}

Echo_Blue_Blod_Ex()
{
    Color_Text_Blod_Ex "$1" "$2" "$3" "34"
}

Echo_Magenta_Blod_Ex()
{
    Color_Text_Blod_Ex "$1" "$2" "$3" "35"
}

Echo_Cyan_Blod_Ex()
{
    Color_Text_Blod_Ex "$1" "$2" "$3" "36"
}

# About shell Echo_RGBs_HalfLight()
Color_Text_HL()
{
    echo -e "\e[2;$2m$1\e[0m"
}

Echo_Red_HL()
{
    Color_Text_HL "$1" "31"
}

Echo_Green_HL()
{
    Color_Text_HL "$1" "32"
}

Echo_Yellow_HL()
{
    Color_Text_HL "$1" "33"
}

Echo_Blue_HL()
{
    Color_Text_HL "$1" "34"
}

Echo_Magenta_HL()
{
    Color_Text_HL "$1" "35"
}

Echo_Cyan_HL()
{
    Color_Text_HL "$1" "36"
}

# About shell Echo_RGBs_HalfLight_Ex()
Color_Text_HL_Ex()
{
    echo -e "$1\e[2;$4m$2\e[0m$3"
}

Echo_Red_HL_Ex()
{
    Color_Text_HL_Ex "$1" "$2" "$3" "31"
}

Echo_Green_HL_Ex()
{
    Color_Text_HL_Ex "$1" "$2" "$3" "32"
}

Echo_Yellow_HL_Ex()
{
    Color_Text_HL_Ex "$1" "$2" "$3" "33"
}

Echo_Blue_HL_Ex()
{
    Color_Text_HL_Ex "$1" "$2" "$3" "34"
}

Echo_Magenta_HL_Ex()
{
    Color_Text_HL_Ex "$1" "$2" "$3" "35"
}

Echo_Cyan_HL_Ex()
{
    Color_Text_HL_Ex "$1" "$2" "$3" "36"
}

##
## This is a echo color test
##
Echo_Color_Test()
{
    echo ""
    Echo_Red "This is Red color."
    Echo_Red_HL "This is Red HL color."
    Echo_Red_Blod "This is Red blod color."
    echo ""

    Echo_Green "This is Green color."
    Echo_Green_HL "This is Green HL color."
    Echo_Green_Blod "This is Green blod color."
    echo ""

    Echo_Blue "This is Blue color."
    Echo_Blue_HL "This is Blue HL color."
    Echo_Blue_Blod "This is Blue blod color."
    echo ""

    Echo_Yellow "This is Yellow color."
    Echo_Yellow_HL "This is Yellow HL color."
    Echo_Yellow_Blod "This is Yellow blod color."
    echo ""

    Echo_Magenta "This is Magenta color."
    Echo_Magenta_HL "This is Magenta HL color."
    Echo_Magenta_Blod "This is Magenta blod color."
    echo ""

    Echo_Cyan "This is Cyan color."
    Echo_Cyan_HL "This is Cyan HL color."
    Echo_Cyan_Blod "This is Cyan blod color."
    echo ""
}

##
## This is a echo color extend mode test
##
Echo_Color_Ex_Test()
{
    local prefix_text=" |  <<<      "
    local suffix_text="      >>>  | "
    echo ""
    Echo_Red_Ex "${prefix_text}" "This is Red color.         " "${suffix_text}"
    Echo_Red_HL_Ex "${prefix_text}" "This is Red HL color.      " "${suffix_text}"
    Echo_Red_Blod_Ex "${prefix_text}" "This is Red blod color.    " "${suffix_text}"
    echo ""

    Echo_Green_Ex "${prefix_text}" "This is Green color.       " "${suffix_text}"
    Echo_Green_HL_Ex "${prefix_text}" "This is Green HL color.    " "${suffix_text}"
    Echo_Green_Blod_Ex "${prefix_text}" "This is Green blod color.  " "${suffix_text}"
    echo ""

    Echo_Blue_Ex "${prefix_text}" "This is Blue color.        " "${suffix_text}"
    Echo_Blue_HL_Ex "${prefix_text}" "This is Blue HL color.     " "${suffix_text}"
    Echo_Blue_Blod_Ex "${prefix_text}" "This is Blue blod color.   " "${suffix_text}"
    echo ""

    Echo_Yellow_Ex "${prefix_text}" "This is Yellow color.      " "${suffix_text}"
    Echo_Yellow_HL_Ex "${prefix_text}" "This is Yellow HL color.   " "${suffix_text}"
    Echo_Yellow_Blod_Ex "${prefix_text}" "This is Yellow blod color. " "${suffix_text}"
    echo ""

    Echo_Magenta_Ex "${prefix_text}" "This is Magenta color.     " "${suffix_text}"
    Echo_Magenta_HL_Ex "${prefix_text}" "This is Magenta HL color.  " "${suffix_text}"
    Echo_Magenta_Blod_Ex "${prefix_text}" "This is Magenta blod color." "${suffix_text}"
    echo ""

    Echo_Cyan_Ex "${prefix_text}" "This is Cyan color.        " "${suffix_text}"
    Echo_Cyan_HL_Ex "${prefix_text}" "This is Cyan HL color.     " "${suffix_text}"
    Echo_Cyan_Blod_Ex "${prefix_text}" "This is Cyan blod color.   " "${suffix_text}"
    echo ""
}
