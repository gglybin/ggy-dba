--#-----------------------------------------------------------------------------------
--# File Name    : sess_info_by_undo_used.sql
--#
--# Description  : Shows top 50 sessions ordered by UNDO usage.
--#
--# Call Syntax  : SQL> @sess_info_by_undo_used
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;

Prompt
Prompt ##
Prompt ## Top 50 sessions ordered by UNDO usage:
Prompt ##

col "SID,SERIAL" for a15
col username     for a20
col schemaname   for a20
col osuser       for a20
col segment_name for a40
col machine      for a50

select *
from (select s.sid||','||s.serial# as "SID,SERIAL"
             ,s.username
             ,s.schemaname
             ,s.osuser
             ,round((t.used_ublk * bs.blksize /1024/1024),2) "USED_MB"
             -- ,t.used_ublk
             -- ,t.used_urec
             ,rs.segment_name "UNDO_SEGMENT_NAME"
             -- ,r.rssize
             -- ,r.status
             ,s.sql_id
             ,s.machine
      from   gv$transaction t
             ,gv$session s
             ,gv$rollstat r
             ,dba_rollback_segs rs
             ,(select block_size as blksize  from dba_tablespaces where contents='UNDO') bs
      where  s.saddr = t.ses_addr
      and    t.xidusn = r.usn
      and    rs.segment_id = t.xidusn
      order  by t.used_ublk desc
     )
where rownum <=50;

Prompt
Prompt Note: use "sess_info.sql" script to get more detailed information about the particular session.
Prompt
