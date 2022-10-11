# Docker-compose for php-apps generated by scriptcase together with nginx, mysql, phpmyadmin and phhp-fpm into production 

![This is an image](https://deam-scriptcase.s3.eu-west-1.amazonaws.com/securityexample/dockercycle.png)


## Features
- Added support for the newest version of scriptcase 9.8.009 and php version 8.1.6
(Also can be set for older versions of scriptcase and php)
- Install Scriptcase generated php applications on docker with docker-compose
- Using nginx-proxy, jcrs letsencrypte, nginx, mysql, phpmyadmin with ssl access
- Additional solved the portability issue with wkhtmltopdf by generating a container for it where settings can be altered per report   
- Automatically publish updates pushed via ftp (pureftp)
- date: 15–11–2021

## Introduction
Here is described how to get your applications generated by scriptcase into production using docker with nginx-proxy, letsencrypt, nginx and mysql and wkhtmltopdf dockerized. 

The standard installed application is a demo application (securityexample) from scriptcase.
It is running on ubuntu 18 and requires docker, docker-compose and ufw installed. Explanation how to install these you can easily find here or the other many manuals. Furthermore ensure that your servers and I like to stress this if you use your applications are exposed to the outside world they are extremely hardened . (you can find enough examples of them with google). Better is to use a vpn.
Objective is to have the generated scriptcase php-applications accessible through the nginx-proxy protected by a certificate. Also I liked to have the benefit to test an older version and a new version of the generated scriptcase application in the same environment .
Prerequisites
Starting point: Ensure versions are equal or higher for:
- Ubuntu 18.04.4 LTS with ufw installed 
- docker version 18.09.7
- docker-compose 1.29.2

Ensure your production environment is safe and hardened otherwise  you get your data exposed. (ufw is up, fail2ban, sudo and no root users, ssh only with key and many other safety precautions steps you should  be familiar with)

With having this docker environment set up it is very easy to spin up an new copy of an environment and set up a stage environment.
Also new versions of scriptcase with new versions of php , nginx and mysql can be far more easily automatically installed and tested.
New applications and database updates which are pushed via ftp are deployed automatically.
Also it solves the problem to change settings for wkhtmltopdf per report and are settings like Landscape or A4.

## Installation

1. Precautions for automatic iptable changes by docker.
When using docker first of all you do not want starting containers automatically opening ports and change the iptables. Also added standard dns.
1.1 edit daemon.json: 
```sh
sudo vi /etc/docker/daemon.json
```
1.2 copy tekst into and save
```sh
{ "iptables" : false }
{ "dns": ["8.8.8.8", "8.8.8.4"] }
```
1.3 restart docker:
```sh
sudo systemctl start docker
```

2. Required is to start up nginx-proxy and nginxproxy-acme-companion developed by Evert Ramos
- Ensure the right certificates on your server
```sh
sudo apt-get update && sudo apt-get install ca-certificates
```
- Follow then the steps defined in  https://github.com/evertramos/nginx-proxy-automation

3. Ensure you have an A record pointing to your server in your DNS
project1.domain.com -> 111.222.333.444

4. Goto /data or other place where you want to store your project
```sh
cd /data 
git clone https://github.com/StephanTie/nginx-proxy-letsencrypt.git
```

5. Change .env file

5.1 cd to scriptcase_prod
```sh
cd ./scriptcase_prod
```
5.2 Copy .env1.template to .env and change the .env file
```sh
cp .env1.template .env
```
5.3 edit .env file and change all the items that have a mark <changeme> and <domain.com>.
```sh
vi .env
```
5.4 change the following data 
```sh
MYSQL_ROOT_PASSWORD=<changeme>
MYSQL_PASSWORD=<changeme2>
MAIN_DOMAIN_PROJECT=project1.<domain.com>
```
5.5 Do not change the other settings. Do this later after the first initial run works

6. Get generated php example files and  mysql files 
```sh
./get_example_files.sh 1
```

7. Run install for project 1
```sh
sudo ./firststeponly.sh 1
```

8. Configure Scriptcase production 

8.1 In your browser go to 
```sh
https://project1.<domain.com>/_lib/prod
```
8.2 Login with scriptcase and set new password
    
8.3 edit setting for pdf server in production settings to /app
    
8.4 edit database connection option conn_example and change Server/Host to mysql-project and save
    
![afbeelding](https://user-images.githubusercontent.com/8845918/147996147-8448611b-33e6-4878-b6f8-8b304a215315.png)
    
8.5 Exit your browser and startup again to check if your settings were saved
    
8.6 Now you can browse to 
```sh   
https://project1.<domain.com> for which you fill in your domain
```

9. Starting the second project with connection to the same database 
9.1 Follow the same steps as above but with specifics of project2 (so copy .env2.template to .env2 etc)
9.2 Start up sudo ./firststeponly 2

## Remarks:
If you encounter problems most of the time it is related with not having the proper rights although the scripts changes them correctly.
    
## Special options
A. Automatic updates in case updates are pushed to directory app_install/project{1..n} or directory mysql_install or with help of the pure-ftpd server (see project pureftpd)
A.1 Install inotifytools
```sh  
apt install inotify-tools
```  
A.2    Start automatic update process  
```sh  
screen -dmS PUBLISH1  bash -c '/data/scriptcase_prod/publish_scriptcase.sh 1 -d'
```
check en reattach to screen (detach with CTR a d)
```sh  
screen -list
screen -r PUBLISH1
```

B. Php settings changes 
``` vi php_conf/project1/iniscan/custom.ini ```
    
C. Wkhtmltopdf and scriptcase 
This container and the script can also be used on its own and can be accessed via curl 
Settings can be defined in a separate file per report in the /pdf_ini location.  Copy the example grid_customers_pdf.ini.example (without .example) to this directory
And check if the report is using the other settings for instance Landscape.
In the menu of the application you can change it via a form.
Running on its own and access via curl 
```
./first_wkhtmltopdf.sh 
```
  

| Commands | Description |
| -------- | ----------- |
| ``` docker-compose up -d ``` | Starts up all containers project1 |
| ``` docker-compose build ``` | Creating specific docker images for project1 |
| ``` docker-compose down  ``` | Stops all container project1 |
| ``` docker-compose -f dc_project2 --env_file .env2 up -d ``` | Starts up project2 |
| ``` docker-compose -f dc_project2 --env_file .env2 build ``` | Creating docker specific docker images for project2 |
| ``` docker-compose -f dc_project2 --env_file .env2 down  ``` | Stops project2 |
| ``` screen -dmS PUBLISH1 bash -c '/data/publish_scriptcase.sh 1 -d' ``` | Checks if files are placed in app_install/project1 or mysql_install or ../pure-ftpd/data/scriptcase/project1 dir and updates the projects automatically | 
| ``` screen -dmS PUBLISH2 bash -c '/data/publish_scriptcase.sh 2 -d' ``` | Checks if files are placed in app_install/project2 or mysql_install or ../pure-ftpd/data/scriptcase/project2 dir and updates the projects automatically | 
 
```sh  
Projectstructure:
── app
│   ├── project1
│   │   ├── grid_customers
│   │   ├── history
│   │   ├── _lib
│   │   │   └── tmp
│   │   └── pdf_ini
│   └── project2
│       ├── grid_customers
│       ├── history
│       ├── _lib
│       │   └── tmp
│       │   └── prod
│       └── pdf_ini
├── app_install
│   ├── project1
│   │   └── history
│   └── project2
│       └── history
├── db_project
│   └── securityexample
├── dockerfiles
│   ├── Flask-Shell2HTTP
│   │   ├── conf
│   ├── project1
│   └── project2
├── mysql_conf
├── mysql_install
│   └── history
├── nginx_conf
│   ├── project1
│   │   └── vhost
│   └── project2
│       ├── log
│       └── vhost
├── nginx_log
│   ├── project1
│   └── project2
├── php_conf
│   ├── project1
│   │   ├── iniscan
│   │   └── phpext
│   └── project2
│       ├── iniscan
│       └── phpext
└── pma_conf
    └── sessions
```  

##   Special Thanks to the opensource projects from
- Eshaan Bansal for his contribution on github eshaan7/Flask-Shell2HTTP
- jwilder/nginx-proxy 
- surnet/wkhtmltopdf   
- evertramos/nginxproxy-acme-companion
- To many others who share their knowledge on github and stackoverflow 
