#!/bin/bash
#
# Install automatic by scriptcase generated php applications in production
# newly created  .tar.gz ,  .tar and .sql files will be published automatically
# Check is done firstly in ../pureftpd and if not exits in app_install and mysql_install directories 
# Author: Stephan Tiebosch
#

source .env

# if ../pure-ftpd exists
FILE=${PUREFTPD_DIR}.env
if [ -f "$FILE" ]; then
  source $FILE
  UPDATEDIR=${PUREFTPD_DATA_DIR}/${FTP_USER}
else
  UPDATEDIR=app_install mysql_install 
fi


while true; do
#  inotifywait -e create -e moved_to $UPDATE_DIR
  publish_app $UPDATE_DIR
  sleep $DEPLOY_INTERVAL_SEC
done


function publish_app() {
  for dir in `find $1 -type d`; do
  echo $dir
     project=${dir##*/}
echo $project
      for file in find $dir -maxdepth 1 -type f`; do
echo $file
        if [[ $file == *.tar.gz ]] then
          tar xvfz $file -C app/${project}
          echo "Publishing scriptcase php files from:" $file
          # Special change for app_Login as it seems redirect is not to working with nginx-proxy
          # Maybe myapp_projectx.conf changes can overcome this but is not found yet 
          echo "app_Login/" > app/project$no/_lib/friendly_url/app_Login_ini.txt
          mv $file app_install/${project}/history 
        fi
        if [[ $file == *prod*.tar ]] then
          tar xvf $file -C app/${project}/${SCRIPTCASE_PROD_LIB}
          echo "Publishing scriptcase Prod environment from:" $file
          echo "Please goto ${project}.domain.com/_lib/prod to check/configure database connection" $file
          mv $file app_install/${project}/history 
        fi
        if [[ $file == *.sql ]] then
	  # Execute sql file 
          echo Importing in database $file
          IMPORT_COMMAND='exec mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD"'
          docker exec -i mysql-project sh -c "$IMPORT_COMMAND" < $file
          mv $file mysql_install/history 
        fi
     done
echo         rm $file
  done
  # correct rights and owner
  for xd in `find ./app -type f`; do
    chmod 644 $xd
  done
  for xd in `find ./app -type d`; do
    chmod 755 $xd
  done
  chown ${BITNAMI_PHP_USER}:${BITNAMI_PHP_GROUP} ./app -R 

}


