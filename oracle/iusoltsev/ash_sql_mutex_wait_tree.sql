--
-- ASH wait tree for Waits Event or SQL_ID
-- Usage: SQL> @ash_sql_wait_tree "event = 'log file sync'" 100
-- http://iusoltsev.wordpress.com
--

set echo off feedback off heading on timi off pages 1000 lines 500 VERIFY OFF

col INST_ID for 9999999
col WAIT_LEVEL for 999
col BLOCKING_TREE for a30
col EVENT for a40
col SQL_TEXT for a100
col MODULE for a40
col CLIENT_ID for a40
col WAITS for 999999
col AVG_WAIT_TIME_MS for 999999
col DATA_OBJECT for a52

with ash as (select /*+ materialize*/ CAST(sample_time AS DATE) as stime, s.* from gv$active_session_history s &3
--		where sample_time > sysdate-1/24
		)
select LEVEL as LVL,
       inst_id,
--       BLOCKING_INST_ID,
       LPAD(' ',(LEVEL-1)*2)||--decode(ash.session_type,'BACKGROUND',REGEXP_SUBSTR(program, '\([^\)]+\)'), nvl2(qc_session_id, 'PX', 'FOREGROUND')) as BLOCKING_TREE,
        case when REGEXP_INSTR(program, '\([A-Z]...\)') = 0 then '(USER)'
          when REGEXP_INSTR(program, '\(ARC.\)')     > 0 then '(ARC.)'
          when REGEXP_INSTR(program, '\(O...\)')     > 0 then '(O...)'
          when REGEXP_INSTR(program, '\(P...\)')     > 0 then '(P...)'
          else REGEXP_REPLACE(REGEXP_SUBSTR(program, '\([^\)]+\)'), '([[:digit:]])', '.')
        end as BLOCKING_TREE,
--       case when module not like 'oracle%' then substr(module,1,9) else module end as MODULE,
       REGEXP_SUBSTR(client_id, '.+\#') as CLIENT_ID,
       decode(session_state, 'WAITING', EVENT, 'On CPU / runqueue') as EVENT,
--       upper(lpad(trim(to_char(p1,'xxxxxxxxxxxxxxxx')),16,'0')) as p1raw,
       p1,
       p3,
       count(1) as WAITS_COUNT,
       min(sample_time),
       max(sample_time),
       count(distinct sql_exec_id) as EXECS_COUNT,
       round(avg(time_waited) / 1000) as AVG_WAIT_TIME_MS,
--round(sum(case when time_waited > 0 then greatest(1, (1000000/time_waited)) else 0 end)) as est_waits, -- http://www.nocoug.org/download/2013-08/NOCOUG_201308_ASH_Architecture_and_Advanced%20Usage.pdf
--round(sum(1000)/decode(round(sum(case when time_waited > 0 then greatest(1, (1000000/time_waited)) else 0 end)),0,1,round(sum(case when time_waited > 0 then greatest(1, (1000000/time_waited)) else 0 end)))) as est_avg_latency_ms,
       count(distinct inst_id||session_id||session_serial#) as SESS_COUNT,
       p.owner||'.'||p.object_name||'.'||p.procedure_name as PLSQL_OBJECT_ID,
       o.owner||'.'||o.object_name||'.'||o.subobject_name as DATA_OBJECT,
       blocking_session_status||' i#'||blocking_inst_id as BLOCK_SID,
       sql_ID
--       ,sql_plan_line_ID
--       ,sql_plan_operation||' '||sql_plan_options
       ,trim(replace(replace(replace(dbms_lob.substr(sql_text,100),chr(10)),chr(13)),chr(9))) as sql_text
  from --gv$active_session_history
      ash
       left join dba_hist_sqltext hs using(sql_id)
       left join dba_procedures   p  on nvl(plsql_entry_object_id, plsql_object_id) = p.object_id
                                    and nvl(plsql_entry_subprogram_id, plsql_subprogram_id) = p.subprogram_id
       left join dba_objects      o  on ash.current_obj# = o.object_id
 start with p1text = 'idn' and p3text = 'where' and &1-- mutex related events
connect by nocycle (--ash.SAMPLE_ID       = prior ash.SAMPLE_ID or 
                    trunc(ash.sample_time) = trunc(prior ash.sample_time) and
                    abs(to_char(ash.sample_time,'SSSSS') - to_char(prior ash.sample_time,'SSSSS')) <= 1)
                and ash.SESSION_ID      = prior decode(trunc(P2/4294967296),0,trunc(P2/65536),trunc(P2/4294967296))
--              and ash.SESSION_SERIAL# = prior ash.BLOCKING_SESSION_SERIAL#
                and ash.INST_ID         = prior ash.INST_ID
 group by LEVEL,
          inst_id,
--          BLOCKING_INST_ID,
        case when REGEXP_INSTR(program, '\([A-Z]...\)') = 0 then '(USER)'
          when REGEXP_INSTR(program, '\(ARC.\)')     > 0 then '(ARC.)'
          when REGEXP_INSTR(program, '\(O...\)')     > 0 then '(O...)'
          when REGEXP_INSTR(program, '\(P...\)')     > 0 then '(P...)'
          else REGEXP_REPLACE(REGEXP_SUBSTR(program, '\([^\)]+\)'), '([[:digit:]])', '.')
        end,
--       case when module not like 'oracle%' then substr(module,1,9) else module end,
          REGEXP_SUBSTR(client_id, '.+\#'),
          decode(session_state, 'WAITING', EVENT, 'On CPU / runqueue'),
--          upper(lpad(trim(to_char(p1,'xxxxxxxxxxxxxxxx')),16,'0')),
          p1,
          p3,
          p.owner||'.'||p.object_name||'.'||p.procedure_name,
          o.owner||'.'||o.object_name||'.'||o.subobject_name,
          blocking_session_status||' i#'||blocking_inst_id,
          sql_ID
--          ,sql_plan_line_ID
--          ,sql_plan_operation||' '||sql_plan_options
          ,trim(replace(replace(replace(dbms_lob.substr(sql_text,100),chr(10)),chr(13)),chr(9)))
 having count(distinct sample_id) > nvl('&2', 0)
 order by LEVEL, count(1) desc
/
set feedback on echo off VERIFY ON