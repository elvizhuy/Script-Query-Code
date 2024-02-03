#! /bin/bash
db_user="root"
db_password="IDY5tt/5v9]qSOhI"
db_name="mediplus_prod"

find /root/backup/databasebak -name "*.sql" -type f -mtime +7 -exec rm {} \;

mysqldump -uroot -pIDY5tt/5v9]qSOhI $db_name > /root/backup/databasebak/mediplus_prod$(date +\%Y\%m\%d).sql



