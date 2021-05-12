--#-----------------------------------------------------------------------------------
--# File Name    : hwm_df_resize_check.sql
--#
--# Description  : Prepare statement for datafile resize above the high water mark.
--#
--# Call Syntax  : @hwm_df_resize_check
--#
--# References   : https://blog.dbi-services.com/resize-your-oracle-datafiles-down-to-the-minimum-without-ora-03297/
--#-----------------------------------------------------------------------------------

rem
rem -> I generate the resize statements only for datafiles which are autoextensible. 
rem    This is because I want to be sure that the datafiles can grow back to their original size if needed.
rem
rem -> When datafile is not autoextensible, or maxsize is not higher than the current size, I only generate a comment.
rem
rem -> When a datafile has no extents at all I generate a resize to 5MB. 
rem    I would like to find the minimum possible size (without getting ORA-3214) but my test do not validate yet what is documented in MOS. 
rem    If anyone has an idea, please share.
rem
rem -> There is probably a way to get that high water mark in a cheaper way. Because the alter statement gives the ORA-03297 much quicker. 
rem    Information is probably available in the datafile headers, without going to segment headers, but I don’t know if it is exposed in a safe way. 
rem    If you have an idea, once again, please share.
rem

set linesize 1000 pagesize 0 feedback off trimspool on

with
 hwm as (
  -- get highest block id from each datafiles ( from x$ktfbue as we don't need all joins from dba_extents )
  select /*+ materialize */ ktfbuesegtsn ts#,ktfbuefno relative_fno,max(ktfbuebno+ktfbueblks-1) hwm_blocks
  from sys.x$ktfbue group by ktfbuefno,ktfbuesegtsn
 ),
 hwmts as (
  -- join ts# with tablespace_name
  select name tablespace_name,relative_fno,hwm_blocks
  from hwm join v$tablespace using(ts#)
 ),
 hwmdf as (
  -- join with datafiles, put 5M minimum for datafiles with no extents
  select file_name,nvl(hwm_blocks*(bytes/blocks),5*1024*1024) hwm_bytes,bytes,autoextensible,maxbytes
  from hwmts right join dba_data_files using(tablespace_name,relative_fno)
 )
select
 case when autoextensible='YES' and maxbytes>=bytes
 then -- we generate resize statements only if autoextensible can grow back to current size
  '/* reclaim '||to_char(ceil((bytes-hwm_bytes)/1024/1024),999999)
   ||'M from '||to_char(ceil(bytes/1024/1024),999999)||'M */ '
   ||'alter database datafile '''||file_name||''' resize '||ceil(hwm_bytes/1024/1024)||'M;'
 else -- generate only a comment when autoextensible is off
  '/* reclaim '||to_char(ceil((bytes-hwm_bytes)/1024/1024),999999)
   ||'M from '||to_char(ceil(bytes/1024/1024),999999)
   ||'M after setting autoextensible maxsize higher than current size for file '
   || file_name||' */'
 end SQL
from hwmdf
where
 bytes-hwm_bytes>1024*1024 -- resize only if at least 1MB can be reclaimed
order by bytes-hwm_bytes desc
/
