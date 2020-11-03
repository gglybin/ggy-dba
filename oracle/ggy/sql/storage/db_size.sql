--#-----------------------------------------------------------------------------------
--# File Name    : db_size.sql
--#
--# Description  : Short report about the Oracle Database current size.
--#
--# Call Syntax  : @db_size
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;
set verify off;
set linesize 120
set head off

select
'================= Database Size =================',
'DATA_FILES      [MB] ............................ '||round((select sum(bytes)/1024/1024 from dba_data_files),2),
'TEMP_FILES      [MB] ............................ '||round((select nvl(sum(bytes),0)/1024/1024 from dba_temp_files),2),
'REDO_FILES      [MB] ............................ '||round((select (sum(bytes * members)/1024/1024) from gv$log),2),
'CONTROL_FILES   [MB] ............................ '||round((select sum(BLOCK_SIZE*FILE_SIZE_BLKS)/1024/1024 from v$controlfile),2),
'================================================= ',
'TOTAL [MB] ...................................... '||round((select sum(bytes)/1024/1024 from dba_data_files) +
                                                            (select nvl(sum(bytes),0)/1024/1024 from dba_temp_files) +
                                                            (select sum(bytes)/1024/1024 from sys.v_$log) +
                                                            (select sum(BLOCK_SIZE*FILE_SIZE_BLKS)/1024/1024 from v$controlfile),2)
from dual;

set head on;
