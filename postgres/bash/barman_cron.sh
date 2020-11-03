#!/bin/bash

###############################################################
# Description: start barman cron.
###############################################################

##
## Run barman cron to remove obsolete backups according to retention_policy.
## It also executes WAL archiving operations.
##

echo ""
echo "INFO: Starting barman cron..."
echo ""

barman cron

if [[ $? == 0 ]];
then
    echo ""
    echo "INFO: Completed."
    exit 0
else
    echo ""
    echo "WARNING: Failed to perform barman cron operations."
    echo "         Check barman/postgres log files for details."
    exit -10
fi
