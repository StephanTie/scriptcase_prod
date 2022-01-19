#!/bin/sh
LOG_PATH=/log
mkdir -p ${LOG_PATH}
touch ${LOG_PATH}/gunicorn_access.log ${LOG_PATH}/gunicorn_errors.log
#chown -R static_analyzers-user:static_analyzers-user ${LOG_PATH}
chown -R bin:bin ${LOG_PATH}
# change user
#su static_analyzers-user -s /bin/bash
# start flask server
exec /usr/local/bin/gunicorn 'app:app' \
    --bind '0.0.0.0:4000' \
    --user bin \
    --log-level 6  \
    --access-logfile ${LOG_PATH}/gunicorn_access.log \
    --error-logfile ${LOG_PATH}/gunicorn_errors.log
