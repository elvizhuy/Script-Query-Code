#!/bin/bash

find /home/isofh/server/emr/dhy-production/auth-server/log -name "*.gz" -mtime +7 -delete
find /home/isofh/server/emr/dhy-production/emr-eureka/log -name "*.gz" -mtime +7 -delete
find /home/isofh/server/emr/dhy-production/emr-zuul/log -name "*.gz" -mtime +7 -delete
find /home/isofh/server/emr/dhy-production/html-editor/log -name "*.gz" -mtime +7 -delete
#find /home/isofh/server/emr/dhy-production/infection-prevention/log -name "*.gz" -mtime +7 -delete
find /home/isofh/server/emr/dhy-production/master-data/log -name "*.gz" -mtime +7 -delete
find /home/isofh/server/emr/dhy-production/patient-service/log -name "*.gz" -mtime +7 -delete
find /home/isofh/server/emr/dhy-production/pay/log -name "*.gz" -mtime +7 -delete
find /home/isofh/server/emr/dhy-production/phat-thuoc/log -name "*.gz" -mtime +7 -delete
find /home/isofh/server/emr/dhy-production/vital-signs/log -name "*.gz" -mtime +7 -delete
find /home/isofh/server/emr/dhy-production/signer-connector/log -name "*.gz" -mtime +7 -delete

sudo sh -c "truncate -s 0 /var/lib/docker/containers/*/*-json.log"
