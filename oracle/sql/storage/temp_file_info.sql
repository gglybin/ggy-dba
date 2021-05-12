--#-----------------------------------------------------------------------------------
--# File Name    : temp_file_info.sql
--#
--# Description  : Shows information about database TEMP file (size, max size, etc).
--#
--# Call Syntax  : SQL> @temp_file_info (file-name)
--#
--#                SQL> @temp_file_info "temp01.dbf"
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;
set verify off;
set linesize 120
set head off

select
'======================== INFO ==========================',
'FILE_NAME .............................................: '||file_name,
'FILE_ID ...............................................: '||file_id,
'TABLESPACE_NAME  ......................................: '||tablespace_name,
'AUTOEXTENSIBLE ........................................: '||autoextensible,
'CURRENT_SIZE_[MB] .....................................: '||round((bytes/1024/1024))||' MB',
'BLOCKS ................................................: '||blocks,
'MAX_SIZE_[MB] .........................................: '||round((maxbytes/1024/1024))||' MB',
'MAX_BLOCKS ............................................: '||maxblocks,
'USER_DATA_[MB] ........................................: '||round((user_bytes/1024/1024))||' MB',
'USER_BLOCKS ...........................................: '||user_blocks,
'STATUS ................................................: '||status,
'SHARED ................................................: '||shared,
'RELATIVE_FNO ..........................................: '||relative_fno,
'INCREMENT_BY ..........................................: '||increment_by
from  dba_temp_files
where file_name like '%&&1'
order  by 1;

set head on;

/*
Prompt
Prompt ##
Prompt ## All files in tablespace:
Prompt ##

col file_name      for a70
col autoextensible for a15

select file_name
       ,round((bytes/1024/1024)) "SIZE_MB"
       ,autoextensible
       ,round((maxbytes/1024/1024)) "MAX_SIZE_MB"
from   dba_temp_files
where  tablespace_name='xxxxxxTEMPxxxxxx'
order  by 1;
*/
