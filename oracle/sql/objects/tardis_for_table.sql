--#-----------------------------------------------------------------------------------
--# File Name    : tardis_for_table.sql
--#
--# Description  : Script will query given table as of time provided (usually before unexpected removal).
--#
--# Call Syntax  : SQL> @tardis_for_table (timestamp) (table-owner) (table-name) (column-list) (filter)
--#
--#                SQL> @tardis_for_table "03-28-2019 23:55" HR EMPDATA "ID, NAME" "NAME='John'"
--#
--# References   : https://blogs.oracle.com/sql/how-to-recover-data-without-a-backup
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;
set verify off;

Prompt
Prompt ##
Prompt ## Table "&&2"."&&3" data as of "&&1"
Prompt ##

select &&4
from   "&&2"."&&3" as of timestamp to_date('&&1', 'mm.dd.yyyy hh24:mi')
where  &&5;

/***

--
-- Limitations of Flashback Query
--

   -- Oracle only ensures you can query as far back as the value of your “undo_retention” parameter.
   -- Oracle is unable to query across many forms of DDL. So if you change a table's structure there's a good chance Flashback Query will fail.
   -- ORA-01466: unable to read data - table definition has changed -- when run DDL against a table.
   -- Truncate is DDL in Oracle. So if you’ve used this method to wipe a table, there’s no way back!

--
-- How to Restore a Whole Table
--

SQL> alter table <table> enable row movement;
SQL> flashback table <table> to timestamp <when it was good>;

--
-- How to Recover a Few Rows
--

   -- Timestamp

SQL> select * from <table> as of timestamp systimestamp - interval '1' hour;

   -- SCN

SQL> select * from <table> as of scn 1234567;

--
-- Salvaging the Deleted Rows
--

   -- Option 1: If you know which rows were removed.

SQL> insert into table
       select * from <table> as of timestamp sysdate – interval '1' hour
       where <conditions to find the rows>;

   -- Option 2: If you’re not sure which rows are gone, you can find the deleted ones using minus.

SQL> insert into <table>
       select * from <table> as of timestamp sysdate – interval '1' hour
       minus
       select * from <table>;

       NOTE: this will include all rows deleted in the past hour. If there are genuine deletions, you’ll need to remove them again.

--
-- Recover Overwritten Values
--

   -- What if the rows weren’t deleted, just updated? And you need to restore the original values, but don’t know what they are?

SQL> update <table> cur
     set (col1, col2, col3) = (
       select col1, col2, col3 from <table>
         as of timestamp systimestamp – interval '1' hour old
       where cur.primary_key = old.primary_key
     )
     where <rows to update>;

--
-- How to Restore Dropped Tables
--

SQL> flashback table <table> to before drop;

   -- View the contents of the recyclebin

   SQL> select * from recyclebin;

   -- Tables in the recyclebin still consume space. If you’re sure you want to permanently drop a table, use the purge option:

   SQL> drop table <table> purge;

   -- And the table is gone for good. Or you if you want a safety net, drop it normally. Then remove it from the recyclebin with:

   SQL> purge table <table>;

   -- If you want to recover all the space the recyclebin is using, clear it out with:

   SQL> purge recyclebin;

   NOTE: the recyclebin only applies when you use drop table. If you take other actions that remove tables, e.g. drop user or drop tablespace, they are gone for good.

***/
