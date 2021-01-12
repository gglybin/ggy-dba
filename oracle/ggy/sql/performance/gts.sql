--#-----------------------------------------------------------------------------------
--# File name    : gts.sql
--#
--# Description  : Collect table statistics.
--#
--# Call Syntax  : SQL> @gts (table-owner) (table-name)
--#
--# Useful       : https://blogs.oracle.com/optimizer/how-does-autosamplesize-work-in-oracle-database-11g
--#                https://blogs.oracle.com/optimizer/how-does-the-methodopt-parameter-work
--#                https://www.oracle.com/technetwork/database/bi-datawarehousing/twp-bp-for-stats-gather-12c-1967354.pdf
--#-----------------------------------------------------------------------------------
 
set lines 400 pages 1000;
set verify off;
set feedback off;
set serveroutput on;
 
whenever sqlerror exit sql.sqlcode rollback;
 
DECLARE
  v_stats_lock varchar2(10);
  v_stats_type varchar2(10);
  v_stats_date varchar2(30);
BEGIN
  select to_char(last_analyzed, 'HH24:MI DD-MON-YY') into v_stats_date from dba_tables where owner='&&1' and table_name='&&2';
  dbms_output.put_line(chr(10)||'INFO: &&1'||'.'||'&&2 table last stats collection date is "'|| v_stats_date ||'"');
  dbms_output.put_line(chr(10)||'INFO: Checking if stats for table &&1'||'.'||'&&2 is locked.');
  select stattype_locked into v_stats_lock from dba_tab_statistics where owner='&&1' and table_name='&&2' and rownum = 1;
  if v_stats_lock is not null then
    dbms_output.put_line(chr(10)||'INFO: Stats is locked (type = '|| v_stats_lock ||'). Going to unlock it first.');
    dbms_stats.unlock_table_stats('&&1','&&2');
    dbms_output.put_line(chr(10)||'INFO: Stats unlocked.');
  else
    dbms_output.put_line(chr(10)||'INFO: Stats is NOT locked - no additional actions required.');
  end if;
  dbms_output.put_line(chr(10)||'INFO: Stats collection is in progress ...');
  dbms_stats.gather_table_stats (
    ownname => '&&1',
    tabname => '&&2',
    cascade => true, -- for collecting stats for respective indexes
    method_opt => 'for all columns size auto', -- will automatically determine which columns need histograms based on data from SYS.COL_USAGE$
    granularity => 'ALL', -- pertinent only if table is partitioned. ALL means to gather for subpartitions, partition and global.
    estimate_percent => dbms_stats.auto_sample_size, -- since 11g its recommended to use auto sample
    degree => 2); -- parallel
  dbms_output.put_line(chr(10)||'INFO: Stats collection completed.');
  if v_stats_lock is not null then
    dbms_output.put_line(chr(10)||'INFO: Going to lock stats back.');
    dbms_stats.lock_table_stats('&&1','&&2');
    dbms_output.put_line(chr(10)||'INFO: Locked.');
  end if;
  select to_char(last_analyzed, 'HH24:MI DD-MON-YY') into v_stats_date from dba_tables where owner='&&1' and table_name='&&2';
  dbms_output.put_line(chr(10)||'INFO: Current stats for &&1'||'.'||'&&2 table as of "'|| v_stats_date ||'"');
END;
/
 
set verify on;
set feedback on;
set serveroutput off;
