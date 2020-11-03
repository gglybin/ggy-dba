#!/bin/bash

#**************************************************************************************************
#
#   File Name    : ora_cleanup_diag.sh
#
#   Description  : Script to remove obsolete audit/trace/core/log files or folders.
#
#   Call Syntax  : bash$ ./ora_cleanup_diag.sh -h
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

1) Interactively:

   bash$ ./ora_cleanup_diag.sh <DIAG_DEST> <DEPTH>

   Example:
   --------

   bash$ /home/oracle/ora_cleanup_diag.sh /diag/19.0.0 7

2) Background:

   bash$ nohup /home/oracle/ora_cleanup_diag.sh <DIAG_DEST> <DEPTH> &

   Example:
   --------

   bash$ nohup /home/oracle/ora_cleanup_diag.sh /diag/19.0.0 7 &

3) Crontab:

   bash$ crontab -l

   05 00 * * *  /home/oracle/ora_cleanup_diag.sh /diag/19.0.0 7
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

if [[ "$#" = 0 || "$#" > 2 ]]; then
  message "ERROR: Wrong parameters provided to script."
  message "INFO:  Check usage examples below."
  help
  exit 1
elif [[ "$#" = 1 ]]; then
  if [[ "$1" = "--help" || "$1" = "-h" ]]; then
    help
    exit 0
  else
    message "ERROR: Wrong parameters provided to script."
    message "INFO:  Check usage examples below."
    help
    exit 1
  fi
elif [[ "$#" = 2 ]]; then
  if ! [[ -d "$1" ]]; then
    message "ERROR: Directory provided $1 doesn't exist." && echo ""
    exit 1
  else
    if ! [[ "$2" =~ ^[0-9]+$ ]]; then
      message "ERROR: Looks like second parameter is not a number." && echo ""
      exit 1
    fi
  fi
fi
}

##############
get_count() {

local DIAG_DIR="$1"

aud_count="$(find "${DIAG_DIR}" -name "*.aud" -type f | wc -l)"
trc_count="$(find "${DIAG_DIR}" -name "*.trc" -type f | wc -l)"
trm_count="$(find "${DIAG_DIR}" -name "*.trm" -type f | wc -l)"
core_count="$(find "${DIAG_DIR}" -name "core_*" -type d | wc -l)"
log_xml_count="$(find "${DIAG_DIR}" -name "log_*.xml" -type f | wc -l)"

echo "
--------------------------------------------------
Audit files       [*.aud]     :   ${aud_count}
Trace files       [*.trc]     :   ${trc_count}
Trace files       [*.trm]     :   ${trm_count}
Core directories  [core_*]    :   ${core_count}
Log XML files     [log_*.xml] :   ${log_xml_count}
--------------------------------------------------"
}

##############
do_cleanup() {

local DIAG_DIR="$1"
local DEPTH="$2"

message "INFO:  Removing audit files older then ${DEPTH} days ..."
find "${DIAG_DIR}" -name "*.aud" -type f -mtime +"${DEPTH}" -exec rm -f {} \;
if ! [[ $? = 0 ]]; then
  message "ERROR: Something went wrong during audit files removal. Aborting script execution now." && echo ""
  exit 1
else
  message "INFO:  Audit files removal completed."
fi

message "INFO:  Removing trace files files older then ${DEPTH} days ..."
find "${DIAG_DIR}" -name "*.trc" -type f -mtime +"${DEPTH}" -exec rm -f {} \;
if ! [[ $? = 0 ]]; then
  message "ERROR: Something went wrong during trace files removal. Aborting script execution now." && echo ""
  exit 1
else
  find "${DIAG_DIR}" -name "*.trm" -type f -mtime +"${DEPTH}" -exec rm -f {} \;
  if ! [[ $? = 0 ]]; then
    message "ERROR: Something went wrong during trace files removal. Aborting script execution now." && echo ""
    exit 1
  fi
  message "INFO:  Trace files removal completed."
fi

message "INFO:  Removing core* folders older then ${DEPTH} days ..."
find "${DIAG_DIR}" -name "core_*" -type d -mtime +"${DEPTH}" -exec rm -rf {} \;
if ! [[ $? = 0 ]]; then
  message "ERROR: Something went wrong during core* folders removal. Aborting script execution now." && echo ""
  exit 1
else
  message "INFO:  Core* folders removal completed."
fi

message "INFO:  Removing log_*.xml files older then ${DEPTH} days ..."
find "${DIAG_DIR}" -name "log_*.xml" -type f -mtime +"${DEPTH}" -exec rm -f {} \;
if ! [[ $? = 0 ]]; then
  message "ERROR: Something went wrong during log_*.xml files removal. Aborting script execution now." && echo ""
  exit 1
else
  message "INFO:  Log xml files removal completed."
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
message "INFO:  Counting number of files/directories BEFORE cleanup ..."
get_count "$1"
do_cleanup "$1" "$2"
message "INFO:  Counting number of files/directories AFTER cleanup ..."
get_count "$1"
do_script_logs_cleanup
message "LOG:   ${exec_log}"
message "INFO:  Completed!" && echo ""
exit 0
