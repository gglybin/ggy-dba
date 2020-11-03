--#-----------------------------------------------------------------------------------
--# File Name    : tbs_info.sql
--#
--# Description  : Shows information about tablespace and it's usage.
--#
--# Call Syntax  : @tbs_info (tablespace-name)
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;
set verify off;

Prompt
Prompt ##
Prompt ## General:
Prompt ##

col tablespace_name   for a40
col status            for a15
col contents          for a10
col bigfile           for a10
col extent_management for a20

select tablespace_name
       ,status
       ,block_size
       ,contents
       ,bigfile
       ,extent_management
from   dba_tablespaces
where  tablespace_name='&&1';

Prompt ##
Prompt ## Usage:
Prompt ##

col "TABLESPACE_NAME"   for a40
col "USED_W_FRAG_MB"    for 99,999,999
col "FREE_MB"           for 99,999,999
col "SUM_FILES_MB"      for 99,999,999
col "MAX_POSS_SIZE_MB"  for 99,999,999

select p1.*
from  (select fs.tablespace_name                                     "TABLESPACE_NAME"
              ,(df.totalspace - fs.freespace)                        "USED_W_FRAG_MB"
              ,fs.freespace                                          "FREE_MB"
              ,df.totalspace                                         "SUM_FILES_MB"
              ,(select round((sum(decode(autoextensible,'YES',maxbytes,bytes)) / 1024 / 1024))
                from   dba_data_files
                where  tablespace_name='&&1'
               ) as "MAX_POSS_SIZE_MB"
              ,round(100 * (fs.freespace / df.totalspace))           "FREE %"
              ,(100 - round(100 * (fs.freespace / df.totalspace)))   "USED %"
       from
              (select tablespace_name
                      ,round(sum(bytes) / 1048576) TotalSpace
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
and   p1."TABLESPACE_NAME"='&&1'
order by p1."SUM_FILES_MB" desc, p1."USED %" desc;

Prompt ##
Prompt ## File types:
Prompt ##

col "AUTOEXTENSIBLE?"  for a20
col "COUNT_OF_FILES"   for 99,999,999

select autoextensible "AUTOEXTENSIBLE?"
       ,count(*)      "COUNT_OF_FILES"
from   dba_data_files 
where  tablespace_name='&&1'
group  by autoextensible
order  by 2 desc;

Prompt ##
Prompt ## Locations:
Prompt ##

break on report
compute sum label 'TOTAL' of COUNT_OF_FILES on report

col "PATH" for a80

select substr(file_name, 1, instr(file_name, '/', -1)) "PATH"
       ,count(*) "COUNT_OF_FILES"
from   (select file_name from dba_data_files where tablespace_name='&&1') 
group  by substr(file_name, 1, instr(file_name, '/', -1))
order  by 2 desc;
