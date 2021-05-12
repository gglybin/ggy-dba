--#-----------------------------------------------------------------------------------
--# File Name    : tbs_hwm_check.sql
--#
--# Description  : Shows list of all the used extents and free space in a tablespace.
--#
--# Call Syntax  : @tbs_hwm_check (tablespace-name)
--#
--# References   : https://jonathanlewis.wordpress.com/tablespace-hwm/
--#-----------------------------------------------------------------------------------

rem
rem     Notes:
rem     Quick and dirty to list extents in a tablespace
rem     in file and block order.
rem
rem     For LMTs, expect to acquire one TT lock per segment
rem     in the tablespace, and to query seg$ once for each
rem     segment in the tablespace.  This is a side effect of
rem     the mechanism invoked by accessing x$ktfbue. Also 
rem     assume that you will do one physical block read per
rem     segment (reading the segment header block for the 
rem     extent map) as this is also part of the implementation
rem     of x$ktfbue.
rem
rem     Watch out for objects in the recyclebin - they will show
rem     up as FREE in dba_free_space, but will stop you from 
rem     resizing the tablespace until you purge them. Depending
rem     on version of Oracle you may get some clues about this
rem     because each "free" extent in the recyclebin is reported
rem     as a separate extent by dba_free_space. Note that dba_extents
rem     and dba_segments behave differently, the latter reports
rem     objects in the recyclebin, the former doesn't so sum(extents)
rem     doesn't match sum(segments)
rem

set lines 400 pages 1000;
set verify off;
 
column  file_id         format 99,999
column  block_id        format 99,999,999
column  end_block       format 99,999,999
column  owner           format a10
column  partition_name  format a25      noprint
column  segment_name    format a28
 
-- spool

select
        file_id,
        block_id,
        block_id + blocks - 1   end_block,
        blocks,
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
;
--spool off
