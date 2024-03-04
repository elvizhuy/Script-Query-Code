#!/bin/bash
set -e

export BACKUP_DIR=/pg_backup
export DATE=`date +%Y-%m-%d`
export DATERM1=`date -d "-1 day" +%Y-%m-%d`
export DATERM2=`date -d "-2 day" +%Y-%m-%d`

cd $BACKUP_DIR
touch test
rm -rf backup_$DATERM2.tar.gz
pg_basebackup -D /$BACKUP_DIR/backup_$DATE -c fast -X s
tar -czvf backup_$DATE.tar.gz backup_$DATE --remove-files
