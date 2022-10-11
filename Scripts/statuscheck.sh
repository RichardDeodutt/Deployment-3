#!/bin/bash

#Richard Deodutt
#09/26/2022
#This script is meant to do a status check of the system after the deployment.

#Source or import standard.sh
source libstandard.sh

#Home directory
Home='/home/ubuntu'

#Log file name for the status check
LogFileName="StatusCheck.log"

#Set the log file location and name
setlogs

#The main function
main(){
    #Install Screenfetch if not already
    aptinstalllog "screenfetch"
    #Log Java Status
    java -version > /dev/null 2>&1 && log "$(echo "Java Version" ; java -version 2>&1 | cat )" || logwarning "Can't Check the version of Java"
    #Log Jenkins Status
    systemctl status jenkins --no-pager > /dev/null 2>&1 && log "$(echo "Jenkins Status" ; systemctl status jenkins --no-pager)" || logwarning "Can't Check the Status of Jenkins"
    #Log Jenkins Secret Password if it exists(May not if jenkins is set up already and created a user on the webpage)
    log "$(echo "Secret Password")"
    cat /var/lib/jenkins/secrets/initialAdminPassword > /dev/null 2>&1 && logokay "$(cat /var/lib/jenkins/secrets/initialAdminPassword)" || logwarning "No Secret Password Found, May not be Needed"
    #Log the node version
    log "$(echo "The Node Version")"
    npm --version > /dev/null 2>&1 && logokay "$(node --version)" || logwarning "Can't Check the version of Node"
    #Log the npm version
    log "$(echo "The NPM Version")"
    npm --version > /dev/null 2>&1 && logokay "$(npm --version)" || logwarning "Can't Check the version of NPM"
    #Log Screenfetch
    log "$(echo "Screenfetch" ; screenfetch)"
}

#Log start
logokay "Running the status check script"

#Check for admin permissions
admincheck

#Call the main function
main

#Log successs
logokay "Ran the status check script successfully"

#Exit successs
exit 0