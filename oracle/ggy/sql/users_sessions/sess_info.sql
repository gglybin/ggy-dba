--#-----------------------------------------------------------------------------------
--# File Name    : sess_info.sql
--#
--# Description  : Shows basic information about the database session using given sid or pid.
--#
--# Call Syntax  : @sess_info (sid)
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;
set verify off;
set linesize 120
set head off

select
'===================== General  ==========================',
'LOGON_TIME .............................................: '||to_char(s.logon_time, 'DD-MON-YY HH24:MI'),
'SID, SERIAL# ...........................................: '||s.sid||','||s.serial#,
'OS PID .................................................: '||p.spid Server,
'USERNAME ...............................................: '||s.username,
'SCHEMA_NAME ............................................: '||s.schemaname,
'STATUS .................................................: '||s.status,
'EVENT ..................................................: '||s.event,
'===================== SQL ===============================',
'CURRENT_SQL_ID .........................................: '||nvl(s.sql_id,'-'),
'CURRENT_SQL_TEXT .......................................: '||nvl((select sql_text from gv$sqlarea where sql_id in (select sql_id from gv$session where sid='&&1')),'-'),
'PREVIOUS_SQL_ID ........................................: '||nvl(s.prev_sql_id,'-'),
'PREVIOUS_SQL_TEXT ......................................: '||nvl((select sql_text from gv$sqlarea where sql_id in (select prev_sql_id from gv$session where sid='&&1')),'-'),
'LAST_CALL_ET [Sec] .....................................: '||s.last_call_et,
'LAST_CALL_ET [Min] .....................................: '||round(s.last_call_et/60),
'===================== Connection ========================',
'INSTANCE_ID ............................................: '||s.inst_id,
'PROGRAM  ...............................................: '||nvl(s.program,'-'),
'MODULE .................................................: '||nvl(s.module,'-'),
'ACTION .................................................: '||nvl(s.action,'-'),
'TERMINAL ...............................................: '||nvl(s.terminal,'-'),
'CLIENT_MACHINE .........................................: '||nvl(s.machine,'-'),
'===================== Blockers? =========================',
'BLOCKING_STATUS ........................................: '||decode(s.final_blocking_session_status,'VALID','VALID = Blocking session exist'
                                                                                                    ,'NO HOLDER','NO HOLDER = No blockers'
                                                                                                    ,'NOT IN WAIT','NOT IN WAIT = This is not in a wait'
                                                                                                    ,'UNKNOWN','UNKNOWN = The blocking session is unknown'),  
'BLOCKING_INSTANCE ......................................: '||nvl(to_char(s.final_blocking_instance),'-'),
'BLOCKING_SID ...........................................: '||nvl(to_char(s.final_blocking_session),'-'),
'===================== PGA ===============================',
'PGA_USED_MB ............................................: '||nvl(round(p.pga_used_mem/(1024*1024), 2),0),
'===================== UNDO ==============================',
'UNDO_USED_MB ...........................................: '||nvl((select round((t.used_ublk * bs.blksize /1024/1024),2) "USED_MB"
                                                                   from   gv$transaction t
                                                                          ,gv$session s
                                                                          ,gv$rollstat r
                                                                          ,dba_rollback_segs rs
                                                                          ,(select block_size as blksize  from dba_tablespaces where contents='UNDO') bs
                                                                   where  s.saddr = t.ses_addr
                                                                   and    t.xidusn = r.usn
                                                                   and    rs.segment_id = t.xidusn
                                                                   and    s.sid='&&1'),0),
'===================== TEMP ==============================',
'TEMP_USED_MB ...........................................: '||nvl((select round(((b.blocks*p.value)/1024/1024),2) AS temp_size
                                                                   from   gv$session a,
                                                                          gv$sort_usage b,
                                                                          gv$parameter p
                                                                   where  p.name  = 'db_block_size'
                                                                   and    a.saddr = b.session_addr
                                                                   and    a.inst_id=b.inst_id
                                                                   and    a.inst_id=p.inst_id
                                                                   and    a.sid='&&1'),0)
from  gv$session s,
      gv$process p
where p.addr=s.paddr 
and   s.sid='&&1'
--and s.serial#='&&2'
--and p.spid='&&1';

set head on;
