#! /bin/bash

# find /root/backup/sourceCodebak -name "*.tar.gz" -type f -mtime +7 -delete
find /root/backup/sourceCodebak -type f -name "*.tar.gz" -mtime +7 -exec rm {} \;

tar -cvzf /root/backup/sourceCodebak/source_code$(date +\%Y\%m\%d).tar.gz /var/www/html
