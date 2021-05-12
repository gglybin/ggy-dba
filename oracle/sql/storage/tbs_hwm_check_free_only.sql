--#-----------------------------------------------------------------------------------
--# File Name    : tbs_hwm_check_free_only.sql
--#
--# Description  : Shows tablespace holes and its size.
--#
--# Call Syntax  : @tbs_hwm_check_free_only (tablespace-name)
--#
--# References   : https://jonathanlewis.wordpress.com/tablespace-hwm/
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;
set verify off;

break on report
compute sum label 'TOTAL' of BLOCKS, SIZE_MB on report
 
column  file_id         format 99,999
column  block_id        format 99,999,999
column  end_block       format 99,999,999
column  owner           format a10
column  partition_name  format a25      noprint
column  segment_name    format a28
 
-- spool

select * from (
select
        file_id,
        block_id,
        block_id + blocks - 1   end_block,
        blocks,
        blocks * (select block_size from dba_tablespaces where tablespace_name='&&1') / 1024 / 1024   size_mb,
        owner,
        segment_name,
        partition_name,
        segment_type
from
        dba_extents
where
        tablespace_name = upper('&&1')
union all
select
        file_id,
        block_id,
        block_id + blocks - 1     end_block,
        blocks,
        blocks * (select block_size from dba_tablespaces where tablespace_name='&&1') / 1024 / 1024   size_mb,
        'free'                    owner,
        '******free (hole)******' segment_name,
        null                      partition_name,
        null                      segment_type
from 
        dba_free_space 
where 
        tablespace_name = upper('&&1')
order by 
        1,2
) where owner='free' order by 4 desc;


--spool off
