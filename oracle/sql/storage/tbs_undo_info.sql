--#-----------------------------------------------------------------------------------
--# File Name    : tbs_undo_info.sql
--#
--# Description  : Shows information about UNDO tablespace (usage, size, files count and it's location, etc).
--#
--# Call Syntax  : @tbs_undo_info
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;

Prompt
Prompt ##
Prompt ## Info:
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
where  contents='UNDO';

Prompt ##
Prompt ## File types:
Prompt ##

col "AUTOEXTENSIBLE?"  for a20
col "COUNT_OF_FILES"   for 99,999,999

select autoextensible "AUTOEXTENSIBLE?"
       ,count(*)      "COUNT_OF_FILES"
from   dba_data_files
where  tablespace_name in (select tablespace_name from dba_tablespaces where contents='UNDO')
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
from   (select file_name from dba_data_files where tablespace_name in (select tablespace_name from dba_tablespaces where contents='UNDO'))
group  by substr(file_name, 1, instr(file_name, '/', -1))
order  by 2 desc;

Prompt ##
Prompt ## Size:
Prompt ##

col "UNDO_SIZE_MB"        for 99,999,999
col "UNDO_RETENTION_SEC"  for a20
col "NEEDED_UNDO_SIZE_MB" for 99,999,999

select
       m.maxsize "MAX_POSS_SIZE_MB",
       d.undo_size/(1024*1024) "UNDO_SIZE_MB",
       e.value "UNDO_RETENTION_SEC",
       round((to_number(e.value) * to_number(f.value) * g.undo_block_per_sec) / (1024*1024),2) "NEEDED_UNDO_SIZE_MB"
from (
      select sum(a.bytes) undo_size
      from   v$datafile a
             ,v$tablespace b
             ,dba_tablespaces c
      where  c.contents = 'UNDO'
      and    c.status = 'ONLINE'
      and    b.name = c.tablespace_name
      and    a.ts# = b.ts#
     ) d,
     v$parameter e,
     v$parameter f,
    (
     select max(undoblks/((end_time-begin_time)*3600*24))
     undo_block_per_sec
     FROM v$undostat
    ) g,
    (
     select round((sum(decode(f.autoextensible,'YES',f.maxbytes,bytes)) / 1024 / 1024)) maxsize
     from   dba_tablespaces t
           ,dba_data_files f
     where  t.tablespace_name=f.tablespace_name
     and t.contents = 'UNDO'
    ) m
where e.name = 'undo_retention'
and   f.name = 'db_block_size';

Prompt ##
Prompt ## Usage:
Prompt ##

select y.tablespace_name
       ,y.totmb "TOTAL_MB"
       ,round(x.usedmb,2) "USED_MB"
       ,round(x.usedmb * 100 / y.totmb, 2) "USAGE_%"
from   (
        select a.tablespace_name
               ,nvl(sum(bytes), 0) / ( 1024 * 1024 ) usedmb
        from   dba_undo_extents a
        where  tablespace_name in (
                                   select upper(value)
                                   from   gv$parameter
                                   where  name='undo_tablespace'
                                  )
        and    status in ('ACTIVE','UNEXPIRED')
        group  by a.tablespace_name
       ) x,
       (
        select b.tablespace_name
               ,sum(bytes) / ( 1024 * 1024 ) totmb
        from   dba_data_files b
        where  tablespace_name IN (
                                   select upper(value)
                                   from   gv$parameter
                                   where  name='undo_tablespace')
        group  by b.tablespace_name
        ) y
where   y.tablespace_name = x.tablespace_name
order   by y.tablespace_name;

Prompt ##
Prompt ## Usage by Extent type:
Prompt ##
Prompt
Prompt -> ACTIVE    = system is using currently
Prompt -> EXPIRED   = used for read consistency
Prompt -> UNEXPIRED = extents which can be reused

select status
       ,round(sum_bytes / (1024*1024), 0) "USED_MB"
       ,round((sum_bytes / undo_size) * 100, 0) "USAGE_%"
from   (
        select status
               ,sum(bytes) sum_bytes
        from   dba_undo_extents
        group  by status
       ),
       (
        select sum(a.bytes) undo_size
        from   dba_tablespaces c
        join   v$tablespace b on b.name = c.tablespace_name
        join   v$datafile a on a.ts# = b.ts#
        where  c.contents='UNDO'
        and    c.status='ONLINE'
       );

Prompt ##
Prompt ## Usage by Session:
Prompt ##

col username for a20

select s.username,
       s.sid,
       s.serial#,
       t.used_ublk,
       round((t.used_ublk * bs.blksize /1024/1024),2) "USED_MB",
       t.used_urec,
       rs.segment_name,
       r.rssize,
       r.status
from   v$transaction t
       ,v$session s
       ,v$rollstat r
       ,dba_rollback_segs rs
       ,(select block_size as blksize  from dba_tablespaces where contents='UNDO') bs
where  s.saddr = t.ses_addr
and    t.xidusn = r.usn
and    rs.segment_id = t.xidusn
order  by "USED_MB" desc;
