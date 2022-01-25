#!/bin/bash
# Starting up wkhtmltopdf solo
source .env
docker network create --attachable=true --driver=bridge --subnet=${SUBNET} --gateway=${GATEWAY} ${NETWORK}
docker-compose -f dc_wkhtmltopdf.yml build
docker-compose -f dc_wkhtmltopdf.yml up -d
docker-compose -f dc_wkhtmltopdf.yml ps
docker-compose -f dc_wkhtmltopdf.yml logs

