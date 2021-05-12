--#-----------------------------------------------------------------------------------
--# File Name    : check_db_links.sql
--#
--# Description  : Checks if database links are really working.
--#
--# Call Syntax  : @check_db_links
--#
--# References   : https://dba-notes.org/archives/1112/#more-1112
--#-----------------------------------------------------------------------------------

set lines 400 pages 1000;

set serveroutput on;

set feedback off;

declare
  l_result varchar2(1000);
  l_status number default null;
  l_cursor integer;
  l_user_id number;
begin
  execute immediate ('alter session set global_names=false');
  dbms_output.put_line(chr(1));
  dbms_output.put_line('------------------------------------------------------');
  dbms_output.put_line('Checking if PRIVATE database links are really working:');
  dbms_output.put_line('------------------------------------------------------');
  dbms_output.put_line(chr(1));
  for c1 in
  (select u.user_id
          ,d.owner
          ,d.db_link
   from   dba_db_links d
          ,dba_users u
   where  d.owner = u.username
   order  by d.owner
  )
  loop
    begin
      l_cursor:=sys.dbms_sys_sql.open_cursor();
      sys.dbms_sys_sql.parse_as_user(l_cursor,'select * FROM global_name@' || c1.db_link, dbms_sql.native, c1.user_id);
      sys.dbms_sys_sql.define_column(l_cursor, 1, l_result, 1000);
      l_status := sys.dbms_sys_sql.execute(l_cursor);
      if ( dbms_sys_sql.fetch_rows(l_cursor) > 0 ) then
        dbms_sys_sql.column_value(l_cursor, 1, l_result);
      end if;
      dbms_output.put_line('Owner          => '|| c1.owner);
      dbms_output.put_line('Database Link  => '|| c1.db_link);
      dbms_output.put_line('Status         => SUCCESS');
      dbms_output.put_line(chr(2));
      sys.dbms_sys_sql.close_cursor(l_cursor);
    exception
    when others then
      dbms_output.put_line('Owner          => '|| c1.owner);
      dbms_output.put_line('Database Link  => '|| c1.db_link);
      dbms_output.put_line('Status         => FAIL');
      dbms_output.put_line(chr(2));
    end;
  end loop;
  dbms_output.put_line(chr(1));
  dbms_output.put_line('------------------------------------------------------');
  dbms_output.put_line('Checking if PUBLIC database links are really working:');
  dbms_output.put_line('------------------------------------------------------');
  dbms_output.put_line(chr(1));
  select user_id into l_user_id from dba_users where username=USER;
  for c1 in
  (select owner
          ,db_link
   from   dba_db_links
   where  owner='PUBLIC'
   order  by db_link
  )
  loop
    begin
      l_cursor:=sys.dbms_sys_sql.open_cursor();
      sys.dbms_sys_sql.parse_as_user(l_cursor,'select * FROM global_name@' || c1.db_link, dbms_sql.native, l_user_id);
      sys.dbms_sys_sql.define_column(l_cursor, 1, l_result, 1000);
      l_status := sys.dbms_sys_sql.execute(l_cursor);
      if ( dbms_sys_sql.fetch_rows(l_cursor) > 0 ) then
        dbms_sys_sql.column_value(l_cursor, 1, l_result);
      END IF;
      dbms_output.put_line('Owner          => '|| c1.owner);
      dbms_output.put_line('Database Link  => '|| c1.db_link);
      dbms_output.put_line('Status         => SUCCESS');
      dbms_output.put_line(chr(2));
      sys.dbms_sys_sql.close_cursor(l_cursor);
    exception
    when others then
      dbms_output.put_line('Owner          => '|| c1.owner);
      dbms_output.put_line('Database Link  => '|| c1.db_link);
      dbms_output.put_line('Status         => FAIL');
      dbms_output.put_line(chr(2));
    end;
  end loop;
end;
/

set feedback on;
set serveroutput off;

/***

--
-- Same as above, but it will save output into table
--

CREATE TABLE check_links
  (
    owner  VARCHAR(255),
    dblink VARCHAR(255),
    status VARCHAR(3)
  );

DECLARE
  l_result VARCHAR2(1000);
  l_status NUMBER DEFAULT NULL;
  l_cursor INTEGER;
BEGIN
  EXECUTE IMMEDIATE ('ALTER SESSION SET GLOBAL_NAMES=FALSE');
  FOR c1 IN
  (SELECT u.user_id ,
              d.owner ,
          d.db_link
    FROM dba_db_links d, dba_users u
    WHERE d.owner = u.username
    ORDER BY d.owner
  )
  LOOP
    BEGIN
      l_cursor:=sys.dbms_sys_sql.open_cursor();
      sys.dbms_sys_sql.parse_as_user(l_cursor,'SELECT * FROM global_name@' || c1.db_link, dbms_sql.native, c1.user_id);
      sys.dbms_sys_sql.define_column(l_cursor, 1, l_result, 1000);
      l_status := sys.dbms_sys_sql.EXECUTE(l_cursor);
      IF ( dbms_sys_sql.fetch_rows(l_cursor) > 0 ) THEN
        dbms_sys_sql.column_value(l_cursor, 1, l_result );
      END IF;
      INSERT INTO sys.check_links VALUES
        (c1.owner, c1.db_link, 'OK');
      COMMIT;
      sys.dbms_sys_sql.close_cursor(l_cursor);
      COMMIT;
    EXCEPTION
    WHEN OTHERS THEN
      INSERT INTO sys.check_links VALUES
        (c1.owner, c1.db_link, 'ERR');
      COMMIT;
    END;
  END LOOP;
END ;
/

***/

Prompt
Prompt Note: use "db_links_info.sql" script to get list of all database links.
Prompt
