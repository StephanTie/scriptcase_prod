#!/bin/bash
if [ -z $1 ]; then 
  no=1
else
  no=$1
fi
wget 'https://deam-scriptcase.s3.eu-west-1.amazonaws.com/securityexample/securityexample.sql'
mv securityexample.sql mysql_install
wget 'https://deam-scriptcase.s3.eu-west-1.amazonaws.com/securityexample/sc_prod_9.7.009.tar'
mv sc_prod_9.7.009.tar app_install/project${no}
wget 'https://deam-scriptcase.s3.eu-west-1.amazonaws.com/securityexample/securityexample_20220123180138.tar.gz'
mv securityexample_20220123180138.tar.gz app_install/project${no}
