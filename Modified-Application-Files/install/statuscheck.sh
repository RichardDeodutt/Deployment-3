#!/bin/bash

#Richard Deodutt
#10/10/2022
#This script is meant to do a status check of the system after the deployment.

#Source or import standard.sh
source libstandard.sh

#Home directory
Home='/home/ubuntu'

#Log file name for the status check
LogFileName="RunStatusCheck.log"

#Set the log file location and name
setlogs

#The main function
main(){
    #Install Screenfetch if not already
    aptinstalllog "screenfetch"
    #Log the Url-Shortener App Status
    systemctl status run-app --no-pager > /dev/null 2>&1 && log "$(echo "Run App Status" ; systemctl status run-app --no-pager)" || logwarning "Can't Check the Status of the Run App"
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