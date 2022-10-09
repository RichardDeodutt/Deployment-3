#!/bin/bash

#Richard Deodutt
#09/25/2022
#This script is meant to install the Cypress dependencies

#Source or import standard.sh
source libstandard.sh

#Home directory
Home='/home/ubuntu'

#Log file name for the Cypress dependencies installation
LogFileName="InstallCyDepends.log"

#Set the log file location and name
setlogs

#The main function
main(){
    #Update local apt repo database
    aptupdatelog

    #Install nodejs if not already
    aptinstalllog "nodejs"

    #Install nodejs if not already
    aptinstalllog "npm"

    #Install libgtk2.0-0 if not already
    aptinstalllog "libgtk2.0-0"

    #Install libgtk-3-0 if not already
    aptinstalllog "libgtk-3-0"

    #Install libgbm-dev if not already
    aptinstalllog "libgbm-dev"

    #Install libnotify-dev if not already
    aptinstalllog "libnotify-dev"

    #Install libgconf-2-4 if not already
    aptinstalllog "libgconf-2-4"

    #Install libnss3 if not already
    aptinstalllog "libnss3"

    #Install libxss1 if not already
    aptinstalllog "libxss1"

    #Install libasound2 if not already
    aptinstalllog "libasound2"

    #Install libxtst6 if not already
    aptinstalllog "libxtst6"

    #Install xauth if not already
    aptinstalllog "xauth"

    #Install xvfb if not already
    aptinstalllog "xvfb"
}

#Log start
logokay "Running the install Cy Depends script"

#Check for admin permissions
admincheck

#Call the main function
main

#Log successs
logokay "Ran the install Cy Depends script successfully"

#Exit successs
exit 0