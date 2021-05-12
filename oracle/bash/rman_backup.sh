#!/bin/bash

#**************************************************************************************************
#
#   File Name    : rman_backup.sh
#
#   Description  : Script to perform RMAN backups - cold, full, lvl0, lvl1_dif, lvl1_cum, arch.
#
#   Call Syntax  : bash$ ./rman_backup.sh -h
#
#**************************************************************************************************

#*************************#
#     Script settings     #
#*************************#

#set -o xtrace

exec_dir="$(cd "$(dirname "${0}")" && pwd)"
exec_name="$(basename "${0}")"
exec_log="${exec_dir}/${exec_name%.*}_$(date +%Y%m%d)T$(date +%H%M%S)_$$_INITIALIZATION.log"
lock_dir="/tmp"
keep_script_log_count=2

#*******************#
#     Functions     #
#*******************#

##############
message() {

echo "" 
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')] $@" >&2
}

##############
help() {

echo "
USAGE:
------

bash$ ./rman_backup.sh <ORACLE_HOME_PATH> <ORACLE_SID> <BACKUP_TYPE> <RMAN_PARALLELISM> <COMPRESSION> <BACKUP_DESTINATION_PATH>

SUPPORTED BACKUP TYPES:
-----------------------

cold     = Full offline backup, database should be in MOUNT state.

full     = Full online backup with archive log files. All backed up archive log files will be removed (if they are not required for standby, otherwise it will be skipped).

lvl0     = Incremental full online backup with archive log files. All backed up archive log files will be removed (if they are not required for standby, otherwise it will be skipped).

lvl1_dif = Incremental differential online backup with archive log files. If there is no lvl0 backup available then this lvl1 will be as full lvl0.
           All backed up archive log files will be removed (if they are not required for standby, otherwise it will be skipped).

lvl1_cum = Incremental cumulative online backup with archive log files. If there is no lvl0 backup available then this lvl1 will be as full lvl0.
           All backed up archive log files will be removed (if they are not required for standby, otherwise it will be skipped).

arch     = Achive logs online backup. All backed up archive log files will be removed (if they are not required for standby, otherwise it will be skipped).

COMPRESSION OPTIONS:
--------------------

basic    = Default binary compression.

low      = Least impact on backup throughput and suited for environments where CPU resources are the limiting factor.

medium   = Recommended for most environments. Good combination of compression ratios and speed.

high     = Best suited for backups over slower networks where the limiting factor is network speed.

EXAMPLES:
---------

bash$ /home/oracle/rman_backup.sh /u01/app/oracle/product/19.0.0/dbhome_1 ORCL cold     8 basic /backup/ORCL

bash$ /home/oracle/rman_backup.sh /u01/app/oracle/product/19.0.0/dbhome_1 ORCL full     8 basic /backup/ORCL

bash$ /home/oracle/rman_backup.sh /u01/app/oracle/product/19.0.0/dbhome_1 ORCL lvl0     8 basic /backup/ORCL

bash$ /home/oracle/rman_backup.sh /u01/app/oracle/product/19.0.0/dbhome_1 ORCL lvl1_dif 8 basic /backup/ORCL

bash$ /home/oracle/rman_backup.sh /u01/app/oracle/product/19.0.0/dbhome_1 ORCL lvl1_cum 8 basic /backup/ORCL

bash$ /home/oracle/rman_backup.sh /u01/app/oracle/product/19.0.0/dbhome_1 ORCL arch     8 basic /backup/ORCL

SIZE ESTIMATES:
---------------

               #===============================================================================#
               #                               Compression Mode                                #
               #===================#===================#====================#==================#  
               #                   #                   #                    #                  #
               #       Basic       #        Low        #       Medium       #      High        #
               #                   #                   #                    #                  #
#==============#===================#===================#====================#==================#
#              #                   #                   #                    #                  #
# Backup size* #      15-20%       #      25-30%       #       20-25%       #      10-15%      #
#              #                   #                   #                    #                  #
#==============#===================#===================#====================#==================#

*Note: percent of database size. Above estimates are tested on synthetic SOE scheme generated using SwingBench tool. Numbers can vary - it depends on your data and whole database fragmentation.

CRONTAB EXAMPLE:
----------------

$ crontab -l

##
## Hourly Archive Logs backup:
##

05 0 * * * /home/oracle/rman_backup.sh /u01/app/oracle/product/12.1.0.2/dbhome_1 ORCL arch 8 basic /backup/ORCL

##
## Daily Level 1 Differential backup:
##

30 0 * * 1-6 /home/oracle/rman_backup.sh /u01/app/oracle/product/12.1.0.2/dbhome_1 ORCL lvl1_dif 8 basic /backup/ORCL

##
## Weekly Sunday Level 0 backup:
##

30 0 * * 0 /home/oracle/rman_backup.sh /u01/app/oracle/product/12.1.0.2/dbhome_1 ORCL lvl0 8 basic /backup/ORCL 

DOCS:
-----

Getting Started with Recovery Manager (RMAN) (Doc ID 360416.1)
A Complete Understanding of RMAN Compression (Doc ID 563427.1)
How to estimate the size of an RMAN database backup (Doc ID 1274720.1)
Rman backup retention policy (Doc ID 462978.1)
How does the RMAN Retention Policy Obsolete Incremental Backupsets and Archivelog Files (Doc ID 206862.1)
"
}

##############
check_log_dir_permissions() {

touch "${exec_log}_TEST" 2> /dev/null
if [[ $? -ne 0 ]]; then
  message "ERROR: Looks like log destination directory is not writable for \"$(whoami)\" user."
  message "INFO:  Correct permissions for \"$(whoami)\" user on \"$(dirname "${exec_log}")\" directory."
  message "INFO:  Another option is to correct \"exec_log\" variable in \"$exec_name\" script." && echo ""
  exit 1
else
  rm -f "${exec_log}_TEST"
fi
}

##############
rename_log() {

if [[ "${exec_log}" == *INITIALIZATION* ]]; then
  if [[ "$1" = "RUNNING" ]]; then
    exec_log_new="${exec_log%_INITIALIZATION*}_${2}_${3}_${1}.log"
    mv "${exec_log}" "${exec_log_new}"
    exec_log="${exec_log_new}"
  else
    exec_log_new="${exec_log%_INITIALIZATION*}_${1}.log"
    mv "${exec_log}" "${exec_log_new}"
    exec_log="${exec_log_new}"
  fi
elif [[ "${exec_log}" == *RUNNING* ]]; then
  exec_log_new="${exec_log%_RUNNING*}_${1}.log"
  mv "${exec_log}" "${exec_log_new}"
  exec_log="${exec_log_new}"
fi
}

##############
check_param() {

if [[ "$#" = 1 && ("$1" = "-h" || "$1" = "--help") ]]; then
  help && sleep 1
  rename_log HELP
  exit 0
elif [[ "$#" = 6 ]]; then
  if [[ -d "$1" ]]; then
    # Typo below is intentional
    "$1"/OPatch/opatch versionn > /dev/null 2>&1
    if [[ $? -ne 14 ]]; then
      message "ERROR: ORACLE_HOME=$1 directory exist, but looks like its not true or corrupted." && echo ""
      rename_log FAIL
      exit 1
    fi
  else
    message "ERROR: Looks like ORACLE_HOME=$1 directory doesn't exist." && echo ""
    rename_log FAIL
    exit 1
  fi
  grep -q "$2:$1" /etc/oratab
  if [[ $? -ne 0 ]]; then
    message "ERROR: Not found \"$2\" database associated with \"$1\" in \"/etc/oratab\"."
    message "INFO:  Ensure you have \"$2\" database instance running from oracle home \"$1\" on this server \"$(hostname)\"."
    message "INFO:  If you are sure - then to fix this issue just add below line at the end of \"/etc/oratab\" file:"
    echo ""
    echo "                                  $2:$1:N"
    echo ""
    rename_log FAIL
    exit 1
  fi
  if ! [[ "$3" = "cold" || "$3" = "full" || "$3" = "lvl0" || "$3" = "lvl1_dif" || "$3" = "lvl1_cum" || "$3" = "arch" ]]; then
    message "ERROR: Found unsupported backup type \"$3\"."
    message "INFO:  Run \"./$exec_name -h\" to get usage examples." && echo ""
    rename_log FAIL
    exit 1
  fi
  if [[ "$4" =~ ^[0-9]*$ ]]; then
    if [[ "$4" -eq 0 ]]; then
      message "ERROR: RMAN Parallel threads count can't be set to $4."
      message "INFO:  It should be a number >= 1." && echo ""
      rename_log FAIL
      exit 1
    else
      local server_cpu_count=$(grep -c ^processor /proc/cpuinfo)
      if [[ "${server_cpu_count}" -lt "$4" ]]; then
        message "ERROR: RMAN Parallel threads is set to \"$4\", but current server CPU count is $server_cpu_count."
        message "INFO:  Set RMAN Parallel threads count to lower value." && echo ""
        rename_log FAIL
        exit 1
      fi
    fi
  else
    message "ERROR: Not able to parse fourth parameter \"$4\"."
    message "INFO:  It should be a number >= 1." && echo ""
    rename_log FAIL
    exit 1
  fi
  if ! [[ "$5" = "basic" || "$5" = "low" || "$5" = "medium" || "$5" = "high" ]]; then
    message "ERROR: Found unsupported compression type \"$5\"."
    message "INFO:  Run \"./$exec_name -h\" to get usage examples." && echo ""
    rename_log FAIL
    exit 1
  fi
  if ! [[ -d "$6" ]]; then
    message "ERROR: Looks like backup destination directory \"$6\" doesn't exist." && echo ""
    rename_log FAIL
    exit 1
  else
    local test_file=test_$(date +%d-%m-%Y-%H-%M-%S).file
    touch "$6"/"${test_file}" 2> /dev/null
    if [[ $? -ne 0 ]]; then
      message "ERROR: Looks like backup destination directory is not writable for \"$(whoami)\" user."
      message "INFO:  Correct permissions for \"$(whoami)\" user on $6 directory." && echo ""
      rename_log FAIL
      exit 1
    else
      rm -f "$6"/"${test_file}"
    fi
   fi
else
  message "ERROR: Not able to parse parameters."
  message "INFO:  Run script with -h option to get usage examples."
  echo ""
  echo "                                  bash$ ./rman_backup.sh -h"
  echo ""
  rename_log FAIL
  exit 1
fi
}

##############
check_db_state() {

message "INFO:  Checking $2 database state ..."

export ORACLE_HOME="$1"
export ORACLE_SID="$2"
export PATH="${ORACLE_HOME}"/bin:$PATH

local check_pmon=$(ps -ef | grep pmon_${ORACLE_SID} | grep -v grep | awk '{print $NF}')

if ! [[ "${check_pmon}" = "ora_pmon_${ORACLE_SID}" ]]; then
  message "ERROR: Looks like $ORACLE_SID database instance is not running." && echo ""
  rename_log FAIL 
  exit 1
fi

local db_status=$("${ORACLE_HOME}"/bin/sqlplus -s / as sysdba <<EOF
set pagesize 0 feedback off verify off heading off echo off
select status from v\$instance;
exit;
EOF
)

if [[ "${db_status}" = "STARTED" ]]; then
  message "ERROR: Database should be in MOUNT or OPEN state to perform RMAN backup."
  message "INFO:  Current database state is \"${db_status}\" (i.e. NOMOUNT)." && echo ""
  rename_log FAIL
  exit 1
elif [[ "$3" = "cold" && ! "${db_status}" = "MOUNTED" ]]; then
  message "ERROR: If you want to perform RMAN backup with \"$3\" option - database should be in \"MOUNTED\" state."
  message "INFO:  Current database state is \"${db_status}\"." && echo ""
  rename_log FAIL
  exit 1
elif [[ "$3" = "full" || "$3" = "lvl0" || "$3" = "lvl1_dif" || "$3" = "lvl1_cum" || "$3" = "arch" ]] && [[ ! "${db_status}" = "OPEN" ]]; then
  message "ERROR: If you want to perform RMAN backup with \"$3\" option - database should be in \"OPEN\" state."
  message "INFO:  Current database state is \"${db_status}\"."
  message "NOTE:  Oracle allows to run full, lvl0 and lvl1 backups in MOUNTED state, but current script design is not." && echo ""
  rename_log FAIL
  exit 1
fi
message "INFO:  Database status is ${db_status}."
}

##############
check_arch_mode() {

message "INFO:  Checking database ARCHIVELOG mode status ..."

export ORACLE_HOME="$1"
export ORACLE_SID="$2"
export PATH="${ORACLE_HOME}"/bin:$PATH

local check_pmon=$(ps -ef | grep pmon_${ORACLE_SID} | grep -v grep | awk '{print $NF}')

if ! [[ "${check_pmon}" = "ora_pmon_${ORACLE_SID}" ]]; then
  message "ERROR: Looks like $ORACLE_SID database instance is not running." && echo ""
  rename_log FAIL
  exit 1
fi

local arch_status=$("${ORACLE_HOME}"/bin/sqlplus -s / as sysdba <<EOF
set pagesize 0 feedback off verify off heading off echo off
select log_mode from v\$database;
exit;
EOF
)

if [[ "${arch_status}" = "NOARCHIVELOG" ]]; then
  if [[ "$3" = "cold" ]]; then
    message "INFO:  Archive mode status is ${arch_status}, but backup type is set to \"$3\" so its okay to proceed."
  else
    message "ERROR: Database should be in ARCHIVELOG mode to perform RMAN backup."
    message "INFO:  Current mode is ${arch_status}." && echo ""
    rename_log FAIL
    exit 1
  fi
else
  message "INFO:  Archive mode status is ${arch_status}."
fi
}


##############
show_param_info() {

echo "
------------------------- SCRIPT PARAMETERS -----------------------------

ORACLE_HOME                : $1 
ORACLE_SID                 : $2
Backup type                : $3
RMAN Parallel Threads      : $4
RMAN Compression Mode      : $5
Backup files destination   : $6

-------------------------------------------------------------------------"
}

##############
show_rman_param() {

export ORACLE_HOME="$1"
export ORACLE_SID="$2"
export PATH="${ORACLE_HOME}"/bin:$PATH

echo ""
echo "---------------------- Save RMAN settings before backup -----------------"

"${ORACLE_HOME}"/bin/rman target / << EOF
show all;
exit;
EOF

if [[ $? = 0 ]]; then
  echo "-------------------------------------------------------------------------"
else
  echo "-------------------------------------------------------------------------"
  message "ERROR: Something went wrong during RMAN settings check. Review errors in log file." && echo ""
  rename_log FAIL
  exit 1
fi
}

##############
start_rman_cold_bkp() {

local BACKUP_TYPE="$3"
local RMAN_PARALLELISM="$4"
local COMPRESSION="$5"
local BACKUP_DESTINATION_PATH="$6"
local TAG_TIME="TAG$(date +%Y%m%d)T$(date +%H%M%S)"
local RMAN_BKP_TAG="${TAG_TIME}_FULL_COLD"

export ORACLE_HOME="$1"
export ORACLE_SID="$2"
export PATH="${ORACLE_HOME}"/bin:$PATH

echo "
------------------------------ NOTE -------------------------------------

* Cold backup is a consistent backup when the database has been \"shutdown immediate;\" or \"shutdown normal;\".

* If the database is shutdown with \"abort\" option then its NOT a consistent backup.

* Docs: How to take a Cold Backup of Database Using Rman (Doc ID 1391357.1)
        How to restore cold backup of database taken using Rman (Doc ID 1391384.1)

-------------------------------------------------------------------------"

message "INFO:  Starting RMAN Full Offline backup ..."

echo ""
echo "------------------------------ RMAN Output ------------------------------"

"${ORACLE_HOME}"/bin/rman target / << EOF
run
{
CONFIGURE CONTROLFILE AUTOBACKUP OFF;
CONFIGURE COMPRESSION ALGORITHM '${COMPRESSION}';
CONFIGURE DEVICE TYPE DISK PARALLELISM ${RMAN_PARALLELISM} BACKUP TYPE TO COMPRESSED BACKUPSET;
SET COMMAND ID TO 'RMAN COLD FULL BACKUP';
CROSSCHECK BACKUP;
CROSSCHECK ARCHIVELOG ALL;
BACKUP AS COMPRESSED BACKUPSET
TAG ${RMAN_BKP_TAG}
FULL DATABASE                FORMAT '${BACKUP_DESTINATION_PATH}/${TAG_TIME}_%d_s%s_p%p_full_cold'
CURRENT CONTROLFILE          FORMAT '${BACKUP_DESTINATION_PATH}/${TAG_TIME}_%d_s%s_p%p_ctl'
SPFILE                       FORMAT '${BACKUP_DESTINATION_PATH}/${TAG_TIME}_%d_s%s_p%p_spfile';
}
exit;
EOF

if [[ $? = 0 ]]; then
  echo "-------------------------------------------------------------------------"
  message "INFO:  RMAN Full Offline backup successfully completed."
else
  echo "-------------------------------------------------------------------------"
  message "ERROR: Something went wrong during RMAN Full Offline backup operation. Review errors in log file." && echo ""
  rename_log FAIL
  exit 1
fi
}

##############
start_rman_full_bkp() {

local BACKUP_TYPE="$3"
local RMAN_PARALLELISM="$4"
local COMPRESSION="$5"
local BACKUP_DESTINATION_PATH="$6"
local TAG_TIME="TAG$(date +%Y%m%d)T$(date +%H%M%S)"
local RMAN_BKP_TAG="${TAG_TIME}_FULL"
local RMAN_ARCH_TAG="${TAG_TIME}_ARCH"

export ORACLE_HOME="$1"
export ORACLE_SID="$2"
export PATH="${ORACLE_HOME}"/bin:$PATH

message "INFO:  Starting RMAN Full Online backup ..."

echo ""
echo "------------------------------ RMAN Output ------------------------------"

"${ORACLE_HOME}"/bin/rman target / << EOF
run
{
CONFIGURE CONTROLFILE AUTOBACKUP OFF;
CONFIGURE COMPRESSION ALGORITHM '${COMPRESSION}';
CONFIGURE DEVICE TYPE DISK PARALLELISM ${RMAN_PARALLELISM} BACKUP TYPE TO COMPRESSED BACKUPSET;
SET COMMAND ID TO 'RMAN FULL BACKUP';
CROSSCHECK BACKUP;
CROSSCHECK ARCHIVELOG ALL;
BACKUP AS COMPRESSED BACKUPSET
TAG ${RMAN_BKP_TAG}
FULL DATABASE FORMAT '${BACKUP_DESTINATION_PATH}/${TAG_TIME}_%d_s%s_p%p_full'
CURRENT CONTROLFILE          FORMAT '${BACKUP_DESTINATION_PATH}/${TAG_TIME}_%d_s%s_p%p_ctl'
SPFILE                       FORMAT '${BACKUP_DESTINATION_PATH}/${TAG_TIME}_%d_s%s_p%p_spfile'
PLUS ARCHIVELOG              FORMAT '${BACKUP_DESTINATION_PATH}/${TAG_TIME}_%d_s%s_p%p_arch';
SQL 'ALTER SYSTEM ARCHIVE LOG CURRENT';
BACKUP AS COMPRESSED BACKUPSET
TAG ${RMAN_ARCH_TAG}
ARCHIVELOG ALL DELETE ALL INPUT FORMAT '${BACKUP_DESTINATION_PATH}/${TAG_TIME}_%d_s%s_p%p_arch'
CURRENT CONTROLFILE             FORMAT '${BACKUP_DESTINATION_PATH}/${TAG_TIME}_%d_s%s_p%p_ctl';
}
exit;
EOF

if [[ $? = 0 ]]; then
  echo "-------------------------------------------------------------------------"
  message "INFO:  RMAN Full Online backup successfully completed."
else
  echo "-------------------------------------------------------------------------"
  message "ERROR: Something went wrong during RMAN Full Online backup operation. Review errors in log file." && echo ""
  rename_log FAIL
  exit 1
fi
}

##############
start_rman_lvl0_bkp() {

local BACKUP_TYPE="$3"
local RMAN_PARALLELISM="$4"
local COMPRESSION="$5"
local BACKUP_DESTINATION_PATH="$6"
local TAG_TIME="TAG$(date +%Y%m%d)T$(date +%H%M%S)"
local RMAN_BKP_TAG="${TAG_TIME}_LVL0"
local RMAN_ARCH_TAG="${TAG_TIME}_ARCH"

export ORACLE_HOME="$1"
export ORACLE_SID="$2"
export PATH="${ORACLE_HOME}"/bin:$PATH

message "INFO:  Starting RMAN Incremental Level 0 Online backup ..."

echo ""
echo "------------------------------ RMAN Output ------------------------------"

"${ORACLE_HOME}"/bin/rman target / << EOF
run
{
CONFIGURE CONTROLFILE AUTOBACKUP OFF;
CONFIGURE COMPRESSION ALGORITHM '${COMPRESSION}';
CONFIGURE DEVICE TYPE DISK PARALLELISM ${RMAN_PARALLELISM} BACKUP TYPE TO COMPRESSED BACKUPSET;
SET COMMAND ID TO 'RMAN LVL0 BACKUP';
CROSSCHECK BACKUP;
CROSSCHECK ARCHIVELOG ALL;
BACKUP AS COMPRESSED BACKUPSET 
TAG ${RMAN_BKP_TAG}
INCREMENTAL LEVEL 0 DATABASE FORMAT '${BACKUP_DESTINATION_PATH}/${TAG_TIME}_%d_s%s_p%p_lvl0'
CURRENT CONTROLFILE          FORMAT '${BACKUP_DESTINATION_PATH}/${TAG_TIME}_%d_s%s_p%p_ctl'
SPFILE                       FORMAT '${BACKUP_DESTINATION_PATH}/${TAG_TIME}_%d_s%s_p%p_spfile'
PLUS ARCHIVELOG              FORMAT '${BACKUP_DESTINATION_PATH}/${TAG_TIME}_%d_s%s_p%p_arch';
SQL 'ALTER SYSTEM ARCHIVE LOG CURRENT';
BACKUP AS COMPRESSED BACKUPSET
TAG ${RMAN_ARCH_TAG}
ARCHIVELOG ALL DELETE ALL INPUT FORMAT '${BACKUP_DESTINATION_PATH}/${TAG_TIME}_%d_s%s_p%p_arch'
CURRENT CONTROLFILE             FORMAT '${BACKUP_DESTINATION_PATH}/${TAG_TIME}_%d_s%s_p%p_ctl';
}
exit;
EOF

if [[ $? = 0 ]]; then
  echo "-------------------------------------------------------------------------"
  message "INFO:  RMAN Incremental Level 0 Online backup successfully completed."
else
  echo "-------------------------------------------------------------------------"
  message "ERROR: Something went wrong during RMAN Incremental Level 0 Online backup operation. Review errors in log file." && echo ""
  rename_log FAIL
  exit 1
fi
}

##############
start_rman_lvl1_dif_bkp() {

local BACKUP_TYPE="$3"
local RMAN_PARALLELISM="$4"
local COMPRESSION="$5"
local BACKUP_DESTINATION_PATH="$6"
local TAG_TIME="TAG$(date +%Y%m%d)T$(date +%H%M%S)"
local RMAN_BKP_TAG="${TAG_TIME}_LVL1_DIF"
local RMAN_ARCH_TAG="${TAG_TIME}_ARCH"

export ORACLE_HOME="$1"
export ORACLE_SID="$2"
export PATH="${ORACLE_HOME}"/bin:$PATH

message "INFO:  Starting RMAN Incremental Level 1 Differential Online backup ..."

echo ""
echo "------------------------------ RMAN Output ------------------------------"

"${ORACLE_HOME}"/bin/rman target / << EOF
run
{
CONFIGURE CONTROLFILE AUTOBACKUP OFF;
CONFIGURE COMPRESSION ALGORITHM '${COMPRESSION}';
CONFIGURE DEVICE TYPE DISK PARALLELISM ${RMAN_PARALLELISM} BACKUP TYPE TO COMPRESSED BACKUPSET;
SET COMMAND ID TO 'RMAN LVL1 DIF BACKUP';
CROSSCHECK BACKUP;
CROSSCHECK ARCHIVELOG ALL;
BACKUP AS COMPRESSED BACKUPSET
TAG ${RMAN_BKP_TAG}
INCREMENTAL LEVEL 1 DATABASE FORMAT '${BACKUP_DESTINATION_PATH}/${TAG_TIME}_%d_s%s_p%p_lvl1_dif'
CURRENT CONTROLFILE          FORMAT '${BACKUP_DESTINATION_PATH}/${TAG_TIME}_%d_s%s_p%p_ctl'
SPFILE                       FORMAT '${BACKUP_DESTINATION_PATH}/${TAG_TIME}_%d_s%s_p%p_spfile'
PLUS ARCHIVELOG              FORMAT '${BACKUP_DESTINATION_PATH}/${TAG_TIME}_%d_s%s_p%p_arch';
SQL 'ALTER SYSTEM ARCHIVE LOG CURRENT';
BACKUP AS COMPRESSED BACKUPSET
TAG ${RMAN_ARCH_TAG}
ARCHIVELOG ALL DELETE ALL INPUT FORMAT '${BACKUP_DESTINATION_PATH}/${TAG_TIME}_%d_s%s_p%p_arch'
CURRENT CONTROLFILE             FORMAT '${BACKUP_DESTINATION_PATH}/${TAG_TIME}_%d_s%s_p%p_ctl';
}
exit;
EOF

if [[ $? = 0 ]]; then
  echo "-------------------------------------------------------------------------"
  message "INFO:  RMAN Incremental Level 1 Differential Online backup successfully completed."
else
  echo "-------------------------------------------------------------------------"
  message "ERROR: Something went wrong during RMAN Incremental Level 1 Differential Online backup operation. Review errors in log file." && echo ""
  rename_log FAIL
  exit 1
fi
}

##############
start_rman_lvl1_cum_bkp() {

local BACKUP_TYPE="$3"
local RMAN_PARALLELISM="$4"
local COMPRESSION="$5"
local BACKUP_DESTINATION_PATH="$6"
local TAG_TIME="TAG$(date +%Y%m%d)T$(date +%H%M%S)"
local RMAN_BKP_TAG="${TAG_TIME}_LVL1_CUM"
local RMAN_ARCH_TAG="${TAG_TIME}_ARCH"

export ORACLE_HOME="$1"
export ORACLE_SID="$2"
export PATH="${ORACLE_HOME}"/bin:$PATH

message "INFO:  Starting RMAN Incremental Level 1 Cumulative Online backup ..."

echo ""
echo "------------------------------ RMAN Output ------------------------------"

"${ORACLE_HOME}"/bin/rman target / << EOF
run
{
CONFIGURE CONTROLFILE AUTOBACKUP OFF;
CONFIGURE COMPRESSION ALGORITHM '${COMPRESSION}';
CONFIGURE DEVICE TYPE DISK PARALLELISM ${RMAN_PARALLELISM} BACKUP TYPE TO COMPRESSED BACKUPSET;
SET COMMAND ID TO 'RMAN LVL1 CUM BACKUP';
CROSSCHECK BACKUP;
CROSSCHECK ARCHIVELOG ALL;
BACKUP AS COMPRESSED BACKUPSET
TAG ${RMAN_BKP_TAG}
INCREMENTAL LEVEL 1 CUMULATIVE  DATABASE FORMAT '${BACKUP_DESTINATION_PATH}/${TAG_TIME}_%d_s%s_p%p_lvl1_cum'
CURRENT CONTROLFILE                      FORMAT '${BACKUP_DESTINATION_PATH}/${TAG_TIME}_%d_s%s_p%p_ctl'
SPFILE                                   FORMAT '${BACKUP_DESTINATION_PATH}/${TAG_TIME}_%d_s%s_p%p_spfile'
PLUS ARCHIVELOG                          FORMAT '${BACKUP_DESTINATION_PATH}/${TAG_TIME}_%d_s%s_p%p_arch';
SQL 'ALTER SYSTEM ARCHIVE LOG CURRENT';
BACKUP AS COMPRESSED BACKUPSET
TAG ${RMAN_ARCH_TAG}
ARCHIVELOG ALL DELETE ALL INPUT FORMAT '${BACKUP_DESTINATION_PATH}/${TAG_TIME}_%d_s%s_p%p_arch'
CURRENT CONTROLFILE             FORMAT '${BACKUP_DESTINATION_PATH}/${TAG_TIME}_%d_s%s_p%p_ctl';
}
exit;
EOF

if [[ $? = 0 ]]; then
  echo "-------------------------------------------------------------------------"
  message "INFO:  RMAN Incremental Level 1 Cumulative Online backup successfully completed."
else
  echo "-------------------------------------------------------------------------"
  message "ERROR: Something went wrong during RMAN Incremental Level 1 Cumulative Online backup operation. Review errors in log file." && echo ""
  rename_log FAIL
  exit 1
fi
}

##############
start_rman_arch_bkp() {

local BACKUP_TYPE="$3"
local RMAN_PARALLELISM="$4"
local COMPRESSION="$5"
local BACKUP_DESTINATION_PATH="$6"
local TAG_TIME="TAG$(date +%Y%m%d)T$(date +%H%M%S)"
local RMAN_ARCH_TAG="${TAG_TIME}_ARCH"

export ORACLE_HOME="$1"
export ORACLE_SID="$2"
export PATH="${ORACLE_HOME}"/bin:$PATH

message "INFO:  Starting RMAN Archive Logs Online backup ..."

echo ""
echo "------------------------------ RMAN Output ------------------------------"

"${ORACLE_HOME}"/bin/rman target / << EOF
run
{
CONFIGURE CONTROLFILE AUTOBACKUP OFF;
CONFIGURE COMPRESSION ALGORITHM '${COMPRESSION}';
CONFIGURE DEVICE TYPE DISK PARALLELISM ${RMAN_PARALLELISM} BACKUP TYPE TO COMPRESSED BACKUPSET;
SET COMMAND ID TO 'RMAN ARCH BACKUP';
CROSSCHECK ARCHIVELOG ALL;
SQL 'ALTER SYSTEM ARCHIVE LOG CURRENT';
BACKUP AS COMPRESSED BACKUPSET
TAG ${RMAN_ARCH_TAG}
ARCHIVELOG ALL DELETE ALL INPUT FORMAT '${BACKUP_DESTINATION_PATH}/${TAG_TIME}_%d_s%s_p%p_arch'
CURRENT CONTROLFILE             FORMAT '${BACKUP_DESTINATION_PATH}/${TAG_TIME}_%d_s%s_p%p_ctl';
}
exit;
EOF

if [[ $? = 0 ]]; then
  echo "-------------------------------------------------------------------------"
  message "INFO:  RMAN Archive Logs Online backup successfully completed."
else
  echo "-------------------------------------------------------------------------"
  message "ERROR: Something went wrong during RMAN Archive Logs Online backup operation. Review errors in log file." && echo ""
  rename_log FAIL
  exit 1
fi
}

##############
do_rman_backup() {

case "$3" in

  cold) start_rman_cold_bkp "$@"
        ;;
  full) start_rman_full_bkp "$@"
        ;;
  lvl0) start_rman_lvl0_bkp "$@"
        ;;
  lvl1_dif) start_rman_lvl1_dif_bkp "$@"
        ;;
  lvl1_cum) start_rman_lvl1_cum_bkp "$@"
        ;;
  arch) start_rman_arch_bkp "$@"
        ;;
esac
}

##############
do_rman_remove_obsolete() {
 
if [[ "$3" = "full" || "$3" = "lvl0" ]]; then
  export ORACLE_HOME="$1"
  export ORACLE_SID="$2"
  export PATH="${ORACLE_HOME}"/bin:$PATH
 
  message "INFO:  Removing RMAN Expired and Obsolete backups according to current retention policy ..."
 
  echo ""
  echo "------------------------------ RMAN Delete Expired / Obsolete -----------"
 
  "${ORACLE_HOME}"/bin/rman target / << EOF
run
{
CROSSCHECK BACKUP;
CROSSCHECK ARCHIVELOG ALL;
REPORT OBSOLETE;
DELETE NOPROMPT EXPIRED BACKUP;
DELETE NOPROMPT EXPIRED ARCHIVELOG ALL;
DELETE NOPROMPT OBSOLETE;
}
exit;
EOF
 
  if [[ $? = 0 ]]; then
    echo "-------------------------------------------------------------------------"
    message "INFO:  RMAN Expired / Obsolete backups successfully removed."
  else
    echo "-------------------------------------------------------------------------"
    message "ERROR: Something went wrong during RMAN Expired / Obsolete backups removal. Review errors in log file." && echo ""
    rename_log FAIL
    exit 1
  fi
fi
}

##############
do_script_logs_cleanup() {

message "INFO:  Checking if old script log files needs to be removed ..."

local log_dir="$(cd "$(dirname "${exec_log}")" && pwd)"
local curr_logs_count=$(find "${log_dir}" -name "${exec_name%.*}*${2}_${3}*.log" -type f | wc -l)
local diff=$((${curr_logs_count} - ${keep_script_log_count}))

if [[ ${diff} -le 0 ]]; then
  message "INFO:  Script logs cleanup is not required. Keep threshold is set to ${keep_script_log_count} log file(s)."
else
  message "INFO:  Going to remove obsolete script log files."
  #find "${log_dir}" -name "${exec_name%.*}*${2}_${3}*.log" -type f -printf "%AD %AT %p\n" | sort | head -n ${diff} | xargs rm 2> /dev/null
  find "${log_dir}" -name "${exec_name%.*}*${2}_${3}*.log" -type f -printf "%AD %AT %p\n" | sort -k1.8n -k1.1nr -k1 | head -n ${diff} | xargs rm 2> /dev/null
fi
}

##############
check_running() {

pids=($(ps aux | grep "${exec_name}" | grep -v "grep" | awk {'print$2'}))
for pid in ${pids}; do
  if [[ ${pid} -ne $$ ]]; then
    bkp_count=$(find "${lock_dir}" -maxdepth 1 -name ".lock_rman_bkp_${2}_${3}*" -type f | wc -l)
    if [[ "${bkp_count}" -ne 0 ]]; then
      file_list=$(find "${lock_dir}" -maxdepth 1 -name ".lock_rman_bkp_${2}_${3}*" -type f)
      for curr_file in ${file_list}; do
        check_pid=$(cat "${curr_file}" | head -n 1)
        flag=$(ps -ef | grep "${check_pid}" | grep -v "grep" | awk {'print$2'} | head -n 1)
        if [[ ! -z "${flag}" ]]; then
          message "ERROR: Looks like RMAN \"${3}\" backup already running for ${2} instance. PID = ${check_pid}." && echo ""
          rename_log FAIL
          exit 1
        fi
      done
      #find "${lock_dir}" -maxdepth 1 -name ".lock_rman_bkp_${2}_${3}*" -type f -exec rm -f {} \;
    fi
  fi
done
find "${lock_dir}" -maxdepth 1 -name ".lock_rman_bkp_${2}_${3}*" -type f -exec rm -f {} \;
}

##############
create_lock_file() {

local lock_file="${lock_dir}"/.lock_rman_bkp_${2}_${3}_$$
touch "${lock_file}" 2> /dev/null

if [[ $? = 0 ]]; then
  echo $$ > "${lock_file}"
  echo "" >> "${lock_file}"
  echo "DO NOT REMOVE THIS FILE MANUALLY." >> "${lock_file}"
  echo "" >> "${lock_file}"
  echo "IT WILL BE REMOVE AUTOMATICALLY BY SCRIPT." >> "${lock_file}"
  message "INFO:  Lock file has been created."
else
  message "ERROR: Not able to create script lock file \"${lock_file}\"." && echo ""
  rename_log FAIL
  exit 1
fi
}

##############
remove_lock_file() {

rm -f "${lock_dir}"/.lock_rman_bkp_${2}_${3}_$$
if [[ $? = 0 ]]; then
  message "INFO:  Lock file has been removed."
else
  message "WARN:  Not able to remove script lock file \"${lock_file}\"." && echo ""
fi
}

#**************#
#     Main     #
#**************#

check_log_dir_permissions
check_param      "$@"  &> >(tee -a "${exec_log}")
rename_log RUNNING ${2} ${3} 
check_running    "$@"   &> >(tee -a "${exec_log}")
check_db_state   "$@"   &> >(tee -a "${exec_log}")
check_arch_mode  "$@"   &> >(tee -a "${exec_log}")
show_param_info  "$@"   &> >(tee -a "${exec_log}")
show_rman_param  "$@"   &> >(tee -a "${exec_log}")
create_lock_file "$@"   &> >(tee -a "${exec_log}")
do_rman_backup   "$@"   &> >(tee -a "${exec_log}")

sleep 1

#do_rman_remove_obsolete "$@"  &> >(tee -a "${exec_log}")   ## (!) NOTE: it will work only after full / lvl0 backups.
                                                            ## (!)       In all other cases it will do nothing with obsolete backups.
                                                            ## (!) NOTE: Make sure you have set correct retention policy before uncommenting this line.
                                                            ## (!)       Otherwise some backups can be removed unexpectedly for you.
                                                            ## (!) NOTE: You should keep the recovery window time period less than or equal to the value 
                                                            ## (!)       of the control file parameter CONTROL_FILE_RECORD_KEEP_TIME to prevent the record 
                                                            ## (!)       of older backups from being overwritten in the control file. (Ref. to 462978.1, 397269.1)
                                                            ## (!)       CONTROL_FILE_RECORD_KEEP_TIME = retention_period + level_0_backup interval + 1 

rename_log SUCCESS

do_script_logs_cleanup         "$@"   &> >(tee -a "${exec_log}")
message "LOG:   ${exec_log}"          &> >(tee -a "${exec_log}")
remove_lock_file               "$@"   &> >(tee -a "${exec_log}")
message "INFO:  Completed!"           &> >(tee -a "${exec_log}")
exit 0
