--#-----------------------------------------------------------------------------------
--# File Name    : top_sch_obj.sql
--#
--# Description  : Shows top 10 schemas and objects in database ordered by it's size.
--#
--# Call Syntax  : @top_sch_obj
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;
set verify off;

Prompt
Prompt ##
Prompt ## Top 10 schemas in database
Prompt ##

col owner for a15

select *
from   (select owner
               ,round(sum(bytes)/1024/1024,2) as "Size in MB"
        from   dba_segments 
        group  by owner
        order by 2 desc)
where  rownum <=10;

Prompt ##
Prompt ## Top 10 objects in database
Prompt ##

col segment_name for a60
col segment_type for a30
col partition_name for a30
col tablespace_name for a20

select *
from   (select owner
               ,tablespace_name
               ,segment_type
               ,segment_name
               ,partition_name
               ,round(bytes/(1024*1024),2) SIZE_MB 
        from   dba_segments
        where  segment_type in ('TABLE', 'TABLE PARTITION', 'TABLE SUBPARTITION','INDEX', 'INDEX PARTITION', 'INDEX SUBPARTITION', 'TEMPORARY', 'LOBINDEX', 'LOBSEGMENT', 'LOB PARTITION')
        order by bytes desc)
where rownum <=10;

Prompt
Prompt Note: use "table_info.sql" script to get more detailed information about the particular table.
Prompt
