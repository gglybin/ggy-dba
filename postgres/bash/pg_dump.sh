#!/bin/bash

#============================================================================================================
# Description: Short script to take a logical backup of PostgreSQL databases defined in "db_list" variable
#============================================================================================================

bkp_dir="/backup/pg_dump"
pg_dump_bin="/usr/local/pgsql/bin/pg_dump"
tag="PROD"
db_list=('dbname_1' 'dbname_2')
count_of_db=${#db_list[@]}
keep_days=7

message() {

echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@" >&2
}

if [[ ! -d ${bkp_dir} ]];
then
   message "FAIL    => Backup directory ${bkp_dir} doesn't exist."
   exit -10
fi

##
## Take a backup
##

for (( curr_db = 0; curr_db <= count_of_db - 1; curr_db++)); do
  message "INFO    => Starting \"${db_list[curr_db]}\" backup."
  ${pg_dump_bin} --format=plain --create --column-inserts --verbose --file="${bkp_dir}/${tag}_${db_list[curr_db]}_`date +%Y-%m-%dT%H-%M-%S`.bkp" "${db_list[curr_db]}" 2> /dev/null
  if [[ $? != 0 ]];
  then
     message "FAIL    => There are errors during \"${db_list[curr_db]}\" database backup.";
     message "        => Ensure that cluster is running and start ${pg_dump_bin} manually to identify the issue.";
  else
     message "SUCCESS => \"${db_list[curr_db]}\" backup completed."
  fi
done

##
## Find backup files older then ${keep_days} value and remove them
##

find ${bkp_dir} -maxdepth 1 -name "${tag}*" -type f -mtime +${keep_days} -exec rm -f {} \;
if [[ $? != 0 ]];
then
   message "WARNING => There is an issue with old backup files removal. Please review and investigate the issue manually.";
else
   message "CLEANUP => Done."
fi
exit 0
