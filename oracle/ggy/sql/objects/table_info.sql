--#-----------------------------------------------------------------------------------
--# File name    : table_info.sql
--#
--# Description  : Shows information about given table - size, fragmentation, it's indexes, constaints etc.
--# 
--# Call Syntax  : @table_info (table-owner) (table-name)
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;
set verify off;

Prompt 
Prompt ##
Prompt ## Created:
Prompt ##

col "DATE" for a20

select to_char(created, 'HH24:MI DD-MON-YY') as "DATE"
from   dba_objects
where  owner='&&1'
and    object_name='&&2'
and    object_type='TABLE';

Prompt ##
Prompt ## Last statistics date:
Prompt ##

select to_char(last_analyzed, 'HH24:MI DD-MON-YY') as "STATS_DATE"
from   dba_tables
where  owner = '&&1'
and    table_name='&&2';

Prompt ##
Prompt ## Size:
Prompt ##
Prompt
Prompt NOTE: fresh table stats required to show up to date data. Run below if required:
Prompt SQL>  exec dbms_stats.gather_table_stats('TABLE_OWNER','TABLE_NAME');

col owner           for a30
col table_name      for a50
col tablespace_name for a30

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
        where  tablespace_name in (select tablespace_name from dba_tables where owner='&&1' and table_name='&&2')
       ) b
where  owner = '&&1'
and    table_name='&&2';

/*
col owner        for a30
col segment_name for a50

select owner
       ,segment_name 
       ,bytes/1024/1024 as "SIZE_MB"
from   dba_segments 
where  owner='&&1'
and    segment_name='&&2'
and    segment_type='TABLE';
*/

Prompt ##
Prompt ## Table partitions count (if any):
Prompt ##

select count(*) as "PART_COUNT"
from   dba_tab_partitions
where  table_owner='&&1'
and    table_name='&&2';

Prompt ##
Prompt ## Indexes:
Prompt ##

col index_name      for a30
col column_name     for a30
col index_type      for a20
col uniqueness      for a15
col status          for a10
col tablespace_name for a30
col "CREATED"       for a20
col "STATS_DATE"    for a20
col index_owner     for a20
col index_name      for a30

select  i.owner index_owner
       ,i.index_name
       ,c.column_name
       ,i.index_type
       ,i.uniqueness
       ,i.status
       ,i.tablespace_name
       ,to_char(o.created, 'HH24:MI DD-MON-YY') as "CREATED"
       --,to_char(i.last_analyzed, 'HH24:MI DD-MON-YY') as "STATS_DATE"
from   dba_ind_columns c
 inner join dba_indexes i on c.index_owner=i.owner and c.index_name=i.index_name
 inner join dba_objects o on i.owner=o.owner and i.index_name=o.object_name
where  c.table_owner='&&1'
and    c.table_name='&&2'
order  by o.created desc, i.owner, i.uniqueness desc, c.index_name;

Prompt ##
Prompt ## Constraints:
Prompt ##

col constraint_name  for a40
col constraint_type  for a10
col search_condition for a50
col status           for a20

select owner
       ,constraint_name
       ,constraint_type
       ,search_condition
       ,status
from   dba_constraints
where  owner='&&1'
and    table_name='&&2'
order  by constraint_name;
