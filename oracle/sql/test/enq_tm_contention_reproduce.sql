--#-----------------------------------------------------------------------------------
--# File Name    : enq_tm_contention_reproduce.sql
--#
--# Description  : This script will create some tables to reproduce "enq - TM contention" locks.
--#
--# Call Syntax  : @enq_tm_contention_reproduce
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;

Prompt
Prompt ##
Prompt ## ATTENTION: Going to create test tables for this experiment.
Prompt ##
Prompt
Prompt Press Enter to proceed ...
Prompt
pause

Prompt
Prompt ##
Prompt ## Creating TEST_SUPPLIER table:
Prompt ##

CREATE TABLE TEST_SUPPLIER 
( 
  supplier_id number(10) not null, 
  supplier_name varchar2(50) not null, 
  contact_name varchar2(50), 
  CONSTRAINT supplier_pk PRIMARY KEY (supplier_id) 
); 

INSERT INTO TEST_SUPPLIER VALUES (1, 'Supplier 1', 'Contact 1'); 
INSERT INTO TEST_SUPPLIER VALUES (2, 'Supplier 2', 'Contact 2'); 
INSERT INTO TEST_SUPPLIER VALUES (3, 'Supplier 3', 'Contact 3');

COMMIT; 

Prompt ##
Prompt ## Creating TEST_PRODUCT table:
Prompt ##

CREATE TABLE TEST_PRODUCT
( 
  product_id number(10) not null, 
  product_name varchar2(50) not null, 
  supplier_id number(10) not null, 
  CONSTRAINT fk_supplier FOREIGN KEY (supplier_id) REFERENCES test_supplier(supplier_id) ON DELETE CASCADE 
); 

INSERT INTO TEST_PRODUCT VALUES (1, 'Product 1', 1); 
INSERT INTO TEST_PRODUCT VALUES (2, 'Product 2', 1); 
INSERT INTO TEST_PRODUCT VALUES (3, 'Product 3', 2); 

COMMIT;

Prompt
Prompt ##
Prompt ## Try to run DML's below from different session to reproduce "enq - TM contention":
Prompt ##
Prompt

set serveroutput on;
set feedback off;

exec dbms_output.put_line('Session-1 ===> SQL> DELETE TEST_SUPPLIER WHERE SUPPLIER_ID = 1;          -- with NO commit');
exec dbms_output.put_line('Session-2 ===> SQL> DELETE TEST_SUPPLIER WHERE SUPPLIER_ID = 2;          -- it will hang');
exec dbms_output.put_line('Session-3 ===> SQL> INSERT INTO TEST_PRODUCT VALUES (4,''Product 4'',3); -- it will hang');

set serveroutput off;
set feedback on;

Prompt
Prompt Press Enter once done ...
pause

Prompt ##
Prompt ## Locks info:
Prompt ##

col SID_SERIAL   for a15
col BLOCKER_SID  for a10
col USERNAME     for a20
col OWNER_OBJECT for a30
col LOCK_TYPE    for a5
col LOCKED_MODE  for a30
col WAIT_EVENT   for a30
col SESS_STATUS  for a15

select substr(to_char(l.session_id)||','||to_char(s.serial#),1,15) SID_SERIAL
       ,nvl(to_char(s.final_blocking_session),'-') BLOCKER_SID
       ,substr(l.os_user_name||'/'||l.oracle_username,1,20) USERNAME
       ,substr(o.owner||'.'||o.object_name,1,35) OWNER_OBJECT
       ,ll.type LOCK_TYPE
       ,decode(l.locked_mode, 1,'No Lock', 2,'Row Share', 3,'Row Exclusive', 4,'Share', 5,'Share Row Excl', 6,'Exclusive',null) LOCKED_MODE
       ,s.event WAIT_EVENT
       ,substr(s.status,1,10) SESS_STATUS
from   v$lock ll
       ,v$locked_object l
       ,dba_objects o
       ,v$session s
       ,v$process p
where  l.object_id=ll.id1 and l.session_id=ll.sid
and    l.object_id = o.object_id
and    l.session_id = s.sid
and    s.paddr = p.addr
and    s.status != 'KILLED'
order  by o.owner, o.object_name;

Prompt Note: use "lock_info.sql" script to get info about the locks in database.
Prompt
Prompt ##
Prompt ## Going to create Foreing Key Index to resolve issue:
Prompt ##
Prompt
Prompt Press Enter to proceed with index creation ..
pause

CREATE INDEX TEST_FK_SUPPLIER ON TEST_PRODUCT (SUPPLIER_ID);

col index_name      for a30
col column_name     for a30
col index_type      for a20
col uniqueness      for a15
col status          for a10
col tablespace_name for a30
col "CREATED"       for a20
col "STATS_DATE"    for a20
col index_owner     for a20
col index_name      for a30

select  i.owner index_owner
       ,i.index_name
       ,c.column_name
       ,i.index_type
       ,i.uniqueness
       ,i.status
       ,i.tablespace_name
       ,to_char(o.created, 'HH24:MI DD-MON-YY') as "CREATED"
       --,to_char(i.last_analyzed, 'HH24:MI DD-MON-YY') as "STATS_DATE"
from   dba_ind_columns c
 inner join dba_indexes i on c.index_owner=i.owner and c.index_name=i.index_name
 inner join dba_objects o on i.owner=o.owner and i.index_name=o.object_name
where  i.index_name='TEST_FK_SUPPLIER'
and    c.table_name='TEST_PRODUCT'
order  by o.created desc, i.owner, i.uniqueness desc, c.index_name;

Prompt ##
Prompt ## Re-run DML's below:
Prompt ##
Prompt

set serveroutput on;
set feedback off;

exec dbms_output.put_line('Session-1 ===> SQL> DELETE TEST_SUPPLIER WHERE SUPPLIER_ID = 1;           -- should be okay');
exec dbms_output.put_line('Session-2 ===> SQL> DELETE TEST_SUPPLIER WHERE SUPPLIER_ID = 2;           -- should be okay');
exec dbms_output.put_line('Session-3 ===> SQL> INSERT INTO TEST_PRODUCT VALUES (4,''Product 4'',3);  -- should be okay');

set serveroutput off;
set feedback on;

Prompt
Prompt Press Enter once done ...
pause

Prompt ##
Prompt ## Locks info:
Prompt ##

col SID_SERIAL   for a15
col BLOCKER_SID  for a10
col USERNAME     for a20
col OWNER_OBJECT for a30
col LOCK_TYPE    for a5
col LOCKED_MODE  for a30
col WAIT_EVENT   for a30
col SESS_STATUS  for a15

select substr(to_char(l.session_id)||','||to_char(s.serial#),1,15) SID_SERIAL
       ,nvl(to_char(s.final_blocking_session),'-') BLOCKER_SID
       ,substr(l.os_user_name||'/'||l.oracle_username,1,20) USERNAME
       ,substr(o.owner||'.'||o.object_name,1,35) OWNER_OBJECT
       ,ll.type LOCK_TYPE
       ,decode(l.locked_mode, 1,'No Lock', 2,'Row Share', 3,'Row Exclusive', 4,'Share', 5,'Share Row Excl', 6,'Exclusive',null) LOCKED_MODE
       ,s.event WAIT_EVENT
       ,substr(s.status,1,10) SESS_STATUS
from   v$lock ll
       ,v$locked_object l
       ,dba_objects o
       ,v$session s
       ,v$process p
where  l.object_id=ll.id1 and l.session_id=ll.sid
and    l.object_id = o.object_id
and    l.session_id = s.sid
and    s.paddr = p.addr
and    s.status != 'KILLED'
order  by o.owner, o.object_name;

Prompt Note: use "get_unindexed_fk_list.sql" to get info about all unindexed foreing keys in specific schema or database.
Prompt

Prompt !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
Prompt !!! Press Enter to drop all test objects created above: !!!
Prompt !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

col owner         for a20
col object_name   for a70
col object_type   for a30
col status        for a10
col created       for a20
col last_ddl_time for a20

select owner
       ,object_name
       ,object_type
       ,status
       ,to_char(created, 'DD-MON-YY HH24:MI') "CREATED"
       ,to_char(last_ddl_time, 'DD-MON-YY HH24:MI') "LAST_DDL_TIME"
from   dba_objects
where  object_name in ('TEST_SUPPLIER','TEST_PRODUCT','TEST_FK_SUPPLIER')
order  by owner, created desc, last_ddl_time desc, object_type;

pause

DROP TABLE TEST_PRODUCT;
DROP TABLE TEST_SUPPLIER;
