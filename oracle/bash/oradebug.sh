#!/bin/bash

#**************************************************************************************************
#
#   File Name    : oradebug.sh
#
#   Description  : Takes hanganalyze, ashdumpseconds, systemstate dumps for post mortem analysis.
#
#   Call Syntax  : bash$ ./oradebug.sh -h
#
#   References   : --> Troubleshooting Database Hang Issues (Doc ID 1378583.1)
#                  --> How to Collect Diagnostics for Database Hanging Issues (Doc ID 452358.1)
#                  --> How to Collect Systemstate Dumps When you Cannot Connect to Oracle (Doc ID 121779.1)
#                  --> Important Customer information about using Numeric Events (Doc ID 75713.1)
#                  --> Reading and Understanding Systemstate Dumps (Doc ID 423153.1)
#                  --> EVENT: HANGANALYZE – Reference Note (Doc ID 130874.1)
#                  --> https://blog.dbi-services.com/oracle-is-hanging-dont-forget-hanganalyze-and-systemstate/
#                  --> https://tanelpoder.com/2012/05/08/oradebug-hanganalyze-with-a-prelim-connection-and-error-can-not-perform-hang-analysis-dump-without-a-process-state-object-and-a-session-state-object/
#                  --> https://grepora.com/2017/01/04/systemstate-dump/
#
#**************************************************************************************************

#*************************#
#     Script settings     #
#*************************#

#set -o xtrace
readonly exec_dir="$(cd "$(dirname "${0}")" && pwd)"
readonly exec_name="$(basename "${0}")"
readonly exec_log="${exec_name%.*}_$(date +%d-%m-%Y-%H-%M-%S).log"

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

1) For standalone instance:

   $ ./oradebug.sh sa 

2) For RAC:

   $ ./oradebug.sh rac

3) For help:

   $ ./oradebug.sh -h

OR

   $ ./oradebug.sh --help

Note: ORACLE_SID and ORACLE_HOME environment variables must be defined before running this script.
"
return 0
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

if [[ "$#" = 0 || "$#" > 1 ]]; then
  message "ERROR: Provide correct parameter value to the script."
  help
  exit 1
elif [[ "$1" = "-h" || "$1" = "--help" ]]; then
  help
  exit 0
elif [[ "$1" = "sa" ]]; then
  if [[ "${ORACLE_SID}" = "" || "${ORACLE_HOME}" = "" ]]; then
    message "ERROR: Please set ORACLE_SID / ORACLE_HOME environment variables before running this script." && echo ""
    exit 1
  else
    message "INFO:  Running script for standalone instance."
  fi
elif [[ "$1" = "rac" ]]; then
  if [[ "${ORACLE_SID}" = "" || "${ORACLE_HOME}" = "" ]]; then
    message "ERROR: Please set ORACLE_SID / ORACLE_HOME environment variables before running this script." && echo ""
    exit 1
  else
    message "INFO:  Running script for RAC cluster."
  fi
else
  message "ERROR: Provide correct parameter value to the script."
  help
  exit 1
fi
}

##############
do_dump() {

echo ""
echo "------------------------------- `date` -------------------------------"
echo ""
echo "ORACLE_SID  = ${ORACLE_SID}"
echo "ORACLE_HOME = ${ORACLE_HOME}"
echo ""

if [[ "$1" = "sa" ]]; then
  sqlplus -s -prelim / as sysdba << EOF
oradebug setorapname diag
!echo ""
!echo "INFO: Taking hanganalyze dump ..."
oradebug hanganalyze 3
!echo ""
!echo "INFO: Taking ashdumpseconds dump ..."
oradebug dump ashdumpseconds 30
!echo ""
!echo "INFO: Taking systemstate dump ..."
oradebug dump systemstate 266
!echo ""
oradebug tracefile_name
exit;
EOF
  if [[ "$?" = 0 ]]; then
    echo "--------------------------------------------------------------------------------------------"
    message "INFO:  Dump performed."
  else
    echo "--------------------------------------------------------------------------------------------"
    message "ERROR: Something went wrong during dump operation. Aborting script execution now."
    exit 1
  fi
elif [[ "$1" = "rac" ]]; then
  sqlplus -s -prelim / as sysdba << EOF
oradebug setorapname diag
!echo ""
!echo "INFO: Taking hanganalyze dump ..."
oradebug -g all hanganalyze 3
!echo ""
!echo "INFO: Taking ashdumpseconds dump ..."
oradebug -g all dump ashdumpseconds 30
!echo ""
!echo "INFO: Taking systemstate dump ..."
oradebug -g all dump systemstate 266
!echo ""
oradebug tracefile_name
exit;
EOF
  if [[ "$?" = 0 ]]; then
    echo "--------------------------------------------------------------------------------------------"
    message "INFO:  Dump performed."
  else
    echo "--------------------------------------------------------------------------------------------"
    message "ERROR: Something went wrong during dump operation. Aborting script execution now."
    exit 1
  fi
fi
}

#**************#
#     Main     #
#**************#

exec &> >(tee -a "${exec_log}")
check_running
check_param "$@"
do_dump "$@"
message "LOG:   ${exec_dir}/${exec_log}"
message "INFO:  Completed!" && echo ""
exit 0
