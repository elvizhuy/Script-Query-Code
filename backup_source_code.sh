#! /bin/bash

find /var/lib/backups -name "*.dmp*" -type f -mtime +30 -delete

tar -cvzf /root/backup/sourceCodebak/source_code$(date +\%Y\%m\%d).tar.gz /var/www/html
