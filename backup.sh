#! /bin/bash

mkdir /var/lib/backups

find /var/lib/backups -name "*.dmp*" -type f -mtime +30 -delete

tar -cvzf source_code.gz ten_thu_muc_hoac_file_can_nen

mysqldump -u root -p mediplus_prod > mediplus_prod_backup.dmp



