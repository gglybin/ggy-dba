--#-----------------------------------------------------------------------------------
--# File Name    : tbs_usage_info.sql
--#
--# Description  : Shows usage information about all data (i.e. exclude undo/temp) tablespaces.
--#
--# Call Syntax  : SQL> @tbs_usage_info
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;

Prompt
Prompt ##
Prompt ## Usage (except UNDO / TEMP):
Prompt ##

col "TABLESPACE_NAME"    for a40
col "USED_W_FRAG_MB"     for 99,999,999
col "FREE_MB"            for 99,999,999
col "SUM_FILES_MB"       for 99,999,999
col "MAX_POSS_SIZE_MB"   for 99,999,999
col "BIGFILE"            for a8

select p1."TABLESPACE_NAME"
       ,p2.BIGFILE
       ,p1."USED_W_FRAG_MB"
       ,p1."FREE_MB"
       ,p1."CURRENT_SUM_FILES_MB"
       ,p1."MAX_POSS_SIZE_MB"
       ,round((100 * p1."USED_W_FRAG_MB" / p1."MAX_POSS_SIZE_MB"),3) "USAGE %"
from  (select fs.tablespace_name                                     "TABLESPACE_NAME"
              ,(df.totalspace - fs.freespace)                        "USED_W_FRAG_MB"
              ,fs.freespace                                          "FREE_MB"
              ,df.totalspace                                         "CURRENT_SUM_FILES_MB"
              ,df.max_poss_size                                      "MAX_POSS_SIZE_MB"
       from
              (select tablespace_name
                      ,round(sum(bytes) / 1048576) TotalSpace
                      ,round(((sum(decode(autoextensible,'YES',maxbytes,bytes))) / 1024 / 1024)) max_poss_size
               from   dba_data_files
               group  by tablespace_name
              ) df,
             (select  tablespace_name
                      ,round(sum(bytes) / 1048576) FreeSpace
              from    dba_free_space
              group   by tablespace_name
             ) fs
       where df.tablespace_name = fs.tablespace_name
      ) p1,
      dba_tablespaces p2
where p2.tablespace_name=p1."TABLESPACE_NAME"
and   p2.contents='PERMANENT'
order by p1."CURRENT_SUM_FILES_MB" desc, "USAGE %" desc;

Prompt
Prompt Note: use "tbs_undo_info.sql" to get usage info about UNDO tablespace.
Prompt
Prompt Note: use "tbs_temp_info.sql" to get usage info about TEMP tablespace.
Prompt
