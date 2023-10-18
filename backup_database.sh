#! /bin/bash
db_user="root"
db_password="Huynn@9890#!"
db_name="mediplus_prod"

find /root/backup/databasebak -name "*.sql" -type f -mtime +7 -delete

mysqldump -u $db_user -p $db_password $db_name > /root/backup/databasebak/mediplus_prod$(date +\%Y\%m\%d).sql



