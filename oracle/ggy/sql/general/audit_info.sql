--#-----------------------------------------------------------------------------------
--# File Name     : audit_info.sql
--#
--# Description   : Shows information about current database Audit settings.
--#
--# Call Syntax   : @audit_info
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;

col name             for a30
col value            for a60
col issys_modifiable for a16
col ispdb_modifiable for a16
col isses_modifiable for a16
col description      for a50

Prompt
Prompt ##
Prompt ## Audit Parameters:
Prompt ##

select name
       ,value
       ,issys_modifiable
       ,ispdb_modifiable
       ,isses_modifiable
       ,description
from   v$system_parameter2
where  name in ('audit_file_dest','audit_sys_operations','audit_trail');

Prompt ##
Prompt ## Audit Tables:
Prompt ##

col owner      for a10
col table_name for a15

select t.owner
       ,t.table_name
       ,t.tablespace_name
       ,t.blocks
       ,t.num_rows
       ,t.avg_row_len
       ,round(((t.blocks * b.blksize /1024/1024)),2) as "TOTAL_SIZE_MB"
       ,round((t.num_rows * t.avg_row_len /1024/1024),2) as "ACTUAL_SIZE_MB"
       ,round(((t.blocks * b.blksize /1024/1024)-(t.num_rows * t.avg_row_len /1024/1024)),2) as "FRAGMENTED_SPACE_MB"
from   dba_tables t,
       (
        select block_size blksize
        from   dba_tablespaces
        where  tablespace_name in (select tablespace_name from dba_tables where table_name='AUD$')
       ) b
where  table_name in ('AUD$')
union all
select t.owner
       ,t.table_name
       ,t.tablespace_name
       ,t.blocks
       ,t.num_rows
       ,t.avg_row_len
       ,round(((t.blocks * b.blksize /1024/1024)),2)
       ,round((t.num_rows * t.avg_row_len /1024/1024),2)
       ,round(((t.blocks * b.blksize /1024/1024)-(t.num_rows * t.avg_row_len /1024/1024)),2)
from   dba_tables t,
       (
        select block_size blksize
        from   dba_tablespaces
        where  tablespace_name in (select tablespace_name from dba_tables where table_name='FGA_LOG$')
       ) b
where  table_name in ('FGA_LOG$');

Prompt ##
Prompt ## Statement level: 
Prompt ##
Prompt
Prompt Note: all possible values for this audit level can be found at "STMT_AUDIT_OPTION_MAP".
Prompt

col user_name    for a20
col proxy_name   for a20
col audit_option for a20
col success      for a20
col failure      for a20

select * 
from   dba_stmt_audit_opts;

Prompt ##
Prompt ## Object level:
Prompt ##

col owner for a20
col object_name for a20
col object_type for a20
col alt for a5
col aud for a5
col com for a5
col del for a5
col gra for a5
col ind for a5
col ins for a5
col loc for a5
col ren for a5
col sel for a5
col upd for a5
col exe for a5
col cre for a5
col rea for a5
col wri for a5
col fbk for a5

select * 
from   dba_obj_audit_opts 
where  owner not like '%SYS%';

Prompt ##
Prompt ## Privilege level:
Prompt ##
Prompt
Prompt Note: all possible values for this audit level can be found at "SYSTEM_PRIVILEGE_MAP".
Prompt

col privilege for a20

select * from dba_priv_audit_opts;

Prompt ##
Prompt ## Useful Docs:
Prompt ##
Prompt
Prompt -> How to Plan for Oracle Database Auditing (Doc ID 1528166.1)
Prompt -> Script to Show Audit Options/Audit Trail (Doc ID 1019552.6)
Prompt -> SCRIPT: Basic example to manage AUD$ table in 11.2 with dbms_audit_mgmt (Doc ID 1362997.1)
Prompt -> How To Move The DB Audit Trails To A New Tablespace Using DBMS_AUDIT_MGMT? (Doc ID 1328239.1)
Prompt -> How to Truncate, Delete or Purge Rows from SYS.AUD$ (Doc ID 73408.1)
Prompt -> How to cleanup the log table FGA_LOG$ ? (Doc ID 402528.1)
Prompt -> The Effect Of Creating Index On Table Sys.Aud$ (Doc ID 1329731.1)
Prompt -> Known Issues When Using: DBMS_AUDIT_MGMT (Doc ID 804624.1)
Prompt
Prompt ##
Prompt ## Useful query to get info about audit events:
Prompt ##
Prompt
Prompt SQL> set lines 400 pages 1000
Prompt col audit_type for a20
Prompt col extended_timestamp for a50
Prompt col db_user for a20
Prompt col object_schema for a20
Prompt col object_name for a20
Prompt col statement_type for a20 
Prompt    select audit_type
Prompt             ,extended_timestamp
Prompt             ,db_user
Prompt             ,object_schema
Prompt             ,object_name
Prompt            ,statement_type
Prompt      from dba_common_audit_trail
Prompt      where db_user='<USER_NAME_HERE>'
Prompt      order by extended_timestamp desc;
Prompt
