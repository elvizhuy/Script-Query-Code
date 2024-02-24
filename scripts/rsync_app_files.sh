#!/bin/bash
set -e
DATE=`date +%Y-%m-%d`

rsync -avzhe ssh --delete /data/emr/files/ isofh@192.168.55.205:/data/emr/files --log-file=/tmp/rsynclog/rsync_his_$DATE.log

rsync -avzh isofh@127.0.0.1:/home/isofh/server/emr/ndtp-production/his/files/public/nas2/ /home/isofh/server/emr/ndtp-production/his/files/public/nas1 --log-file=/tmp/rsynclog/rsync_his_$DATE.log
