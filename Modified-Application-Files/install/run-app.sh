#!/bin/bash

#Richard Deodutt
#10/10/2022
#This script is meant to run the flask app

#Source or import standard.sh
source libstandard.sh

#Home directory
Home='/home/ubuntu'

#Log file name
LogFileName="AppRun.log"

#Log file location and name
LogFile=$Home/$LogFileName

#Path of the venv
Pathofvenv=$Home/"venv"

#The main function
main(){
    #Activate the venv
    source $Pathofvenv/bin/activate && logokay "Successfully activated the python venv directory" || { logerror "Failure activating the python venv directory" && exiterror ; }

    #Run the Flask App
    cd $Pathofvenv && gunicorn -w 4 --bind 0.0.0.0:8000 application:app && logokay "Successfully ran the app" || { logerror "Failure running the app" && exiterror ; }

    #Deactivate the venv
    deactivate && logokay "Successfully deactivated the python venv directory" || { logerror "Failure deactivating the python venv directory" && exiterror ; }
}

#Log start
logokay "Running the app script"

#Check for admin permissions
admincheck

#Call the main function
main

#Log successs
logokay "Ran the app script successfully"

#Exit successs
exit 0