#!/bin/bash
export ORACLE_HOME=/u01/app/oracle/product/11.2.0/db_1
export PATH=$PATH:$ORACLE_HOME/bin
export ORACLE_SID=his
export BACKUP_DIR=/backup
export ORACLE_OWNER=oracle

cd $BACKUP_DIR

$ORACLE_HOME/bin/rman target / <<EOF
RUN {
DELETE FORCE NOPROMPT ARCHIVELOG ALL COMPLETED BEFORE 'SYSDATE-7';
}
exit;
EOF
