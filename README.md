# Deployment-3

Set up a CI/CD pipeline from start to finish using a Jenkins server and Jenkins agent in different VPCs.

Using Elastic Beanstalk and customizing the pipeline. 

Deploying a [url-shortener](https://github.com/RichardDeodutt/kuralabs_deployment_3) Flask app.


# Objective: 

Deployment 3: Flask App

Objective: Learn how to deploy to your own VPC

● Be sure to follow instructions.

● After you have successfully deployed your application to your VPC, add to the pipeline and diagram.

● Document the process and any issues you run into while setting up the deployment and what you did to fix it.

● Lastly save your documentation and diagram into your repository and submit the link to your repository.

Take away: You will understand the purpose of a deploying to your own VPC.

Repo link: https://github.com/kura-labs-org/kuralabs_deployment_3.git

# Notes before starting

- These instructions use AWS. 

- These instructions are for the AWS Ubuntu image. They assume you are running the commands as the 'ubuntu' user. 

- These instructions assume you are using a jenkins server and a jenkins agent to do all the work. 

- There are some shortcuts in the shortcut section to save time. It may be a good idea to check it first. 

# Instructions

## Step 1: Prepare the Jenkins server EC2 if you don't have one

<details>

<summary>Step by Step</summary>

- Create/Launch an EC2 using the AWS Console in your region of choice, `Asia Pacific (Tokyo) or ap-northeast-1` in my case. 

- Set the `Name and tags` `Name` to anything you want, `Application and OS Images (Amazon Machine Image)` to Ubuntu 64-bit (x86), `Instance type` to t2.micro. 

- Set the `Key pair(login)` to any keypair you have access to or create one. `Network Settings` set the security group to one with ports 80 and 22 open or create one with those ports open. For `Network` use the default VPC and network settings. Launch with `default settings` for the rest is fine. 

- `SSH or connect` to the ec2 when it is running. 

    Example below: 

    ```
    ssh -i ~/.ssh/keyfile.pem root@18.179.26.45
    ```
    <details>

    <summary>Single Commands</summary>

    - `Download` the `jenkins keyring` for the package repository source list. 

        Example below: 

        ```
        wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo gpg --batch --yes --dearmor -o /usr/share/keyrings/jenkins.gpg
        ```

    - `Install` the `jenkins keyring` to the package repository source list. 

        Example below: 

        ```
        sudo sh -c 'echo deb [signed-by=/usr/share/keyrings/jenkins.gpg] http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
        ```

    - `Update` the package repository source list. 

        Example below: 

        ```
        sudo apt update
        ```

    - `Install` the `apt` packages `default-jre`. 

        Example below: 

        ```
        sudo apt install -y default-jre
        ```

    - `Install` the `apt` packages `jenkins`. 

        Example below: 

        ```
        sudo apt install -y jenkins
        ```

    - `Install` the `apt` packages `nginx`. 

        Example below: 

        ```
        sudo apt install -y nginx
        ```

    - `Install` the `apt` packages `curl`. 

        Example below: 

        ```
        sudo apt install -y curl
        ```

    - `Edit` /etc/nginx/sites-enabled/default to look like the following or `Download` and `Set` the nginx configuration. 

        <details>

        <summary>Config</summary>

        - `/etc/nginx/sites-enabled/default` file. 

            Example below: 

            ```
            sudo nano /etc/nginx/sites-enabled/default
            ```

            ```
            server {
                    listen 80;

                    root /var/www/html;

                    index index.html index.htm index.nginx-debian.html;

                    server_name _;

                    location / {
                            proxy_pass http://127.0.0.1:8080;
                            proxy_set_header Host $host;
                            proxy_set_header x-Forward-For $proxy_add_x_forwarded_for;
                    }
            }
            ```

        </details>

        <details>

        <summary>Download and Set</summary>

        - `/etc/nginx/sites-enabled/default` file. 

            Example below: 

            ```
            sudo curl -s "https://raw.githubusercontent.com/RichardDeodutt/Deployment-3/main/Configs/server-nginx-default" | sudo tee /etc/nginx/sites-enabled/default > /dev/null 2>&1
            ```

        </details>

    - `Restart` nginx

        Example below: 

        ```
        sudo systemctl restart nginx
        ```

    - `Get` the secret password and save it for future use. 

        Example below: 

        ```
        sudo cat /var/lib/jenkins/secrets/initialAdminPassword
        ```

    </details>

    <details>

    <summary>One Liner</summary>

    - `One Liner` to do do everything above at once. 

        Example below: 

        ```
        wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo gpg --batch --yes --dearmor -o /usr/share/keyrings/jenkins.gpg && sudo sh -c 'echo deb [signed-by=/usr/share/keyrings/jenkins.gpg] http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list' && sudo apt update && sudo apt install -y default-jre && sudo apt install -y jenkins && sudo apt install -y nginx && sudo apt install -y curl && sudo curl -s "https://raw.githubusercontent.com/RichardDeodutt/Deployment-3/main/Configs/server-nginx-default" | sudo tee /etc/nginx/sites-enabled/default > /dev/null 2>&1 && sudo systemctl restart nginx && sudo cat /var/lib/jenkins/secrets/initialAdminPassword
        ```

    </details>

</details>

## Step 2: Connect GitHub to the Jenkins server

<details>

<summary>Step by Step</summary>

- Create/Generate a [personal access token in GitHub](https://github.com/settings/tokens) for the Jenkins server and webhook if you don't have one. I added all the `repo`, `admin:repo_hook` and `notifications` permissions. When done save the token for future use. 

- Fork the [deployment repository](https://github.com/kura-labs-org/kuralabs_deployment_3) and using this forked repository connect it to the Jenkins server webhook in the settings of the newly forked repository. 

- Connect the webhook by configuring the setting as the following. 

    <details>

    <summary>Settings</summary>

    - The `Payload URL` to your Jenkins server webhook. 

        Example `Payload URL`
        ```
        http://35.77.201.219/github-webhook/
        ```
    
    - The `Content type` to application/json. 
    
    - The `Which events would you like to trigger this webhook?` to 'Send me everything.'. 
    
    - The `Active` checkbox to checked. 

    </details>
    
- Then when everything is set click `Add webhook` to connect the forked repository to the Jenkins server webhook. 

</details>

## Step 3: Create a VPC with a Public Subnet

<details>

<summary>Step by Step</summary>

- Navigate to the `VPC` section on the AWS services list from the AWS Console and click `Create VPC`. 

- Under `Resources to create` select VPC only and under `Name tag - optional` enter a name for the VPC to recognize it easier. 

- Under `IPv4 CIDR block` leave it at IPv4 CIDR manual input and under `IPv4 CIDR` enter a cider such as `172.25.0.0/16`. 

- Everything else should be default so click `Create VPC`. 

- Once the VPC is created click on `Subnets` to go to the subnets section then click `Create subnet` and under `VPC ID` select the VPC you just created. 

- Under `Subnet name` enter a name for the subnet to recognize it easier. Under `Availability Zone` select any of them as it does not matter for now. For `IPv4 CIDR block` enter a cidr block such as `172.25.0.0/18`. 

- Everything else should be default so click `Create subnet` to create the subnet. 

- The route table should have automatically been created and we don't need to touch it so leave it alone. 

- Once the subnet is created click on `Internet gateways` to go to the Internet gateways section then if a internet gateway is not already attached to your created VPC then click `Create internet gateway`.

- Under `Name tag` enter a name for the internet gateway to recognize it easier. Once done click `Create internet gateway`. Once created attach it to your VPC to give your VPC internet. 

</details>


## Step 4: Prepare the Jenkins agent EC2 if you don't have one

<details>

<summary>Step by Step</summary>

- Create/Launch an EC2 using the AWS Console in your region of choice, `Asia Pacific (Tokyo) or ap-northeast-1` in my case. 

- Set the `Name and tags` `Name` to anything you want, `Application and OS Images (Amazon Machine Image)` to Ubuntu 64-bit (x86), `Instance type` to t2.micro. 

- Set the `Key pair(login)` to any keypair you have access to or create one. For `Network` use a different VPC than the default VPC and a public subnet and make sure `Auto-assign public IP` is enabled. `Network Settings` set the security group to one with ports 80 and 22 open or create one with those ports open. Launch with `default settings` for the rest is fine. 

- `SSH or connect` to the ec2 when it is running. 

    Example below: 

    ```
    ssh -i ~/.ssh/keyfile.pem root@18.180.26.45
    ```

    <details>

    <summary>Single Commands</summary>

    - `Update` the package repository source list. 

        Example below: 

        ```
        sudo apt update
        ```

    - `Install` the `apt` packages `default-jre`. 

        Example below: 

        ```
        sudo apt install -y default-jre
        ```

    - `Install` the `apt` packages `python3-pip`. 

        Example below: 

        ```
        sudo apt install -y python3-pip
        ```

    - `Install` the `apt` packages `python3.10-venv`. 

        Example below: 

        ```
        sudo apt install -y python3.10-venv
        ```

    - `Install` the `apt` packages `nginx`. 

        Example below: 

        ```
        sudo apt install -y nginx

    - `Edit` /etc/nginx/sites-enabled/default to look like the following or `Download` and `Set` the nginx configuration. 

        <details>

        <summary>Config</summary>

        - `/etc/nginx/sites-enabled/default` file. 

            Example below: 

            ```
            sudo nano /etc/nginx/sites-enabled/default
            ```

            ```
            server {
                    listen 80;

                    root /var/www/html;

                    index index.html index.htm index.nginx-debian.html;

                    server_name _;

                    location / {
                            proxy_pass http://127.0.0.1:8000;
                            proxy_set_header Host $host;
                            proxy_set_header x-Forward-For $proxy_add_x_forwarded_for;
                    }
            }
            ```

        </details>

        <details>

        <summary>Download and Set</summary>

        - `/etc/nginx/sites-enabled/default` file. 

            Example below: 

            ```
            sudo curl -s "https://raw.githubusercontent.com/RichardDeodutt/Deployment-3/main/Configs/agent-nginx-default" | sudo tee /etc/nginx/sites-enabled/default > /dev/null 2>&1
            ```

        </details>

    - `Restart` nginx

        Example below: 

        ```
        sudo systemctl restart nginx
        ```

    </details>

    <details>

    <summary>One Liner</summary>

    - `One Liner` to do do everything above at once. 

        Example below: 

        ```
        sudo apt update && sudo apt install -y default-jre && sudo apt install -y python3-pip && sudo apt install -y python3.10-venv && sudo apt install -y nginx && sudo curl -s https://raw.githubusercontent.com/RichardDeodutt/Deployment-3/main/Configs/agent-nginx-default | sudo tee /etc/nginx/sites-enabled/default > /dev/null 2>&1
        ```

    </details>

</details>

## Step 5: Update the forked repository

<details>

<summary>Step by Step</summary>

- This is to update the forked [deployment repository](https://github.com/RichardDeodutt/kuralabs_deployment_3) using [this repository](https://github.com/RichardDeodutt/Deployment-3). 

    <details>

    <summary>Step by Step</summary>

    - `Clone or download` [this repository](https://github.com/RichardDeodutt/Deployment-3) to get the files locally on your computer. 

        Example below: 

        ```
        git clone git@github.com:RichardDeodutt/Deployment-3.git
        ```

    - `Clone your forked repository` in my case that would be https://github.com/RichardDeodutt/kuralabs_deployment_3 if you have not already done so to have it locally on your computer. 

        Example below: 

        ```
        git clone git@github.com:RichardDeodutt/kuralabs_deployment_3.git
        ```

    - `Everything` in the folder [Modified-Application-Files](https://github.com/RichardDeodutt/Deployment-3/tree/main/Modified-Application-Files) should be `copied over` to the `root` of your forked repository. In my case that would be https://github.com/RichardDeodutt/kuralabs_deployment_3 and it should replace and overwrite the existing files there. 

        Example below: 

        ```
        cp -a Deployment-3/Modified-Application-Files/* kuralabs_deployment_3/
        ```

    - You may want to edit the [Jenkinsfile](https://github.com/RichardDeodutt/Deployment-3/blob/main/Modified-Application-Files/Jenkinsfile) on your forked repository to have the `Deploy` stage use the region of your choice in my case I selected ap-northeast-1.

    - Once these changes are made and the newly forked repository is `patched` `commit` and `push` these changes to make sure they are on your `online GitHub repository` as in the website. 

        Example below: 

        ```
        git add .
        ```

        ```
        git commit -m "Update"
        ```

        ```
        git push
        ```

    </details>

    <details>

    <summary>One Liner</summary>

    - `One Liner` to do do everything above at once. 

        Example below: 

        ```
        git clone git@github.com:RichardDeodutt/Deployment-3.git ; git clone git@github.com:RichardDeodutt/kuralabs_deployment_3.git ; cp -a Deployment-3/Modified-Application-Files/* kuralabs_deployment_3/ && cd kuralabs_deployment_3 && git add . && git commit -m "Update" && git push && cd ..
        ```

    </details>

</details>

## Step 6: Configure the Jenkins server

<details>

<summary>Step by Step</summary>

- Navigate to the Jenkins page using the url in a browser. 

    Example URL
    ```
    http://35.77.201.219/
    ```

- Enter the `secret password or initial admin password` you saved earlier or get it again and enter it then click Continue. 

    Example below: 

    ```
    sudo cat /var/lib/jenkins/secrets/initialAdminPassword
    ```

- For the `Customize Jenkins page` just click Install suggested plugins and wait for it to install the plugins `which may take some time`. 

- Once that is done you will have a `Create First Admin User` page so fill out that page and save the information for future logins then click Save and Continue. 

- After that is a `Instance Configuration` page where the default `Jenkins URL` should be correct already is similar to `http://35.77.201.219/` so click Save and Finish. 

- The next page is the `Jenkins is ready!` page where you just click Start using Jenkins to finish configuring the Jenkins server and go to the home page. 

</details>

## Step 7: Add the Jenkins agent node to the Jenkins server

<details>

<summary>Step by Step</summary>

- In the Jenkins server homepage click `Build Executor Status` to go to the Manage nodes and clouds page of the Jenkins server then when it loads the page click `+ New Node` on the next page when it loads under `Node name` enter a name for the node to recognize it easier. Under `Type` select `Permanent Agent` and click `Create`. 

- When the `Node` configuration options load enter the following. 

    <details>

    <summary>Settings</summary>

    - Under `Name` enter a name for the Agent in my case I used Jenkins-Agent if it's not there already. Under `Description` enter a description for the Agent. 

    - Under `Remote root directory` enter the following. Which is the working directory for the Jenkins agent. 

        Example below: 

        ```
        /home/ubuntu/agent
        ```

    - Under `Labels` enter the following. 

        Example below: 

        ```
        linux ubuntu ec2
        ```

    - Under `Usage` select Only build jobs with label expressions matching this node. Under `Launch method` select Launch agents via SSH. Under `Host` enter the public IP of the Jenkins agent instance. 

    - Under `Credentials` where it says `- none -` under it is `+ Add` click it to open the dropdown menu and select the `Jenkins` option. When the popup loads under `Kind` select SSH Username with private key then when it loads under `Username` enter ubuntu then under `Private Key` select `Enter directly` and then click `Add`. In the textarea that appears copy and paste the contents of your `AWS SSH pem keyfile` to get it you can just `cat` the file and copy it from the terminal. Once the key is entered click Add to save it. If you don't have a keyfile you can create one in the AWS Console and download it then do this step. 

        Example below: 

        ```
        cat ~/.ssh/keyfile.pem
        ```

    - Under `EC2 Key Pair's Private Key` where it says `- none -` click it to open the dropdown menu and select the `EC2 Key Pair's Private Key` you just added. 

    - Under `Host Key Verification Strategy` select Non verifying Verification Strategy from the dropdown menu. Under `Availability` select Keep this agent online as much as possible. 

- Once the done click `Save`. 

</details>

## Step 8: Create a Multibranch Pipeline for the forked repository

<details>

<summary>Step by Step</summary>

- In the Jenkins server homepage click `New Item` to create a new pipeline then when it loads the page enter a `item name` in my case I named it `Deployment-3` and then select `Multibranch Pipeline` clicking `OK` once done. 

- On the Configuration page for the new pipeline enter the following settings. 

    <details>

    <summary>Settings</summary>

    - On `Branch Sources` click `Add source` and select `GitHub`. On the new `GitHub section` under `Credentials` click `+ Add` and select `Jenkins`. When the popup loads under `Username` enter your exact GitHub username then under `Password` enter your exact [personal access token in GitHub](https://github.com/settings/tokens) you created and saved earlier then click `Add` to add your GitHub credentials to this Jenkins server. 
    
    - Under `Credentials` where it says `- none -` click it to open the dropdown menu and select the GitHub credentials you just added. 
    
    - Where it says `Repository HTTPS URL` under it enter your forked repository URL in my case it would be https://github.com/RichardDeodutt/kuralabs_deployment_3 then click `Validate`. It should say it's ok. 

        Example below: 

        ```
        Credentials ok. Connected to https://github.com/RichardDeodutt/kuralabs_deployment_3.
        ```
    
    - This `may not be needed` but if you created `more branches` in your fork but want to work with one you can scroll down until you see `Property strategy`. Above that should be a `Add` button, click that and select `Filter by name (with wildcards)`. Under Include enter `main` and use wildcards or * to select and exclude unwated branches in my case I had a `original` branch so under `Exclude` I entered `o*` to exclude it. 

    </details>

- Once the pipeline is configured click `Apply` and `Save`. 

</details>

## Additions from Deployment-2

- Add another test. 

    <details>

    <summary>Another Test</summary>

    - Stage below: 

        ```
        stage ('Pytest') {
            steps {
            sh '''#!/bin/bash
                source testenv/bin/activate
                py.test --verbose --junit-xml test-reports/pytest-results.xml
                '''
            }
            post{
            always {
                junit 'test-reports/pytest-results.xml'
            }
            }
        }
        ```

    - Added Test [Pytest](https://github.com/RichardDeodutt/Deployment-3/blob/main/Modified-Application-Files/test_pages.py). 

    </details>

- Add a way to notify you. 

    <details>

    <summary>Notifications</summary>

    - Download and Install [catlight](https://catlight.io/downloads). 

    - Add a `Connection` to Jenkins and enter the `Jenkins server url` then enter your credentials, the `username` and `password` you created and connect. 

    - Once connected select the projects you want `to get notifications from` and Save. 

    - It will send a desktop notification when a build `fails or passes`. 

    <details>

    <summary>Dashboard</summary>

    <br>

    <p align="center">
    <a href="https://github.com/RichardDeodutt/Deployment-3/blob/main/Images/Dashboard.png"><img src="https://github.com/RichardDeodutt/Deployment-3/blob/main/Images/Dashboard.png" />
    </p>

    </details>

    <details>

    <summary>Notifications</summary>

    <br>

    <p align="center">
    <a href="https://github.com/RichardDeodutt/Deployment-3/blob/main/Images/Notifications.png"><img src="https://github.com/RichardDeodutt/Deployment-3/blob/main/Images/Notifications.png" />
    </p>

    </details>

    <details>

    <summary>Broken</summary>

    <br>

    <p align="center">
    <a href="https://github.com/RichardDeodutt/Deployment-3/blob/main/Images/Broken.png"><img src="https://github.com/RichardDeodutt/Deployment-3/blob/main/Images/Broken.png" />
    </p>

    </details>

    </details>

- Use Cypress for testing. 

    <details>

    <summary>E2E Test with Cypress</summary>

    - Stages below: 

        ```
        stage ('Build Tools') {
            steps {
            sh '''#!/bin/bash
            source testenv/bin/activate
            node --max-old-space-size=100 /usr/bin/npm install --save-dev cypress@7.6.0
            /usr/bin/npx cypress verify
            '''
            }
        }
        ```

        ```
        stage ('Deploy') {
            steps {
            sh '''#!/bin/bash
                cd && sudo rm -r venv ; curl -s -O https://raw.githubusercontent.com/RichardDeodutt/kuralabs_deployment_3/main/appdeployment.sh && sudo chmod +x appdeployment.sh && sudo ./appdeployment.sh
                '''
            }
        }
        ```

        ```
        stage ('Cypress E2E') {
            steps {
            sh '''#!/bin/bash
                source testenv/bin/activate
                NO_COLOR=1 /usr/bin/npx cypress run --config video=false --spec cypress/integration/test.spec.js
                '''
            }
            post{
            always {
                junit 'test-reports/cypress-results.xml'
            }
            }
        }
        ```

    - Added Test [Cypress](https://github.com/RichardDeodutt/Deployment-3/blob/main/Modified-Application-Files/cypress/integration/test.spec.js). 

    - Added Config [Cypress](https://github.com/RichardDeodutt/Deployment-3/blob/main/Modified-Application-Files/cypress.json). 

    - Modified Fixed [Jenkinsfile](https://github.com/RichardDeodutt/Deployment-3/blob/main/Modified-Application-Files/Jenkinsfile). 

    </details>

- Add a linter. 

    <details>

    <summary>Linter</summary>

    - Stage below: 

        ```
        stage ('Pylint') {
            steps {
            sh '''#!/bin/bash
                source testenv/bin/activate
                pylint --output-format=text,pylint_junit.JUnitReporter:test-reports/pylint-results.xml application.py
                '''
            }
            post{
            always {
                junit 'test-reports/pylint-results.xml'
            }
            }
        }
        ```

    - Modified Pip [Requirements](https://github.com/RichardDeodutt/Deployment-3/blob/main/Modified-Application-Files/requirements.txt). 

    - Modified Fixed [Application](https://github.com/RichardDeodutt/Deployment-3/blob/main/Modified-Application-Files/application.py). 

    </details>

- Change something on the application front. 

    <details>

    <summary>Changes</summary>

    - Modified Template [Base](https://github.com/RichardDeodutt/Deployment-3/blob/main/Modified-Application-Files/templates/base.html). 

    - Modified Template [Home](https://github.com/RichardDeodutt/Deployment-3/blob/main/Modified-Application-Files/templates/home.html). 

    - Modified Style [CSS](https://github.com/RichardDeodutt/Deployment-3/blob/main/Modified-Application-Files/static/style.css). 

    <details>

    <summary>Makeover</summary>

    <br>

    <p align="center">
    <a href="https://github.com/RichardDeodutt/Deployment-3/blob/main/Images/Makeover.png"><img src="https://github.com/RichardDeodutt/Deployment-3/blob/main/Images/Makeover.png" />
    </p>

    </details>

    </details>

## Pipeline and VPC

- Diagram of the pipeline and VPC. 

    <details>

    <summary>Pipeline and VPC</summary>

    <br>

    <p align="center">
    <a href="https://github.com/RichardDeodutt/Deployment-3/blob/main/Images/Pipeline.png"><img src="https://github.com/RichardDeodutt/Deployment-3/blob/main/Images/Pipeline.png" />
    </p>

    </details>

## Software Stack

- Type of software stack used. 

    <details>

    <summary>Software Stack</summary>

    <br>

    <p align="center">
    <a href="https://github.com/RichardDeodutt/Deployment-3/blob/main/Images/Stack.png"><img src="https://github.com/RichardDeodutt/Deployment-3/blob/main/Images/Stack.png" />
    </p>

    </details>

## Documentation

- Documentation of everything. 

    <details>

    <summary>Documentation</summary>

    <br>

    - [Documentation](https://github.com/RichardDeodutt/Deployment-3/blob/main/README.md). 

    </details>

# Shortcuts

## Starting from scratch

### Deploy everything in parts

<details>

<summary>Jenkins Server</summary>

- Jenkins Server Part

    - You can use my [jenkins deployment script](https://github.com/RichardDeodutt/Deployment-3/blob/main/Deployment-Scripts/jenkinsdeployment.sh) during EC2 creation by copying and pasting it in the userdata field to automate installing Jenkins and the status check after a deployment. This will be the Jenkins server that controls the agents. 

    - If the EC2 is created already you can run the commands below to run my [jenkins deployment script](https://github.com/RichardDeodutt/Deployment-3/blob/main/Deployment-Scripts/jenkinsdeployment.sh). 

        - If this is the first time deploying, run the command below. 
            ```
            cd && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-3/main/Deployment-Scripts/jenkinsdeployment.sh && sudo chmod +x jenkinsdeployment.sh && sudo ./jenkinsdeployment.sh
            ```

        - If you want to redo the deployment, run the commmand below **but it will delete the 'Deployment-3' directory if it was created from a previous deployment.** 

            ```
            cd && sudo rm -r Deployment-3 ; curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-3/main/Deployment-Scripts/jenkinsdeployment.sh && sudo chmod +x jenkinsdeployment.sh && sudo ./jenkinsdeployment.sh
            ```

</details>

<details>

<summary>Jenkins Agent</summary>

- Jenkins Agent Part

    - You can use my [agent deployment script](https://github.com/RichardDeodutt/Deployment-3/blob/main/Deployment-Scripts/agentdeployment.sh) during EC2 creation by copying and pasting it in the userdata field to automate installing the agent dependencies and the status check after a deployment. This will be the Jenkins agent that the Jenkins server controls. 

    - If the EC2 is created already you can run the commands below to run my [agent deployment script](https://github.com/RichardDeodutt/Deployment-3/blob/main/Deployment-Scripts/agentdeployment.sh). 

        - If this is the first time deploying, run the command below. 
            ```
            cd && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-3/main/Deployment-Scripts/agentdeployment.sh && sudo chmod +x agentdeployment.sh && sudo ./agentdeployment.sh
            ```

        - If you want to redo the deployment, run the commmand below **but it will delete the 'Deployment-3' directory if it was created from a previous deployment.** 

            ```
            cd && sudo rm -r Deployment-3 ; curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-3/main/Deployment-Scripts/agentdeployment.sh && sudo chmod +x agentdeployment.sh && sudo ./agentdeployment.sh
            ```

</details>

## Install parts separately

<details>

<summary>Parts</summary>

- If you just want to install a specific part run the corresponding script below. 

    <details>

    <summary>Install Jenkins</summary>

    - To install Jenkins. 

        ```
        cd && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-3/main/Scripts/installjenkins.sh && sudo chmod +x installjenkins.sh && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-3/main/Scripts/libstandard.sh && sudo chmod +x libstandard.sh && sudo ./installjenkins.sh
        ```

    </details>

    <details>

    <summary>Install Jenkins Agent</summary>

    - To install the Jenkins agent dependencies. 

        ```
        cd && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-3/main/Scripts/installagent.sh && sudo chmod +x installagent.sh && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-3/main/Scripts/libstandard.sh && sudo chmod +x libstandard.sh && sudo ./installagent.sh
        ```

    </details>

    <details>

    <summary>Install Cypress Dependencies</summary>

    - To install Cypress dependencies. 

        ```
        cd && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-3/main/Scripts/installcydepends.sh && sudo chmod +x installcydepends.sh && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-3/main/Scripts/libstandard.sh && sudo chmod +x libstandard.sh && sudo ./installcydepends.sh
        ```

    </details>

    <details>

    <summary>Check Deployment Status</summary>

    - To check the status after a deployment. 

        ```
        cd && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-3/main/Scripts/statuscheck.sh && sudo chmod +x statuscheck.sh && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-3/main/Scripts/libstandard.sh && sudo chmod +x libstandard.sh && sudo ./statuscheck.sh
        ```

    </details>

    <details>

    <summary>Install The Flask App</summary>

    - To install the flask app. 

        ```
        cd && sudo rm -r venv ; curl -s -O https://raw.githubusercontent.com/RichardDeodutt/kuralabs_deployment_3/main/appdeployment.sh && sudo chmod +x appdeployment.sh && sudo ./appdeployment.sh
        ```

    </details>

</details>

# Why?

- I turned off creating a video for the cypress test because it is hosting the server and running the cypress test on the same machine then creating a video which is too much for the instance I am using to handle. 

# Issues

- Any code not up to `Pylint's standard` in [application.py](https://github.com/RichardDeodutt/Deployment-3/blob/main/Modified-Application-Files/application.py) will throw a `"error"` and fail the test breaking the `rest of the chain` even if the error in question is `just a style thing` and `not a real error`. 

# Improvements

- A better linter that isn't so strict. 