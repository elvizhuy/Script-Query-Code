#! /bin/bash

find /root/backup/databasebak -name "*.sql" -type f -mtime +7 -delete

mysqldump -u root -p mediplus_prod > /root/backup/databasebak/mediplus_prod.sql



