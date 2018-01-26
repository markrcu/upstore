# Successfully Build Php 5.2 & Apache 2.2 Protocol 1.1
##### `Build Size 3.04GB`
Follow the commands below to build the docker image successfully for Php5.2 & Apache 2.2. The Dockerfile is based on Official CentOS pulling from the remote repository (`FROM centos:6`) as selected before it starts packaging the required softwares and libraries for php and apache.
### Clone Repository
Run the command below to pull the docker file from Projects repository.
<br />
`Command:`
```
git clone git@gitlab.digitalroominc.com:mark.c/Projects.git
```
### Navigate to Projects directory
Run the command below to change directory to Protocol2/AmazonLinux/Uprinting/store folder.
<br />
`Command:`
```
cd Projects/Protocol2/AmazonLinux/Uprinting/store
```
### Docker Build and Run (Express) ``-Not Available-``
Run the command below to build and run the image. <br />
NOTE: The script will ask for the image name, containter name, and the host port bind the to container port. Wait until the "Instruction" message appear.
<br />
`Command:`
```
sh run.sh
```
### Docker Build and Run (Manual)
You can Build and Run the image manually by typing the command below
<br />
`Build Command:`
```
docker build -t store .
```
`Run Command:`
```
docker run -dit -p 80:80 -e NR_INSTALLKEY="license_key" -e DOMAIN_NAME="www.uprinting.com" -e DOMAIN_STORE="store.uprinting.com" -e DOMAIN_PAYMENT="payment.uprinting.com" -e DOMAIN_DESIGN="design.uprinting.com" --name store store
```

##### To access the container's port using web browser(Chrome/Firefox) follow the instruction below
Will publish the container’s port(s) to the host port(s) that you entered a while ago<br />
You should be able to access the container using http://{YOUR_IP} and it should display the content below. <br />
`Display:`
```
File not Found!
