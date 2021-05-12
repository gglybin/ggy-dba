#!/bin/bash

BKP_DIR="{{ bkp_dir }}/pg_dumpall"
AGE=7

echo "====================== $(date) ======================"

if [[ -d ${BKP_DIR} ]]; then
  pg_dumpall -U postgres -f ${BKP_DIR}/full_backup_$(date +'%Y-%m-%dT%H-%M-%S').dump
  if [[ $? != 0 ]]; then
    echo "Failed to take backup!";
    exit -10;
  else
    echo "Backup successfully completed."
  fi
else
   echo "ERROR: Directory ${BKP_DIR} does not exist!";
   exit -10;
fi

find ${BKP_DIR} -maxdepth 1 -name "full_backup*.dump" -type f -mtime +${AGE} -exec rm -f {} \;
if [[ $? != 0 ]]; then
  echo "Failed to remove dump files older than ${AGE} days!";
  exit -10;
else
  echo "Removed dump files older than ${AGE} days."
fi
