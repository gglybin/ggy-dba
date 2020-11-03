#!/bin/bash

###############################################################
# Description: script to start PostgreSQL backup using barman.
###############################################################

server=$1
log_detail="/var/lib/barman/dba/logs/barman_bkp_detail.log"

##
## Check available backups before start new one
##

echo "----------------- List of ${server} server barman backups -----------------" > ${log_detail}
echo "" >> ${log_detail}
barman list-backup ${server} >> ${log_detail}
echo "" >> ${log_detail}
echo "----------------- BARMAN backup of ${server} server -----------------" >> ${log_detail}
echo "" >> ${log_detail}
echo "START: `date`" >> ${log_detail}

##
## Switch currrent WAL before starting backup
##

echo ""
echo "INFO: Switching current wal ..."
echo "" >> ${log_detail}
barman switch-wal ${server} >> ${log_detail}
if [[ $? == 0 ]];
then
    echo "INFO: Switch wal completed."
else
    echo "ERROR: Failed to switch wal file."
    echo "       Check barman/postgres log files for details."
    exit -10
fi

##
## Start backup
##

echo ""
echo "INFO: Starting backup ..."
echo "" >> ${log_detail}
barman backup ${server} >> ${log_detail}
if [[ $? == 0 ]];
then
    echo "INFO: Backup completed."
else
    echo "ERROR: Failed to take ${server} server barman backup."
    echo "       Check barman/postgres log files for details."
    exit -10
fi

##
## Run barman cron to remove obsolete backups according to retention_policy parameter
##

echo ""
echo "INFO: Removing obsolete backups ..."
echo "" >> ${log_detail}
barman cron >> ${log_detail}
if [[ $? == 0 ]];
then
    echo "INFO: Obsolete backups removal completed."
else
    echo "WARNING: Failed to remove obsolete backups"
    echo "         Check barman/postgres log files for details."
    exit -10
fi

echo "" >> ${log_detail}
echo "DONE:  `date`" >> ${log_detail}
echo "" >> ${log_detail}
echo "----------------- List of ${server} server barman backups -----------------" >> ${log_detail}
echo "" >> ${log_detail}
barman list-backup ${server} >> ${log_detail}
echo ""
echo "Check log file for any errors: $log_detail"
exit 0
