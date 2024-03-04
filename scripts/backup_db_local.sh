#!/bin/bash
set -e

project=${1}
db_name=${2}
db_user=${3}
db_pass=${4}
backup_option=${5:-reduce}
file_name=${6:-${project}_${backup_option}_$(date +"%Y_%m_%d_%H_%M").dmp}
backup_path=${7:-/pg_backup}

cd $backup_path

if [[ "$backup_option" = "reduce" ]]; then
	backup_option="--exclude-table-data=adempiere.ad_changelog"
fi

export PGPASSWORD=$db_pass

echo ...................Start backup...................
pg_dump -U $db_user -d $db_name $backup_option -c -Fc -f ${file_name}