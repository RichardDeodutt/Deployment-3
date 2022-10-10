#!/bin/bash

#Richard Deodutt
#09/27/2022
#This script is meant to install the Jenkins agent dependencies on ubuntu

#Source or import standard.sh
source libstandard.sh

#Home directory
Home='/home/ubuntu'

#Log file name for jenkins installation
LogFileName="InstallAgent.log"

#Set the log file location and name
setlogs

#The main function
main(){
    #Update local apt repo database
    aptupdatelog

    #Install java if not already
    aptinstalllog "default-jre"

    #Install python3-pip if not already
    aptinstalllog "python3-pip"

    #Install python3.10-venv if not already
    aptinstalllog "python3.10-venv"

    #Install nginx if not already
    aptinstalllog "nginx"
}

#Log start
logokay "Running the install agent script"

#Check for admin permissions
admincheck

#Call the main function
main

#Log successs
logokay "Ran the install agent script successfully"

#Exit successs
exit 0