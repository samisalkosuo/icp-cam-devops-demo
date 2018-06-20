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
1. Install file server:
   - File server exists so that AWS instance can download the application Docker image.
   - This will be replaced by IBM Object Storage in the future.
   - [Quick and easy file server](https://hub.docker.com/r/halverneus/static-file-server/)
   - Go to directory that you want to share, then execute:
     - ```docker run -d -v $(pwd):/web -p 8088:8080 halverneus/static-file-server:latest```
1. In addition to the components above, you need AWS EC2 account and Slack account.


Now the basic components are installed: IBM Cloud Private, IBM Cloud Automation Manager and Jenkins. The next step is to configure the environment.

## Configure the demo environment

Configuration includes setting up all the components so that automatic deploment happens when developer commits code. 

### Cloud Automation Manager

1. Configure CAM:
   - [Connect to AWS cloud](https://www.ibm.com/support/knowledgecenter/en/SS2L37_2.1.0.2/cam_managing_connections.html)
   - You need AWS access key ID and secret access key.
1. Create CAM template:
   - [cam/template](cam/template) includes the template to provision single AWS image.
   - [Documentation](https://www.ibm.com/support/knowledgecenter/en/SS2L37_2.1.0.2/cam_creating_template.html) includes steps to create template. It is pretty straight-forward task.
   - 


### Jenkins

Configure Jenkins:
   - Blue Ocean plugins
   - install Slack plugin
   - env variables
1. AWS

Setting up the demo environment includes multipe steps.


- instructions how to use
  - laita artikkeli tms DeveloperWorksiin tai ICP blogiin tms
  - esim: https://developer.ibm.com/recipes/
  - linkki tähän githubiin koska tätä päivitetään
- setup Jenkins
- setup NFS
- setup ICP boot
- setup ICP nodes
- setup CAM
- setup AWS including keys, use temp key?
- configure pipeline
- update powerpoint
