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

