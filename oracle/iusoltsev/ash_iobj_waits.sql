--
-- ASH I/O waits
-- Usage: SQL> @ash_iobj_waits [waits|reqs|blocks] [10]         "where sample_time > sysdate - 1/24"
--                            ^sort order         ^top N rows  ^ash filter
-- by Igor Usoltsev
--

set echo off feedback off heading on timi off pages 1000 lines 500 VERIFY OFF

col SQL_PROCESS for a13
col "event(waits:requests:blocks)" for a300
col "waits%"  for a7
col "reqs%"   for a7
col "blocks%" for a7
col inst_id for 9999 hea #i
col PROGRAMS for a60 HEADING 'PROGRAMS BY TYPES                                           '
col t0 for 999
col OBJECT_NAME for a65

with ash as (select * from gv$active_session_history &3
            )
select /*+ rule*/ * from (
    select 
inst_id,
           object_name,
           tablespace_name,
           SUM(WAIT_COUNT),
           to_char(RATIO_TO_REPORT(SUM(WAIT_COUNT)) OVER() * 100, '990.99') AS "waits%",
           SUM(REQUESTS),
           to_char(RATIO_TO_REPORT(SUM(REQUESTS)) OVER()   * 100, '990.99') AS "reqs%",
           SUM(BLOCKS),
           to_char(RATIO_TO_REPORT(SUM(BLOCKS)) OVER()     * 100, '990.99') AS "blocks%",
           decode(nvl(upper('&&1'), 'BLOCKS')
                                  , 'WAITS' , rtrim(xmlagg(xmlelement(s, '(' || WAIT_COUNT||':'|| REQUESTS ||':'|| BLOCKS, '); ').extract('//text()') order by WAIT_COUNT desc), '; ')
                                  , 'REQS'  , rtrim(xmlagg(xmlelement(s, '(' || WAIT_COUNT||':'|| REQUESTS ||':'|| BLOCKS, '); ').extract('//text()') order by REQUESTS desc), '; ')
                                  , 'BLOCKS', rtrim(xmlagg(xmlelement(s, '(' || WAIT_COUNT||':'|| REQUESTS ||':'|| BLOCKS, '); ').extract('//text()') order by BLOCKS desc), '; ')
                                            , rtrim(xmlagg(xmlelement(s, '(' || WAIT_COUNT||':'|| REQUESTS ||':'|| BLOCKS, '); ').extract('//text()') order by BLOCKS desc), '; '))
            as "event(waits:requests:blocks)"
      from (select 
inst_id,
                   object_name,
                   tablespace_name,
                   sum(WAIT_COUNT)                     as WAIT_COUNT,
                   sum(WAIT_COUNT * REQS_PER_WAIT)     as REQUESTS,
                   sum(WAIT_COUNT * BLOCKS_PER_WAIT) as BLOCKS
              from (select count(*) as WAIT_COUNT,
                           o.object_type||' '||o.owner||'.'||o.object_name||'.'||o.subobject_name as object_name,
                           NVL(f.tablespace_name, l.tablespace_name) as tablespace_name,
                           case when p2text = 'blocks' then p2
                                when p3text in ('blocks','block cnt') then p3
                                when p1text = 'requests' then p1  
                                else 1
                           end                                                                                            as BLOCKS_PER_WAIT,
                           case when p3text='requests' then p3 when p1text='requests' then p1 else 1 end                  as REQS_PER_WAIT
,inst_id
                      from ash --Gv$active_session_history--
                      left join dba_objects o     on current_obj# = object_id
                      left join dba_data_files f  on current_file# = file_id
                      left join dba_lobs l        on l.owner = o.owner and l.segment_name = o.object_name
                     where 
                        wait_class in ('User I/O','System I/O') and
                        session_state = 'WAITING'
			and current_obj# > 0
                     group by o.object_type||' '||o.owner||'.'||o.object_name||'.'||o.subobject_name,
                              NVL(f.tablespace_name, l.tablespace_name),
                              case when p2text = 'blocks' then p2
                                   when p3text in ('blocks','block cnt') then p3
                                   when p1text = 'requests' then p1  
                                   else 1
                              end,
                              case when p3text='requests' then p3 when p1text='requests' then p1 else 1 end
,inst_id
			      )
             group by 
inst_id,
                      object_name,
                      tablespace_name)
     group by 
inst_id,
              object_name,
              tablespace_name
     order by 1, decode(nvl(upper('&&1'),'BLOCKS'), 'WAITS', SUM(WAIT_COUNT), 'REQS', SUM(REQUESTS), 'BLOCKS', SUM(BLOCKS), SUM(BLOCKS)) desc
) where rownum <= nvl('&2', 10)
/
set feedback on echo off VERIFY ON
