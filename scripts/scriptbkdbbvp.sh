#!/bin/bash
export ORACLE_HOME=/u01/app/oracle/product/11.2.0/db_1
export PATH=$PATH:$ORACLE_HOME/bin
export ORACLE_SID=his
export BACKUP_DIR=/backup
export ORACLE_OWNER=oracle
export DATE=`date +%Y%m%d`
export DATERM1=`date -d "-1 day" +%Y%m%d`
export DATERM2=`date -d "-2 day" +%Y%m%d`
export DATERM3=`date -d "-3 day" +%Y%m%d`
export DATERM4=`date -d "-4 day" +%Y%m%d`
export DATERM5=`date -d "-5 day" +%Y%m%d`
export DATERM6=`date -d "-6 day" +%Y%m%d`
export DATERM7=`date -d "-7 day" +%Y%m%d`

cd $BACKUP_DIR
rm -rf backup_full_$DATERM7
mv backup_full backup_full_$DATE
mkdir backup_full

$ORACLE_HOME/bin/rman target / log /backup/log_rman/rman_backup_full_$DATE.log <<EOF
RUN {
CROSSCHECK BACKUP OF DATABASE;
CROSSCHECK ARCHIVELOG ALL;
BACKUP AS COMPRESSED BACKUPSET FORMAT '/backup/backup_full/his_arc_f%t_s%s_s%p' ARCHIVELOG ALL;
BACKUP AS COMPRESSED BACKUPSET FORMAT '/backup/backup_full/his_data_f%t_s%s_s%p' DATABASE ;
SQL 'ALTER SYSTEM ARCHIVE LOG CURRENT';
BACKUP AS COMPRESSED BACKUPSET FORMAT '/backup/backup_full/his_arc_f%t_s%s_s%p' ARCHIVELOG ALL;
#DELETE FORCE NOPROMPT ARCHIVELOG ALL COMPLETED BEFORE 'SYSDATE-7' BACKED UP 1 TIMES TO DEVICE TYPE DISK;
DELETE FORCE NOPROMPT ARCHIVELOG ALL COMPLETED BEFORE 'SYSDATE-7';
BACKUP CURRENT CONTROLFILE;
}
exit;
EOF
