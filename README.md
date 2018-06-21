# icp-cam-devops-demo

The idea of this demo is to show how IBM Cloud Private and IBM Cloud Automation Manager can be used as part of the DevOps pipeline in multi-cloud environment. Multi-cloud in this context means on-premise private cloud and public AWS.

The application used in this demo environment is [Daytrader, a JEE7 application](https://github.com/samisalkosuo/sample.daytrader7).

The guiding lights of this demo are:
  - when developer commits to develop-branch --> automatic deployment to AWS.
  - when developer commits to master-branch --> automatic deployment to ICP.

## Setup

Assumption is that demo setup is created from scratch using Linux servers. 

Demo servers are Ubuntu Linux servers. total of 8 servers, and they are:

- ICP boot node, including:
  - Jenkins
  - File server
  - Database
  - in real life, all of these would be separate servers but for demo purposes this is fine
- NFS server
  - separate NFS server for ICP and CAM
- 6 server for ICP
  - master, management, proxy, vulnerability advisor and 2 worker nodes
- Minimum server requirements:
  - Ubuntu or CentOS (others may work too)
  - 4 CPU
  - 16GB RAM
  - 100GB disk

 
## Install the demo environment

Starting from scratch, installing the demo environment is an effort. But outcome will be well worth the effort :-)

1. Provision servers.
1. Use one of the servers as the ICP boot node.
   - This is also Jenkins server and simulates external database.
1. [Setup IBM Cloud Private](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_2.1.0.3/installing/installing.html) (Cloud Native offering v 2.1.0.3).
   - Setup nodes and install as instructed.
   - [hosts](icp/hosts) and [config.yaml](icp/config.yaml) are samples.
1. Setup NFS server in one of the servers.
   - If using Ubuntu, [good instructions are here](https://help.ubuntu.com/community/SettingUpNFSHowTo).
1. Setup NFS client on ICP nodes.
   - Make note to allow NFS traffic through firewall(s).
1. Install to ICP bootnode:
   - [kubectl](https://v1-10.docs.kubernetes.io/docs/tasks/tools/install-kubectl/)
   - [IBM Cloud CLI](https://console.bluemix.net/docs/cli/reference/bluemix_cli/get_started.html#getting-started)
   - [Helm](https://github.com/kubernetes/helm/releases)
   - [ICP CLI](https://www.ibm.com/support/knowledgecenter/SSBS6K_2.1.0.3/manage_cluster/install_cli.html)
   - These tools are also used by Jenkins.
1. Configure Docker private registry access from ICP boot node:
   - install ICP certificate, [instructions here](https://www.ibm.com/support/knowledgecenter/SSBS6K_2.1.0.3/manage_images/configuring_docker_cli.html).
1. [Install CAM](https://www.ibm.com/support/knowledgecenter/en/SS2L37_2.1.0.2/cam_install_EE_main.html)
   - See [cam/storage](cam/storage) directory for yaml files to create storage.
   - Remember to create directories in NFS server.
1. Install external database for Daytrader:
   - This simulates production database.
   - In the boot node:
     - ```git clone https://github.com/samisalkosuo/sample.daytrader7.git```
     - Go to *sample_database* directory
     - Build Docker image: ```docker build -t daytrader_db .```
     - Run it: ```docker run -d -p 1527:1527 daytrader_db```
1. Install Jenkins:
   - https://jenkins.io/doc/book/installing/
   - Assumption here is that Jenkins is installed natively (no Docker container).
   - Jenkins uses host OS to build application (using Docker, IBM Cloud CLI, kubectl, etc).
   - Add jenkins-user to Docker users:
     - ```usermod -aG docker jenkins```
     - Restart jenkins: ```systemctl stop jenkins && systemctl start jenkins```
   - Install ICP CLI plugin for jenkins-user:
     - Login as jenkins-user
     - [Install ICP plugin](https://www.ibm.com/support/knowledgecenter/SSBS6K_2.1.0.3/manage_cluster/install_cli.html).
1. Install file server:
   - File server exists so that AWS instance can download the application Docker image.
   - This will be replaced by IBM Object Storage in the future.
   - [Quick and easy file server](https://hub.docker.com/r/halverneus/static-file-server/)
   - Go to directory that you want to share, then execute:
     - ```docker run -d -v $(pwd):/web -p 8088:8080 halverneus/static-file-server:latest```
1. In addition to the components above, you need: 
   - AWS EC2 account
   - Slack account
   - GitHub account


Now the basic components are installed: IBM Cloud Private, IBM Cloud Automation Manager and Jenkins. The next step is to configure the environment.

## Configure the demo environment

Configuration includes setting up all the components so that automatic deploment happens when developer commits code. 

### GitHub

In order to use the demo, you need an application in GitHub. Fork [sample Daytrader application](https://github.com/samisalkosuo/sample.daytrader7) and use your own fork when using this demo.

The sample application includes Jenkinsfile, Dockerfile and other configuration for this demo.

### Cloud Automation Manager

1. Configure CAM:
   - [Connect to AWS cloud](https://www.ibm.com/support/knowledgecenter/en/SS2L37_2.1.0.2/cam_managing_connections.html)
   - You need AWS access key ID and secret access key.
1. Create CAM template:
   - [Documentation](https://www.ibm.com/support/knowledgecenter/en/SS2L37_2.1.0.2/cam_creating_template.html) includes steps to create template. It is pretty straight-forward task.
   - Demo template is in this repository [cam/template](cam/template). It provisions single AWS image and downloads and installs application Docker image.   
   - When deploying the template, AWS key and AWS secret key are required, as well as URL to download application Docker image.
1. Create CAM service:
   - CAM service can include many templates, in this context, only the template created in previous step is used.
   -  [Documentation](https://www.ibm.com/support/knowledgecenter/en/SS2L37_2.1.0.2/cam_managing_services.html) includes steps to create service. 
     - [Sample service JSON file](cam/service/daytrader_at_frankfurt.json)
   - You must use service name: *Daytrader@Frankfurt*
     - Because this is hardcoded in Daytrader Jenkins build :-)
   - Add service parameter:
     - parameter key: *app_download_url*
   - Add template parameters:
     - app_download_url = ${parameters.app_download_url}
     - aws_access_key = YOUR_AWS_ACCESS_KEY
     - aws_secret_key = YOUR_AWS_SECRET_ACCESS_KEY

You may test template and service from CAM UI.

### Jenkins

1. [Install Blue Ocean plugins](https://jenkins.io/doc/book/blueocean/getting-started/).
1. Configure Slack:
   - [Follow these instructions](https://github.com/jenkinsci/slack-plugin).
   - Use slack channel name: *#deployments*
     - Because this is hardcoded in Daytrader Jenkins build :-)
1. Add following global environment variables to Jenkins:
   - ICP_URL - URL to ICP admin console (like https://server.ip:8843).
   - CAM_URL - CAM URL. Default like https://proxy.server.ip:30000.
   - ICP_PROXY_IP - ICP proxy node IP address.
   - CAM_USER - admin user name for both CAM and ICP (default is typically 'admin')
   - CAM_PASSWORD - password for CAM and ICP (assumes that admin-user can access both)
   - DAYTRADER_DB_IP - IP address where Daytrader external database is running. Must be accessible from ICP worker nodes.
   - FILE_SERVER_PATH - Full path to HTTP file server directory (for example: /http_files/)
   - HTTP_FILE_SERVER - File server URL and port. For example: http://file.server.ip:8088.
1. Change file server path owner to jenkins:
   - ```chown jenkins:jenkins /http_files/```
1. Open Blue Ocean and create a new pipeline from GitHub repository:
   - [Sample steps are described here](https://jenkins.io/doc/tutorials/create-a-pipeline-in-blue-ocean/#create-your-pipeline-project-in-blue-ocean)
   - When you've created the pipeline, build processes start for both develop and master branches.
   - Remember to set GitHub polling:
     - Select pipeline settings and Scan Repository Settings and set interval to 1 minute.
     - This enables automatic deployment after commit, with only small delay :-)

If everything was installed and configured correctly, you'll get notified via Slack channel about build processes and eventually see Daytrader application appearing in AWS and ICP.

