--#-----------------------------------------------------------------------------------
--# File Name    : redo_switches_info.sql
--#
--# Description  : Shows info about redo switches, archive logs size for last 7 days.
--#
--# Call Syntax  : @redo_switches_info
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;
set verify off;

Prompt
Prompt Note: information for last 7 days.
Prompt

Prompt ##
Prompt ## Redo records per DAY:
Prompt ##

select *
from (select to_char(first_time,'YYYY-MM-DD') DAY
             ,count(1) REDO_COUNT#
             ,min(recid) SEQ_MIN#
             ,max(recid) SEQ_MAX#
             ,(max(next_change#) - min(first_change#) - 1) REDO_REC_COUNT
      from   v$log_history
      group  by to_char(first_time,'YYYY-MM-DD')
      order  by 1 desc)
where rownum <= 7;

Prompt ##
Prompt ## Redo swicthes per HOUR:
Prompt ##

select *
from 
     (select to_char(first_time,'YYYY-MM-DD') DAY
             ,to_char(sum(decode(to_char(first_time,'HH24'),'00',1,0)),'999') "00"
             ,to_char(sum(decode(to_char(first_time,'HH24'),'01',1,0)),'999') "01"
             ,to_char(sum(decode(to_char(first_time,'HH24'),'02',1,0)),'999') "02"
             ,to_char(sum(decode(to_char(first_time,'HH24'),'03',1,0)),'999') "03"
             ,to_char(sum(decode(to_char(first_time,'HH24'),'04',1,0)),'999') "04"
             ,to_char(sum(decode(to_char(first_time,'HH24'),'05',1,0)),'999') "05"
             ,to_char(sum(decode(to_char(first_time,'HH24'),'06',1,0)),'999') "06"
             ,to_char(sum(decode(to_char(first_time,'HH24'),'07',1,0)),'999') "07"
             ,to_char(sum(decode(to_char(first_time,'HH24'),'08',1,0)),'999') "08"
             ,to_char(sum(decode(to_char(first_time,'HH24'),'09',1,0)),'999') "09"
             ,to_char(sum(decode(to_char(first_time,'HH24'),'10',1,0)),'999') "10"
             ,to_char(sum(decode(to_char(first_time,'HH24'),'11',1,0)),'999') "11"
             ,to_char(sum(decode(to_char(first_time,'HH24'),'12',1,0)),'999') "12"
             ,to_char(sum(decode(to_char(first_time,'HH24'),'13',1,0)),'999') "13"
             ,to_char(sum(decode(to_char(first_time,'HH24'),'14',1,0)),'999') "14"
             ,to_char(sum(decode(to_char(first_time,'HH24'),'15',1,0)),'999') "15"
             ,to_char(sum(decode(to_char(first_time,'HH24'),'16',1,0)),'999') "16"
             ,to_char(sum(decode(to_char(first_time,'HH24'),'17',1,0)),'999') "17"
             ,to_char(sum(decode(to_char(first_time,'HH24'),'18',1,0)),'999') "18"
             ,to_char(sum(decode(to_char(first_time,'HH24'),'19',1,0)),'999') "19"
             ,to_char(sum(decode(to_char(first_time,'HH24'),'20',1,0)),'999') "20"
             ,to_char(sum(decode(to_char(first_time,'HH24'),'21',1,0)),'999') "21"
             ,to_char(sum(decode(to_char(first_time,'HH24'),'22',1,0)),'999') "22"
             ,to_char(sum(decode(to_char(first_time,'HH24'),'23',1,0)),'999') "23"
      from   v$log_history
      group  by to_char(first_time,'YYYY-MM-DD')
      order  by day desc)
where rownum <= 7;

Prompt ##
Prompt ## Archive logs size per DAY:
Prompt ##

select *
from (select to_char(completion_time,'YYYY-MM-DD') DAY
             ,thread# 
             ,round(sum(blocks*block_size)/1024/1024) SIZE_MB
             ,count(*) ARCH_COUNT
      from   v$archived_log 
      group  by to_char(completion_time,'YYYY-MM-DD'), thread#
      order  by 1 desc)
where rownum <= 7;
