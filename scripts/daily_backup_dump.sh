#!/bin/bash
set -e

export BK_DIR=/db_backup
export DATE=`date +%Y_%m_%d_%H_%M`

cd $BK_DIR

pg_dump -d dev --exclude-table-data=adempiere.ad_changelog --exclude-table-data=adempiere.ad_issue -c -Fc -f dev_$DATE.dmp
