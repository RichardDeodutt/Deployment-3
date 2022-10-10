# Deployment-3
Set up a CI/CD pipeline from start to finish using a Jenkins server and Jenkins agent in different VPCs.

Using Elastic Beanstalk and customizing the pipeline. 

Deploying a [url-shortener](https://github.com/RichardDeodutt/kuralabs_deployment_3) Flask app.

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

- Set the `Key pair(login)` to any keypair you have access to or create one. `Network Settings` set the security group to one with ports 80, 8080 and 22 open or create one with those ports open. For `Network` use the default VPC and network settings. Launch with `default settings` for the rest is fine. 

- `SSH or connect` to the ec2 when it is running. 

    Example below: 

    ```
    ssh -i ~/.ssh/keyfile.pem root@18.179.26.45
    ```

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

 - `Get` the secret password and save it for future use. 

    Example below: 

    ```
    sudo cat /var/lib/jenkins/secrets/initialAdminPassword
    ```

</details>

<details>

<summary>One liner</summary>

 - `One liner` to do do everything above at once. 

    Example below: 

    ```
    wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo gpg --batch --yes --dearmor -o /usr/share/keyrings/jenkins.gpg && sudo sh -c 'echo deb [signed-by=/usr/share/keyrings/jenkins.gpg] http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list' && sudo apt update && sudo apt install -y default-jre && sudo apt install -y jenkins && sudo cat /var/lib/jenkins/secrets/initialAdminPassword
    ```

</details>

## Step 2: Create a Jenkins user in your AWS account using IAM in the AWS Console if you don't have one

<details>

<summary>Step by Step</summary>

- Create a user in [AWS IAM](https://us-east-1.console.aws.amazon.com/iamv2/home) for jenkins to get access with username `Eb-user` and AWS credential type of `Access key - Programmatic access`. 

- Then select `Attach existing policies directly` and select `AdministratorAccess` permissions policy then click next tags and then next review to skip the tags and review the changes to be made. 

- Review the changes to be made and click create user when ready and save the information provided after creation such as the `Access key ID` and `Secret access key` or download the csv with the information for future use. 

</details>

## Step 3: Connect GitHub to the Jenkins server

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
        http://35.77.201.219:8080/github-webhook/
        ```
    
    - The `Content type` to application/json. 
    
    - The `Which events would you like to trigger this webhook?` to 'Send me everything.'. 
    
    - The `Active` checkbox to checked. 

    </details>
    
- Then when everything is set click `Add webhook` to connect the forked repository to the Jenkins server webhook. 

</details>

## Step 4: Configure the Jenkins server

<details>

<summary>Step by Step</summary>

- Navigate to the Jenkins page using the url in a browser. 

    Example URL
    ```
    http://35.77.201.219:8080/
    ```

- Enter the `secret password or initial admin password` you saved earlier or get it again and enter it then click Continue. 

    Example below: 

    ```
    sudo cat /var/lib/jenkins/secrets/initialAdminPassword
    ```

- For the `Customize Jenkins page` just click Install suggested plugins and wait for it to install the plugins `which may take some time`. 

- Once that is done you will have a `Create First Admin User` page so fill out that page and save the information for future logins then click Save and Continue. 

- After that is a `Instance Configuration` page where the default `Jenkins URL` should be correct already is similar to `http://35.77.201.219:8080/` so click Save and Finish. 

- The next page is the `Jenkins is ready!` page where you just click Start using Jenkins to finish configuring the Jenkins server and go to the home page. 

</details>

## Step 5: Create a VPC with a Public Subnet

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


## Step 6: Prepare the Jenkins agent EC2 if you don't have one

<details>

<summary>Step by Step</summary>

- Create/Launch an EC2 using the AWS Console in your region of choice, `Asia Pacific (Tokyo) or ap-northeast-1` in my case. 

- Set the `Name and tags` `Name` to anything you want, `Application and OS Images (Amazon Machine Image)` to Ubuntu 64-bit (x86), `Instance type` to t2.micro. 

- Set the `Key pair(login)` to any keypair you have access to or create one. For `Network` use a different VPC than the default VPC and a public subnet and make sure `Auto-assign public IP` is enabled. `Network Settings` set the security group to one with ports 5000 and 22 open or create one with those ports open. Launch with `default settings` for the rest is fine. 

- `SSH or connect` to the ec2 when it is running. 

    Example below: 

    ```
    ssh -i ~/.ssh/keyfile.pem root@18.180.26.45
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

- `Edit` /etc/nginx/sites-enabled/default to look like the following:

<details>

<summary>Config</summary>

 - `/etc/nginx/sites-enabled/default` file. 

    Example below: 

    ```
    sudo nano /etc/nginx/sites-enabled/default
    ```

    ```
    server {
            listen 5000;

            root /var/www/html;

            index index.html index.htm index.nginx-debian.html;

            server_name _;

            location / {
                    proxy_pass http://127.0.0.1:5000;
                    proxy_set_header Host $host;
                    proxy_set_header x-Forward-For $proxy_add_x_forwarded_for;
            }
    }
    ```

</details>

</details>

<details>

<summary>One liner</summary>

 - `One liner` to do do everything above at once. 

    Example below: 

    ```
    sudo apt update && sudo apt install -y default-jre && sudo apt install -y python3-pip && sudo apt install -y python3.10-venv && sudo apt install -y nginx && sudo curl -s https://raw.githubusercontent.com/RichardDeodutt/Deployment-3/main/Configs/nginx-default | sudo tee /etc/nginx/sites-enabled/default > /dev/null 2>&1
    ```

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

        - If you want to redo the deployment, run the commmand below **but it will delete the 'Deployment-3' directory and the 'aws' directory if it was created from a previous deployment.** 

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

        - If you want to redo the deployment, run the commmand below **but it will delete the 'Deployment-3' directory and the 'aws' directory if it was created from a previous deployment.** 

            ```
            cd && sudo rm -r Deployment-3 ; sudo rm -r aws ; curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-3/main/Deployment-Scripts/agentdeployment.sh && sudo chmod +x agentdeployment.sh && sudo ./agentdeployment.sh
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

    <summary>Install The AWS CLI</summary>

    - To install the AWS CLI. 

        ```
        cd && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-3/main/Scripts/installawscli.sh && sudo chmod +x installawscli.sh && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-3/main/Scripts/libstandard.sh && sudo chmod +x libstandard.sh && sudo ./installawscli.sh
        ```

    </details>

    <details>

    <summary>Install The AWS EB CLI('ubuntu' User)</summary>

    - To install the AWS EB CLI as the 'ubuntu' user. 

        ```
        cd && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-3/main/Scripts/installawsebcli.sh && sudo chmod +x installawsebcli.sh && curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-3/main/Scripts/libstandard.sh && sudo chmod +x libstandard.sh && sudo ./installawsebcli.sh
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

</details>

# Why?

# Issues

- Any code not up to `Pylint's standard` in [application.py](https://github.com/RichardDeodutt/Deployment-3/blob/main/Modified-Application-Files/application.py) will throw a `"error"` and fail the test breaking the `rest of the chain` even if the error in question is `just a style thing` and `not a real error`. 