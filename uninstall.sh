#!/bin/bash
echo "-------------------- Uninstall Scriptcase php application -------------- "
if [ -z "$1" ]; then
  echo "Usage $0 <no>"
  echo " <no> is project number coresponds to docker-compose.yml or dc_project<no> "
  exit
fi
no=$1;
if [ "$no" == "1" ]; then
  source .env
fi
rm -rf app/project$no
rm -rf nginx_log
echo "database for project {no} will not be deleted"
