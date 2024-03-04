#!/bin/bash
export ORACLE_SID=sakura
export RMAN_LOG_FILE=/home/oracle/script/log/delete_archivelog_"$ORACLE_SID"_`date +%Y%m%d`.log
export ORACLE_HOME=/u01/app/oracle/product/19.0.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH

rman target / nocatalog msglog $RMAN_LOG_FILE append <<EOF
run{
crosscheck archivelog all;
delete force noprompt archivelog until time 'sysdate - 3';
crosscheck archivelog all;
}
exit;
EOF

