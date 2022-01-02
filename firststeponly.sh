#!/bin/bash
#
# Install by scriptcase generated php applications in production
# Author: Stephan Tiebosch
# 
echo "-------------------- Install Scriptcase php application with mysql -------------- "
if [ -z "$1" ]; then
  echo "Usage $0 <no>"
  echo " <no> is project number coresponds to docker-compose.yml (1) or dc_project<no> (2..n)"
  exit
fi
no=$1;
if [ "$no" == "1" ]; then
  source .env
else
  source .env${no}
fi



# Fetch a standard php.ini from a standard php-fpm container and add ioncube_loader to it
mkdir -p ${PHP_APP_PROJECT_DIR}/history
mkdir -p ${PHP_APP_PROJECT_DIR}/${SCRIPTCASE_PRODLIB}
chmod 755 ${PHP_APP_PROJECT_DIR} -R
chown ${BITNAMI_PHP_USER}:${BITNAMI_PHP_GROUP} ${PHP_APP_PROJECT_DIR} -R
mkdir -p ${PHP_INI_PROJECT_DIR}
chmod 755 ${PHP_INI_PROJECT_DIR}
chown ${BITNAMI_PHP_USER}:${BITNAMI_PHP_GROUP} ${PHP_INI_PROJECT_DIR}
mkdir -p ${PHP_EXT_PROJECT_DIR}
chmod 755 ${PHP_EXT_PROJECT_DIR}
chown ${BITNAMI_PHP_USER}:${BITNAMI_PHP_GROUP} ${PHP_EXT_PROJECT_DIR}

# Install Scriptcase php application (scriptcase versions that uses php 7.3 or higher)
wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz
tar xzf ioncube_loaders_lin_x86-64.tar.gz -C . 
mv ioncube/*${PHP_PROJECT_VERSION}*  ${PHP_EXT_PROJECT_DIR}
rm ioncube_loaders_lin_x86-64.tar.gz
rm -rf ioncube

docker run -it --name tmpfetch-ini -d --rm docker.io/${PHP_PROJECT_IMAGE:${PHP_PROJECT_IMAGE_VERSION}
docker container cp tmpfetch-ini:${BITNAMI_PHP_INI_DIR}/php.ini ${PHP_INI_PROJECT_DIR}/php.ini
sed -i "s/^zend_extension =.*/zend_extension =\/phpext\/ioncube_loader_lin_""${PHP_PROJECT_VERSION}"".so/g" ${PHP_INI_PROJECT_DIR}/php.ini 
docker stop tmpfetch-ini

dir="app_install/project""$no"
echo $dir
for file in `find $dir -maxdepth 1 -type f`; do
echo $file
  if [[ $file == *.tar.gz ]]; then
   tar xfz $file -C app/project${no}
          # Special change for app_Login as it seems redirect is not to working with nginx-proxy
          # Maybe myapp_projectx.conf changes can overcome this but is not found yet
          echo "app_Login/" > app/project$no/_lib/friendly_url/app_Login_ini.txt
  fi
  if [[ $file == *prod*.tar ]]; then
    tar xf $file -C app/project${no}/${SCRIPTCASE_PRODLIB}
  fi
  mv $file $dir/history
done
for xd in `find ./app/project${no} -type f`; do
  chmod 644 $xd
  chown ${BITNAMI_PHP_USER}:${BITNAMI_PHP_GROUP} $xd
done
for xd in `find ./app/project${no} -type d`; do
  chmod 755 $xd
  chown ${BITNAMI_PHP_USER}:${BITNAMI_PHP_GROUP} $xd
done

if [ "$no" == "1" ]; then
  echo "-------------------- Install MYSQL DATABASE APPLICATION -------------- "
  mkdir -p ${DB_DIR}
  chmod 755 ${DB_DIR}
  chown ${BITNAMI_MYSQL_USER}:${BITNAMI_MYSQL_GROUP} ${DB_DIR}

  echo "Executing docker-compose up -d"
  docker-compose up -d
else
  echo "Executing docker-compose -f dc_project2..n up -d"
  docker-compose -f dc_project{no}.yml -env-file ./env${no} up -d
fi

echo "Database install sleep 10 sec first"
dir="mysql_install"
sleep 10
for file in `find $dir -maxdepth 1  -type f`; do
  echo $file
  if [[ $file = *.sql ]]; then
    database=${file##*/}
    echo $database $file
    IMPORT_COMMAND='exec mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD"'
    docker exec -i mysql-project sh -c "$IMPORT_COMMAND" < $file
    mv $file mysql_install/history 
  fi
done

# Install completed
echo "------------------ Install of by Scriptcase generated php-app Completed! ------------------ "

if [ "$no" == "1" ]; then
  docker-compose ps 
else
  docker-compose -f dc_project{no}.yml -env-file ./env${no} ps
fi
