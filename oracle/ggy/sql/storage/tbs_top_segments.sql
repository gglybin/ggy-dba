--#-----------------------------------------------------------------------------------
--# File Name    : tbs_top_segments.sql
--#
--# Description  : Shows top 10 segments and its size in MB on provided tablespace.
--#
--# Call Syntax  : SQL> @tbs_top_segments (tablespace-name)
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;
set verify off;

Prompt
Prompt ##
Prompt ## Top 10 segments:
Prompt ##

col owner           for a15
col segment_name    for a60
col segment_type    for a30
col partition_name  for a30
col tablespace_name for a20

select *
from   (select owner
               ,tablespace_name
               ,segment_type
               ,segment_name
               ,round(bytes/(1024*1024),2) SIZE_MB
        from   dba_segments
        where  tablespace_name='&&1'
        order by bytes desc)
where rownum <=10;
