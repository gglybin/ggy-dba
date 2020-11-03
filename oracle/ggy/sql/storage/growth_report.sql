--#-----------------------------------------------------------------------------------
--# File Name    : growth_report.sql
--#
--# Description  : Short report about database growth trend.
--#
--# Call Syntax  : @growth_report
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;

Prompt
Prompt ##
Prompt ## General:
Prompt ##

col "Database Size"    for a15
col "Used Space"       for a15
col "Used in %"        for 99,999,999
col "Free in %"        for 99,999,999
col "Database Name"    for a15
col "Free Space"       for a15
col "Growth DAY"       for a15
col "Growth WEEK"      for a15
col "Growth DAY in %"  for 99,999,999
col "Growth WEEK in %" for 99,999,999
col "Create Time"      for a20

select
      (select min(creation_time) from v$datafile) "Create Time"
      ,(select name from v$database) "Database Name"
      ,round((sum(used.bytes) / 1024 / 1024 ),2) || ' MB' "Database Size"
      ,round((sum(used.bytes) / 1024 / 1024 ) - round(free.p / 1024 / 1024 ),2) || ' MB' "Used Space"
      ,round(((sum(used.bytes) / 1024 / 1024 ) - (free.p / 1024 / 1024 )) / round(sum(used.bytes) / 1024 / 1024 ,2)*100,2) "Used in %"
      ,round((free.p / 1024 / 1024 ),2) || ' MB' "Free Space"
      ,round(((sum(used.bytes) / 1024 / 1024 ) - ((sum(used.bytes) / 1024 / 1024 ) - round(free.P / 1024 / 1024 )))/round(sum(used.bytes) / 1024 / 1024,2 )*100,2) "Free in %"
      ,round(((sum(used.bytes) / 1024 / 1024 ) - (free.p / 1024 / 1024 ))/(select sysdate-min(creation_time) from v$datafile),2) || ' MB' "Growth DAY"
      ,round(((sum(used.bytes) / 1024 / 1024 ) - (free.p / 1024 / 1024 ))/(select sysdate-min(creation_time) from v$datafile)/round((sum(used.bytes) / 1024 / 1024 ),2)*100,3) "Growth DAY in %"
      ,round(((sum(used.bytes) / 1024 / 1024 ) - (free.p / 1024 / 1024 ))/(select sysdate-min(creation_time) from v$datafile)*7,2) || ' MB' "Growth WEEK"
      ,round((((sum(used.bytes) / 1024 / 1024 ) - (free.p / 1024 / 1024 ))/(select sysdate-min(creation_time) from v$datafile)/round((sum(used.bytes) / 1024 / 1024 ),2)*100)*7,3) "Growth WEEK in %"
from  (
       select bytes from v$datafile
       union all
       select bytes from v$tempfile
       union all
       select bytes from v$log
      ) used,
      (
       select sum(bytes) as p from dba_free_space
      ) free
group by free.p;

Prompt ##
Prompt ## Growth by Mounth
Prompt ##

col "Database" for a20
col "Month"    for a20
col "Growth in GB" for 99,999,999
select  
      (select name from v$database) as "Database"
      ,to_char(creation_time, 'RRRR-MM') "Month"
      ,sum(bytes/1024/1024/1024) "Growth in GB"
from  v$datafile
group by to_char(creation_time, 'RRRR-MM')
order by 2 desc;
