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

- Set the `Key pair(login)` to any keypair you have access to or create one, `Network Settings` set the security group to one with ports 80, 8080 and 22 open or create one with those ports open. For `Network` use the default VPC and network settings. Launch with `default settings` for the rest is fine. 

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
            cd && sudo rm -r Deployment-3 ; sudo rm -r aws ; curl -s -O https://raw.githubusercontent.com/RichardDeodutt/Deployment-3/main/Deployment-Scripts/jenkinsdeployment.sh && sudo chmod +x jenkinsdeployment.sh && sudo ./jenkinsdeployment.sh
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

    - To install the Jenkins agent. 

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