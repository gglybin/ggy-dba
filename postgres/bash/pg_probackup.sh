#!/bin/bash

BKP_DIR=$1
INSTANCE=$2
THREADS=$3
MODE=$4

echo "====================== ${MODE} backup for ${INSTANCE} instance ======================"
echo "$(date +'%Y-%m-%dT%H:%M:%S')| INFO: Starting backup."
echo "---------------------------"

pg_probackup-{{ pg_version }} backup --backup-path=${BKP_DIR} --instance=${INSTANCE} --threads ${THREADS} --backup-mode ${MODE} --compress --delete-expired --delete-wal -d {{ bkp_db_name }} -h {{ ansible_fqdn }} -p {{ pg_port }} -U {{ bkp_usr }} -w

if [[ $? != 0 ]]; then
  echo "---------------------------"
  echo "$(date +'%Y-%m-%dT%H:%M:%S')| ERROR: Failed to perform ${MODE} backup for ${INSTANCE} instance.";
  exit -10;
else
  echo "---------------------------"
  echo "$(date +'%Y-%m-%dT%H:%M:%S')| INFO: Backup successfully completed."
fi

echo "$(date +'%Y-%m-%dT%H:%M:%S')| SUMMARY:"
echo "---------------------------"
pg_probackup-{{ pg_version }} show --backup-path=${BKP_DIR}
echo "---------------------------"
