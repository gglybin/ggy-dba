#!/bin/bash

#**************************************************************************************************
#
#   File Name    : ora_cleanup_archlogs.sh
#
#   Description  : Script to remove obsolete database archive log files.
#
#   Call Syntax  : bash$ ./ora_cleanup_archlogs.sh -h
#
#**************************************************************************************************

#*************************#
#     Script settings     #
#*************************#

#set -o xtrace
readonly exec_dir="$(cd "$(dirname "${0}")" && pwd)"
readonly exec_name="$(basename "${0}")"
readonly exec_log="${exec_dir}/${exec_name%.*}_$(date +%d-%m-%Y-%H-%M-%S).log"
readonly keep_script_log_count=7

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
---------

bash$ ./ora_cleanup_archlogs.sh <ORACLE_HOME_PATH> <ORACLE_SID> <DEPTH> [<FORCE>]

Examples:
---------

1) Remove archive logs older than 24h:

   bash$ /home/oracle/ora_cleanup_archlogs.sh /oracle/app/oracle/product/19.0.0/dbhome_1 ORCL 1

OR

   bash$ /home/oracle/ora_cleanup_archlogs.sh /oracle/app/oracle/product/19.0.0/dbhome_1 ORCL 1 force

2) Remove archive logs older than 1h:

   bash$ /home/oracle/ora_cleanup_archlogs.sh /oracle/app/oracle/product/19.0.0/dbhome_1 ORCL 1/24

OR

   bash$ /home/oracle/ora_cleanup_archlogs.sh /oracle/app/oracle/product/19.0.0/dbhome_1 ORCL 1/24 force
"
}

##############
check_running() {

pids=($(ps aux | grep "${exec_name}" | grep -v "grep" | awk {'print$2'}))
for pid in ${pids}; do
  if [[ ${pid} -ne $$ ]]; then
    message "ERROR: Script already running. Process ID = ${pid}" && echo ""
    exit 1
  fi
done
}

##############
check_param() {

if [[ "$#" = 3 || "$#" = 4 ]]; then
  if ! [[ -d "$1" ]]; then
    message "ERROR: Looks like ORACLE_HOME directory doesn't exist." && echo ""
    exit 1
  fi
  grep -q "$2:$1" /etc/oratab
  if [[ $? -ne 0 ]]; then
    message "ERROR: Not found $2 database associated with $1 in /etc/oratab." && echo ""
    exit 1
  fi
  if ! [[ "$3" =~ ^[0-9]+\/?[1-9]*$ ]]; then
     message "ERROR: Not able to parse third parameter = $3." && echo ""
     exit 1
  fi
  if [[ $# = 4 ]]; then
    if ! [[ "$4" = "force" ]]; then
      message "ERROR: Looks like fouth parameter is not set to \"force\"." && echo ""
      exit 1
    fi
  fi
elif [[ "$#" = 1 && ("$1" = "-h" || "$1" = "--help") ]]; then
  help
  exit 0
else
  message "ERROR: Not able to parse parameters."
  message "INFO:  Check usage examples below."
  help
  exit 1
fi
}

##############
check_db_status() {

message "INFO:  Checking $2 database status ..."

export ORACLE_HOME="$1"
export ORACLE_SID="$2"
export PATH="${ORACLE_HOME}"/bin:$PATH

local check_pmon=$(ps -ef | grep pmon_${ORACLE_SID} | grep -v grep | awk '{print $NF}')

if ! [[ "${check_pmon}" = "ora_pmon_${ORACLE_SID}" ]]; then
  message "ERROR: Looks like $ORACLE_SID database instance is not running." && echo ""
  exit 1
fi

local db_status=$("${ORACLE_HOME}"/bin/sqlplus -s / as sysdba <<EOF
set pagesize 0 feedback off verify off heading off echo off
select status from v\$instance;
exit;
EOF
)

if [[ "${db_status}" = "STARTED" ]]; then
  message "ERROR: Database should be in MOUNT or OPEN mode to remove obsolete archive logs using RMAN."
  message "INFO:  Current status is ${db_status} = NOMOUNT." && echo ""
  exit 1
else
  message "INFO:  Database status is ${db_status}."
fi
}

##############
do_rman_cmd() {

local DEPTH="$3"
local FORCE="$4"

export ORACLE_HOME="$1"
export ORACLE_SID="$2"
export PATH="${ORACLE_HOME}"/bin:$PATH

message "INFO:  Removing obsolete archive log files ..."

echo ""
echo "------------------------------ RMAN Output ------------------------------"

"${ORACLE_HOME}"/bin/rman target / << EOF
CROSSCHECK ARCHIVELOG ALL;
DELETE NOPROMPT EXPIRED ARCHIVELOG ALL;
DELETE NOPROMPT ${FORCE} ARCHIVELOG ALL COMPLETED BEFORE 'SYSDATE - ${DEPTH}';
exit;
EOF

if [[ $? = 0 ]]; then
  echo "-------------------------------------------------------------------------"
  message "INFO:  Obsolete archive log files have been removed."
else
  echo "-------------------------------------------------------------------------"
  message "ERROR: Something went wrong during RMAN removal operation. Try it manually." && echo ""
  exit 1
fi
}

##############
do_script_logs_cleanup() {

message "INFO:  Checking if old script log files needs to be removed ..."

local log_dir="$(cd "$(dirname "${exec_log}")" && pwd)"
local curr_logs_count=$(find "${log_dir}" -name "${exec_name%.*}*.log" -type f | wc -l)
local diff=$((${curr_logs_count} - ${keep_script_log_count}))

if [[ ${diff} -le 0 ]]; then
  message "INFO:  Script logs cleanup is not required. Keep threshold is set to ${keep_script_log_count} log files."
else
  message "INFO:  Going to remove obsolete script log files."
  #find "${log_dir}" -name "${exec_name%.*}*.log" -type f -printf "%p\n" | sort | head -n ${diff} | xargs rm
  find "${log_dir}" -name "${exec_name%.*}*.log" -type f -printf "%AD %AT %p\n" | sort | head -n ${diff} | xargs rm 2> /dev/null
fi
}

#**************#
#     Main     #
#**************#

exec &> >(tee -a "${exec_log}")
check_running
check_param "$@"
check_db_status "$1" "$2"
do_rman_cmd "$@"
do_script_logs_cleanup
message "LOG:   ${exec_log}"
message "INFO:  Completed!" && echo ""
exit 0
