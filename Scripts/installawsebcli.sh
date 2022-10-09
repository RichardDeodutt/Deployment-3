#!/bin/bash

#Richard Deodutt
#09/24/2022
#This script is meant to install the AWS EB CLI on the ubuntu user on ubuntu

#Source or import standard.sh
source libstandard.sh

#Home directory
Home='/home/ubuntu'

#Log file name for the AWS EB CLI installation
LogFileName="InstallAWSEBCLI.log"

#Set the log file location and name
setlogs

#The main function
main(){
    #Update local apt repo database
    aptupdatelog

    #Install python3-pip if not already
    aptinstalllog "python3-pip"

    #Change directory to the home folder
    cd $Home

    #As the ubuntu user install awsebcli with pip
    su - ubuntu -c "pip install awsebcli --upgrade --user > /dev/null 2>&1" && logokay "Successfully installed the AWS EB CLI for the ubuntu's user" || { logerror "Failure installing the AWS EB CLI for the ubuntu's user" && exiterror ; }

    #As the ubuntu user create a .bashrc file in the home folder
    su - ubuntu -c "cd && touch .bashrc" && logokay "Successfully created .bashrc for the ubuntu's user" || { logerror "Failure creating .bashrc for the ubuntu's user" && exiterror ; }

    #Add to the path of the ubuntu user the location where awsebcli is installed
    echo 'PATH=$PATH:$HOME/.local/bin' > '/home/ubuntu/.bashrc' && logokay "Successfully added the AWS EB CLI to ubuntu's user's PATH" || { logerror "Failure adding the AWS EB CLI to ubuntu's user's PATH" && exiterror ; }

    #Add it to path now also
    source '/home/ubuntu/.bashrc'
}

#Log start
logokay "Running the install AWS EB CLI script"

#Check for admin permissions
admincheck

#Call the main function
main

#Log successs
logokay "Ran the install AWS EB CLI script successfully"

#Exit successs
exit 0