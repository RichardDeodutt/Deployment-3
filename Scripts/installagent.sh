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

#The configuration for nginx
ConfigNginx="https://raw.githubusercontent.com/RichardDeodutt/Deployment-3/main/Configs/agent-nginx-default"

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

    #Install python3-gunicorn if not already
    aptinstalllog "python3-gunicorn"

    #Install curl if not already
    aptinstalllog "curl"

    #Download and set the nginx configuration
    curl -s $ConfigNginx | tee /etc/nginx/sites-enabled/default > /dev/null 2>&1 && logokay "Successfully Set Nginx" || { logerror "Failure Setting Nginx" && exiterror ; }

    #Restart the nginx service
    systemctl restart nginx && logokay "Successfully restarted nginx" || { logerror "Failure restarting nginx" && exiterror ; }
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