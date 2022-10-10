#!/bin/bash

#Richard Deodutt
#09/22/2022
#This script is meant to install Jenkins on ubuntu

#Source or import standard.sh
source libstandard.sh

#Home directory
Home='/home/ubuntu'

#Log file name for jenkins installation
LogFileName="InstallJenkins.log"

#Set the log file location and name
setlogs

#The configuration for nginx
ConfigNginx="https://raw.githubusercontent.com/RichardDeodutt/Deployment-3/main/Configs/server-nginx-default"

#The main function
main(){
    #Adding the Keyrings if not already
    wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | gpg --batch --yes --dearmor -o /usr/share/keyrings/jenkins.gpg && logokay "Successfully installed jenkins keyring" || { logerror "Failure installing jenkins keyring" && exiterror ; }

    #Adding the repo to the sources of apt if not already
    sh -c 'echo deb [signed-by=/usr/share/keyrings/jenkins.gpg] http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list' && logokay "Successfully installed jenkins repo" || { logerror "Failure installing jenkins repo" && exiterror ; }

    #Update local apt repo database
    aptupdatelog

    #Install java if not already
    aptinstalllog "default-jre"

    #Install jenkins if not already
    aptinstalllog "jenkins"

    #Enable the Jenkins service if not already
    systemctl enable jenkins && logokay "Successfully enabled jenkins" || { logerror "Failure enabling jenkins" && exiterror ; }

    #Start the Jenkins service if not already
    systemctl start jenkins && logokay "Successfully started jenkins" || { logerror "Failure starting jenkins" && exiterror ; }

    #Install nginx if not already
    aptinstalllog "nginx"

    #Install curl if not already
    aptinstalllog "curl"

    #Download and set the nginx configuration
    curl -s $ConfigNginx | tee /etc/nginx/sites-enabled/default > /dev/null 2>&1 && logokay "Successfully Set Nginx" || { logerror "Failure Setting Nginx" && exiterror ; }

    #Restart the nginx service
    systemctl restart nginx && logokay "Successfully restarted nginx" || { logerror "Failure restarting nginx" && exiterror ; }
}

#Log start
logokay "Running the install jenkins script"

#Check for admin permissions
admincheck

#Call the main function
main

#Log successs
logokay "Ran the install jenkins script successfully"

#Exit successs
exit 0