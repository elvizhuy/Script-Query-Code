#!/bin/bash
#remove log his

find /home/isofh/server/his/log -name "*.log" -mtime +14 -delete
find /home/isofh/server/his/log -name "ui.log*" -mtime +14 -delete
find /home/isofh/server/his/log -name "process.log*" -mtime +14 -delete
find /home/isofh/server/his/log -name "model.log*" -mtime +14 -delete
find /home/isofh/server/his/log -name "system.log*" -mtime +14 -delete
find /home/isofh/server/his/log-8082 -name "*.log" -mtime +14 -delete
find /home/isofh/server/his/log-8082 -name "ui.log*" -mtime +14 -delete
find /home/isofh/server/his/log-8082 -name "process.log*" -mtime +14 -delete
find /home/isofh/server/his/log-8082 -name "model.log*" -mtime +14 -delete
find /home/isofh/server/his/log-8082 -name "system.log*" -mtime +14 -delete
sudo sh -c "truncate -s 0 /var/lib/docker/containers/*/*-json.log"
