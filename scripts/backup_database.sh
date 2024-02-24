#! /bin/bash
db_user="root"
db_password="IDY5tt/5v9]qSOhI"
db_name="mediplus_prod"

find /root/backup/databasebak -name "*.sql" -type f -mtime +7 -exec rm {} \;

mysqldump -uroot -pIDY5tt/5v9]qSOhI $db_name > /root/backup/databasebak/mediplus_prod$(date +\%Y\%m\%d).sql


HOST="localhost"
PORT="5432"
USERNAME="your_username"
DATABASE="your_database"
BACKUP_FILE="backup_$(date +\%Y\%m\%d_\%H\%M\%S).sql"

pg_dump -h $HOST -p $PORT -U $USERNAME -d $DATABASE > $BACKUP_FILE



