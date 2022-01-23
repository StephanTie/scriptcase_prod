#!/bin/bash
#
# Install automatic by scriptcase generated php applications in production
# newly created  .tar.gz ,  .tar and .sql files will be published automatically
# Check is done firstly in ../pureftpd and if not exits in app_install/project[n] and mysql_install directories 
# Author: Stephan Tiebosch
#
REALSCRIPT=`realpath -s $0`
REALSCRIPTPATH=`dirname ${REALSCRIPT}`
cd $REALSCRIPTPATH

if [ "$1" == "-h" ]; then
  echo "Usage $0 <no> <-d>"
  echo " <no> is project number coresponds to docker-compose.yml and .env (1) or dc_project<no> (2..n) and .env[n])"
  exit
fi
if [ -z "$1" ]; then
  no=1;
else
  no=$1;
fi
if [ "$no" == "1" ]; then
  source .env
else
  source .env${no}
fi

# if ../pure-ftpd exists
FILE=${PUREFTPD_DIR}/.env
if [ -f "$FILE" ]; then
  source $FILE
  UPDATE_DIR="./${PUREFTPD_DATA_DIR}/${FTP_USER}/project${no} app_install/project${no} mysql_install"
else
  UPDATE_DIR="./app_install/project${no} ./mysql_install" 
fi

echo "updatedir =" "${UPDATE_DIR}"


function update_rights() {
  # correct rights and owner
  if [ "$2" == "-x" ]; then   # not production
    x="$1/$3"
    if [ "$4" = "-n" ]; then
      noex="true"
    else
      noex="false"
    fi
  else
    x="__"
    if [ "$2" = "-n" ]; then
      noex="true"
    else
      noex="false"
    fi
  fi
IFS='
' # split on newline only
  for xd in `find $1 -type d ! -path "$x"`; do
    if [ "$noex" = "true" ]; then
      echo $xd
    else
      chmod 755 "$xd"
    fi 
  done
  for xd in `find $1 -type f ! -path "$x"`; do
    if [ "$noex" = "true" ]; then
      echo $xd
    else
      chmod 644 "$xd"
    fi 
  done
  chown ${BITNAMI_PHP_USER}:${BITNAMI_PHP_GROUP} ./app/${project} -R
}

publish_app() {
  for dir in `find $@ -maxdepth 0 -type d`; do
     project=${dir##*/}
      for file in `find $dir -maxdepth 1 -type f`; do
        if [[ $file == *"sc_prod"*".tar" ]]; then
          tar xvf $file -C app/${project}/${SCRIPTCASE_PRODLIB}
          echo "Publishing scriptcase Prod environment from: $file"
          echo "Please goto ${project}.domain.com/_lib/prod to check/configure database connection "
          mv $file app_install/${project}/history 
          cp app/project${no}/${SCRIPTCASE_PRODLIB}/${SCRIPTCASE_WKHTMLTOPDF_SCRIPT} app/project${no}/${SCRIPTCASE_PRODLIB}/${SCRIPTCASE_WKHTMLTOPDF_SCRIPT}.org 
          update_rights "app/project${no}/${SCRIPTCASE_PRODLIB}" 
          find  app/project${no}/${SCRIPTCASE_PRODLIB}/prod/third -type f  \( -exec sh -c 'file -b "$1" | grep -q executable' Test {} \; -exec chmod 755 {} \; \)
        fi
        if [[ $file == *.tar.gz ]]; then
          tar xvfz $file -C app/${project}
          echo "Publishing scriptcase php files from:" $file
          # Special change for start application (app_Login) as it seems redirect is not to working with nginx-proxy
          # Maybe myapp_projectx.conf changes can overcome this but is not found yet 
          rm -f app/project${no}/_lib/friendly_url/${SCRIPTCASE_STARTAPP}_ini.txt
          mv $file app_install/${project}/history 
          update_rights "app/project${no}" -x "${SCRIPTCASE_PRODLIB}/prod/*"
        fi
        if [[ $file == *.sql ]]; then
	  # Execute sql file 
          echo Importing in database $file
          IMPORT_COMMAND='exec mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD"'
          docker exec -i mysql-project sh -c "$IMPORT_COMMAND" < $file
          mv $file mysql_install/history 
        fi
     done
  done
}

publish_app $UPDATE_DIR
if [ "$2" == "-d" ]; then
  while true; do
    inotifywait -e create -e moved_to $UPDATE_DIR
    echo "Publishing"
    publish_app $UPDATE_DIR
    sleep $DEPLOY_INTERVAL_SEC
  done
fi 
