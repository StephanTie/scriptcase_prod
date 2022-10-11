#!/bin/bash
if [ -z $1 ]; then 
  no=1
else
  no=$1
fi
source .env

echo "get_examples.sh: only $SCRIPTCASE_VERSION 9.7.009 and 9.8.009 are available"

wget 'https://deam-scriptcase.s3.eu-west-1.amazonaws.com/securityexample/securityexample.sql'
mv securityexample.sql mysql_install
echo wget 'https://deam-scriptcase.s3.eu-west-1.amazonaws.com/securityexample/sc_prod_'${SCRIPTCASE_VERSION}'.tar'
wget 'https://deam-scriptcase.s3.eu-west-1.amazonaws.com/securityexample/sc_prod_'${SCRIPTCASE_VERSION}'.tar'
mv sc_prod_${SCRIPTCASE_VERSION}.tar app_install/project${no}
echo wget 'https://deam-scriptcase.s3.eu-west-1.amazonaws.com/securityexample/securityexample_'${SCRIPTCASE_VERSION}'.tar.gz'
wget 'https://deam-scriptcase.s3.eu-west-1.amazonaws.com/securityexample/securityexample_'${SCRIPTCASE_VERSION}'.tar.gz'
mv securityexample_${SCRIPTCASE_VERSION}.tar.gz app_install/project${no}
