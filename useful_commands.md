# Some useful commands

- Install kubectl on Linux
  - ```curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x ./kubectl &&  sudo mv ./kubectl /usr/local/bin/kubectl```

- Login to ICP cluster
  - ```bx pr login -a https://mycluster.icp:8443 --skip-ssl-validation```
  - where mycluster.icp is master node IP address

- See installed clusters
  - ```bx pr clusters```
  - default cluster name is: mycluster

- Configure kubectl for the cluster
  - ```bx pr cluster-config mycluster```
  - Alternatively go to ICP web UI -> Configure client

- Login to ICP using ICP CLI
  - ```echo 1 | bx pr login -a ${ICP_URL} --skip-ssl-validation -u ${ICP_USER} -p ${ICP_PASSWORD}```
  - where ICP_URL is URL to ICP master node and ICP_USER and ICP_PASSWORD are self explanatory
  - 'echo 1' selects the first account when login, without echo login commands asks for account

- Configure kubectl CLI
  - ```bx pr cluster-config mycluster```
  - mycluster is default clustern name
  - alternatively use ICP UI to get kubectl config commands

  


  

