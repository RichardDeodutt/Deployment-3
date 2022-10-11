#!/bin/bash

#Richard Deodutt
#10/10/2022
#This script is meant to install everything the programs need as in the dependencies

#Source or import standard.sh
source libstandard.sh

#Home directory
Home='/home/ubuntu'

#Log file name
LogFileName="InstallApp.log"

#Log file location and name
LogFile=$Home/$LogFileName

#Path of the venv
Pathofvenv=$Home/"venv"

#The main function
main(){
    #Update local apt repo database
    aptupdatelog

    #Install python3 if not already
    aptinstalllog "python3"

    #Install python3-pip if not already
    aptinstalllog "python3-pip"

    #Install python3.10-venv if not already
    aptinstalllog "python3.10-venv"

    #Install git if not already
    aptinstalllog "git"

    #Install curl if not already
    aptinstalllog "curl"

    #Install pip venv enviormentent
    python3 -m venv $Pathofvenv && logokay "Successfully installed the python venv directory" || { logerror "Failure installing the python venv directory" && exiterror ; }

    #Activate the venv
    source $Pathofvenv/bin/activate && logokay "Successfully activated the python venv directory" || { logerror "Failure activating the python venv directory" && exiterror ; }

    #Install the python module flask
    pip install flask > /dev/null 2>&1 && logokay "Successfully installed the python module flask" || { logerror "Failure installing the python module flask" && exiterror ; }

    #Install the python module gunicorn
    pip install gunicorn > /dev/null 2>&1 && logokay "Successfully installed the python module gunicorn" || { logerror "Failure installing the python module gunicorn" && exiterror ; }

    #Deactivate the venv
    deactivate && logokay "Successfully deactivated the python venv directory" || { logerror "Failure deactivating the python venv directory" && exiterror ; }

    #Copy the run script to bin
    cp $Pathofvenv/install/run-app.sh /bin/run-app.sh && logokay "Successfully installed the script 'run-app.sh'" || { logerror "Failure installing the script 'run-app.sh'" && exiterror ; }

    #Copy the standard lib to bin
    cp $Pathofvenv/install/libstandard.sh /bin/libstandard.sh && logokay "Successfully installed the lib 'libstandard'" || { logerror "Failure installing the lib 'libstandard'" && exiterror ; }

    #Chmod the script to Executable
    chmod +x /bin/run-app.sh && logokay "Successfully made the script 'run-app.sh' executable" || { logerror "Failure making the script 'run-app.sh' executable" && exiterror ; }

    #Copy the systemd service to the rest of the services
    cp $Pathofvenv/install/run-app.service /etc/systemd/system/run-app.service && logokay "Successfully installed the service 'run-app.service'" || { logerror "Failure installing the service 'run-app.service'" && exiterror ; }

    #Enable the service
    systemctl enable run-app > /dev/null 2>&1 && logokay "Successfully enabled the service 'run-app.service'" || { logerror "Failure enabling the service 'run-app.service'" && exiterror ; }

    #Start the service
    systemctl start run-app > /dev/null 2>&1 && logokay "Successfully started the service 'run-app.service'" || { logerror "Failure starting the service 'run-app.service'" && exiterror ; }

    #Restart the service in the case of updates
    systemctl restart run-app > /dev/null 2>&1 && logokay "Successfully restarted the service 'run-app.service'" || { logerror "Failure restarting the service 'run-app.service'" && exiterror ; }
}

#Log start
logokay "Running the install app script"

#Check for admin permissions
admincheck

#Call the main function
main

#Log successs
logokay "Ran the install app script successfully"

#Exit successs
exit 0