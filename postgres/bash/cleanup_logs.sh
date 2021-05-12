#!/bin/bash

LOG_DIR="{{ os_pg_logs }}"
AGE=7

echo "====================== $(date) ======================"

if [[ -d ${LOG_DIR} ]]; then
  find ${LOG_DIR} -maxdepth 1 -name "postgresql*.log" -type f -mtime +${AGE} -exec rm -f {} \;
  if [[ $? != 0 ]]; then
    echo "Failed!";
    exit -10;
  else
    echo "Success!"
  fi
else
   echo "ERROR: Directory ${LOG_DIR} does not exist.";
   exit -10;
fi
