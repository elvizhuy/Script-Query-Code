#! /bin/bash

find /var/lib/backups -name "*.dmp*" -type f -mtime +30 -delete

mysqldump -u root -p mediplus_prod > /root/backup/databasebak/mediplus_prod.sql



