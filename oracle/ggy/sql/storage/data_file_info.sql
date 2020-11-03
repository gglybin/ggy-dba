--#-----------------------------------------------------------------------------------
--# File Name    : data_file_info.sql
--#
--# Description  : Shows information about database DATA file (size, max size, etc).
--#
--# Call Syntax  : SQL> @data_file_info (file-name)
--#
--#                SQL> @data_file_info "sysaux01.dbf"
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;
set verify off;
set linesize 120
set head off

select
'======================== INFO ==========================',
'CREATION_TIME .........................................: '||to_char(v.creation_time, 'DD-MON-YY HH24:MI:SS'),
'FILE_NAME .............................................: '||d.file_name,
'FILE_ID ...............................................: '||d.file_id,
'TABLESPACE_NAME  ......................................: '||d.tablespace_name,
'AUTOEXTENSIBLE ........................................: '||d.autoextensible,
'CURRENT_SIZE_[MB] .....................................: '||round((d.bytes/1024/1024))||' MB',
'BLOCKS ................................................: '||d.blocks,
'MAX_SIZE_[MB] .........................................: '||round((d.maxbytes/1024/1024))||' MB',
'MAX_BLOCKS ............................................: '||d.maxblocks,
'USER_DATA_[MB] ........................................: '||round((d.user_bytes/1024/1024))||' MB',
'USER_BLOCKS ...........................................: '||d.user_blocks,
'STATUS ................................................: '||d.status,
'ONLINE_STATUS .........................................: '||d.online_status,
'RELATIVE_FNO ..........................................: '||d.relative_fno,
'INCREMENT_BY ..........................................: '||d.increment_by,
'LOST_WRITE_PROTECT ....................................: '||d.lost_write_protect
from  dba_data_files d
      ,v$datafile    v
where d.file_id=v.file#
and   file_name like '%&&1'
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
from   dba_data_files
where  tablespace_name='XXXXXX'
order  by 1;
*/
