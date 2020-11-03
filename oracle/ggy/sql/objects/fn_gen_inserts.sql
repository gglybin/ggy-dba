--#-----------------------------------------------------------------------------------
--# File Name    : fn_gen_inserts.sql
--#
--# Description  : Script to compile function which will generate insert statements for each table row.
--#
--# Call Syntax  : SQL> @fn_gen_inserts
--#
--# References   : Tomasz Lesinski
--#
--#                https://dbaora.com/oracle-generate-rows-as-insert-statements-from-table-view-using-plsql/
--#
--# Usage        : SQL>  set pagesize 0 long 1000000;
--#                SQL>  set heading off;
--#                SQL>  set serveroutput on;
--#                SQL>  spool inserts.sql
--#                SQL>  select fn_gen_inserts('select * from TEST1.TEST_TABLE','TEST2','TEST_TABLE') from dual;
--#                SQL>  spool off;
--#                bash$ ... correct inserts.sql file.
--#                SQL>  conn TEST2
--#                SQL>  @inserts
--#                SQL>  COMMIT;
--#
--#-----------------------------------------------------------------------------------

create or replace FUNCTION fn_gen_inserts
(
  p_sql                        CLOB, 
  p_new_owner_name             VARCHAR2,
  p_new_table_name             VARCHAR2
)
RETURN CLOB
IS
  l_cur                        NUMBER;
  l_sql                        CLOB := p_sql;
  l_ret                        NUMBER;
  l_col_cnt                    NUMBER;
  l_rec_tab                    dbms_sql.desc_tab;

  l_separator                  CHAR(1) := '!';
  l_clob                       CLOB;
  l_clob_line                  CLOB;
  l_clob_ins                   CLOB;
  l_clob_all                   CLOB;
  l_line                       CLOB := '-----------------------------------';

  cons_date_frm                VARCHAR2(32) := 'DD.MM.YYYY HH24:MI:SS';
  cons_timestamp_frm           VARCHAR2(32) := 'DD.MM.YYYY HH24:MI:SSXFF';
  cons_timestamp_wtz_frm       VARCHAR2(32) := 'DD.MM.YYYY HH24:MI:SSXFF TZR';

  cons_varchar2_code           NUMBER := 1;
  cons_nvarchar2_code          NUMBER := 1;
  cons_number_code             NUMBER := 2;
  cons_float_code              NUMBER := 2;
  cons_long_code               NUMBER := 8;
  cons_date_code               NUMBER := 12;
  cons_binary_float_code       NUMBER := 100;
  cons_binary_double_code      NUMBER := 101;
  cons_timestamp_code          NUMBER := 180;
  cons_timestamp_wtz_code      NUMBER := 181;
  cons_timestamp_lwtz_code     NUMBER := 231;
  cons_interval_ytm_code       NUMBER := 182;
  cons_interval_dts_code       NUMBER := 183;
  cons_raw_code                NUMBER := 23;
  cons_long_raw_code           NUMBER := 24;
  cons_rowid_code              NUMBER := 11;
  cons_urowid_code             NUMBER := 208;
  cons_char_code               NUMBER := 96;
  cons_nchar_code              NUMBER := 96;
  cons_clob_code               NUMBER := 112;
  cons_nclob_code              NUMBER := 112;
  cons_blob_code               NUMBER := 113;
  cons_bfile_code              NUMBER := 114;
  cons_xmltype_code            NUMBER := 109;

  -------------------------------------
  -- Supported types
  -------------------------------------
  l_varchar2_col                VARCHAR2(32767); --1
  l_number_col                  NUMBER;          --2
  --l_long_col                    long;          --8 - not supported
  l_date_col                    DATE;            --12
  --l_raw_col                     raw(2000);     --23 - not supported
  l_rowid_col                   ROWID;           --69
  l_char_col                    CHAR(2000);      --96
  l_binary_float_col            BINARY_FLOAT;    --100
  l_binary_double_col           BINARY_DOUBLE;   --101
  l_clob_col                    CLOB;            --112
  l_timestamp_col               TIMESTAMP(9);    --180
  l_timestamp_wtz_col           TIMESTAMP(9) WITH TIME ZONE;    --181
  l_interval_ytm_col            INTERVAL YEAR(9) TO MONTH;      --182
  l_interval_dts_col            INTERVAL DAY(9) TO SECOND(2);   --183
  l_urowid_col                  UROWID;                         --208
  l_timestamp_wltz_col          TIMESTAMP WITH LOCAL TIME ZONE; --231
  l_xmltype_col                 XMLTYPE; --109
  --l_nchar_col                   nchar(2000); --96 the same as char
  --l_nclob_col                   nclob; --112 the same as clob
  --l_blob_col - not supported
  --l_bfile_col - not supported
  --l_long_raw_col - not supported

  PROCEDURE print_rec(rec IN dbms_sql.desc_rec) IS
  BEGIN
    l_clob_all := l_clob_all||chr(10)||
      'col_type            =    ' || rec.col_type||chr(10)||
      'col_maxlen          =    ' || rec.col_max_len||chr(10)||
      'col_name            =    ' || rec.col_name||chr(10)||
      'col_name_len        =    ' || rec.col_name_len||chr(10)||
      'col_schema_name     =    ' || rec.col_schema_name||chr(10)||
      'col_schema_name_len =    ' || rec.col_schema_name_len||chr(10)||
      'col_precision       =    ' || rec.col_precision||chr(10)||
      'col_scale           =    ' || rec.col_scale||chr(10)||
      'col_null_ok         =    ';

    IF (rec.col_null_ok) THEN
      l_clob_all := l_clob_all||'true'||chr(10);
    ELSE
      l_clob_all := l_clob_all||'false'||chr(10);
    END IF;
  END;  
BEGIN
  ---------------------------------------
  -- INSERT - header generation
  ---------------------------------------
  l_clob_all := 
  'declare'||chr(10)||
  '  type   t_clob is table of clob index by binary_integer;'||chr(10)||
  '  l_clob t_clob;'||chr(10)||
  '  type   t_varchar2 is table of varchar2(64) index by binary_integer;'||chr(10)||
  '  l_varchar2 t_varchar2;'||chr(10)||
  'begin'||chr(10)||
  '/*'||chr(10);

  ---------------------------------------
  -- Introduction
  ---------------------------------------
  l_clob_all := l_clob_all||l_line||chr(10)||'Parsing query:'||chr(10)||l_sql||chr(10);

  ---------------------------------------
  -- Open parse cursor
  ---------------------------------------
  l_cur := dbms_sql.open_cursor;
  dbms_sql.parse(l_cur, l_sql, dbms_sql.NATIVE);

  ---------------------------------------
  -- Describe columns
  ---------------------------------------
  l_clob_all := l_clob_all||l_line||chr(10)||'Describe columns:'||chr(10);

  dbms_sql.describe_columns(l_cur, l_col_cnt, l_rec_tab);

  FOR i IN 1..l_rec_tab.count
  loop
    print_rec(l_rec_tab(i));
  END loop;

  l_clob_all := l_clob_all||chr(10)||
            '*/'||chr(10)||
            '  '||chr(10)||l_line||chr(10)||
            '  -- start generation of records'||chr(10)||
            '  '||l_line||chr(10);

  ---------------------------------------
  -- Define columns
  ---------------------------------------
  FOR i IN 1..l_rec_tab.count
  loop
    IF    l_rec_tab(i).col_type = cons_varchar2_code THEN --varchar2
      dbms_sql.define_column(l_cur, i, l_varchar2_col, l_rec_tab(i).col_max_len); 
    elsif l_rec_tab(i).col_type = cons_number_code THEN --number
      dbms_sql.define_column(l_cur, i, l_number_col); 
    --elsif l_rec_tab(i).col_type = cons_long_code then --long
    --  dbms_sql.define_column_long(l_cur, i); 
    elsif l_rec_tab(i).col_type = cons_date_code THEN --date
      dbms_sql.define_column(l_cur, i, l_date_col); 
    elsif l_rec_tab(i).col_type = cons_binary_float_code THEN --binary_float
      dbms_sql.define_column(l_cur, i, l_binary_float_col); 
    elsif l_rec_tab(i).col_type = cons_binary_double_code THEN --binary_double
      dbms_sql.define_column(l_cur, i, l_binary_double_col); 
--    elsif l_rec_tab(i).col_type = cons_raw_code then --raw
--      dbms_sql.define_column_raw(l_cur, i, l_raw_col, l_rec_tab(i).col_max_len); 
    elsif l_rec_tab(i).col_type = cons_rowid_code THEN  --rowid
      dbms_sql.define_column_rowid(l_cur, i, l_rowid_col); 
    elsif l_rec_tab(i).col_type = cons_char_code THEN  --char
      dbms_sql.define_column_char(l_cur, i, l_char_col, l_rec_tab(i).col_max_len); 
    elsif l_rec_tab(i).col_type = cons_clob_code THEN --clob
      dbms_sql.define_column(l_cur, i, l_clob_col); 
    elsif l_rec_tab(i).col_type = cons_timestamp_code THEN --timestamp
      dbms_sql.define_column(l_cur, i, l_timestamp_col); 
    elsif l_rec_tab(i).col_type = cons_timestamp_wtz_code THEN --timestamp with time zone
      dbms_sql.define_column(l_cur, i, l_timestamp_wtz_col); 
    elsif l_rec_tab(i).col_type = cons_rowid_code THEN --urowid
      dbms_sql.define_column(l_cur, i, l_urowid_col); 
    elsif l_rec_tab(i).col_type = cons_timestamp_lwtz_code THEN --timestamp with local time zone
      dbms_sql.define_column(l_cur, i, l_timestamp_wltz_col); 
    elsif l_rec_tab(i).col_type = cons_interval_ytm_code THEN --interval year to month
      dbms_sql.define_column(l_cur, i, l_interval_ytm_col); 
    elsif l_rec_tab(i).col_type = cons_interval_dts_code THEN --interval day to second
      dbms_sql.define_column(l_cur, i, l_interval_dts_col); 
    elsif l_rec_tab(i).col_type = cons_urowid_code THEN --urowid
      dbms_sql.define_column(l_cur, i, l_urowid_col); 
    elsif l_rec_tab(i).col_type = cons_xmltype_code THEN --xmltype
      dbms_sql.define_column(l_cur, i, l_xmltype_col); 
    ELSE
      raise_application_error(-20001, 'Column: '||l_rec_tab(i).col_name||chr(10)||
                                      'Type not supported: '||l_rec_tab(i).col_type);
      --not supported
    END IF;
  END loop;

  ---------------------------------------
  -- Execute cursor
  ---------------------------------------
  l_ret := dbms_sql.EXECUTE(l_cur);

  ---------------------------------------
  -- Fetch rows
  ---------------------------------------
  loop
    l_ret := dbms_sql.fetch_rows(l_cur);
    exit WHEN l_ret = 0;

    ---------------------------------------
    -- Building INSERT - build column declarations
    ---------------------------------------
    l_clob_line := '';

    FOR i IN 1..l_rec_tab.count
    loop
      IF    l_rec_tab(i).col_type = cons_varchar2_code THEN --varchar2
        dbms_sql.COLUMN_VALUE(l_cur, i, l_varchar2_col); 
        l_clob := l_varchar2_col;
      elsif l_rec_tab(i).col_type = cons_number_code THEN --number
        dbms_sql.COLUMN_VALUE(l_cur, i, l_number_col); 
        l_clob := to_char(l_number_col);
--      elsif l_rec_tab(i).col_type = cons_long_code then --long
--        dbms_sql.column_value(l_cur, i, l_long_col); 
--        l_clob := l_long_col;
      elsif l_rec_tab(i).col_type = cons_date_code THEN --date
        dbms_sql.COLUMN_VALUE(l_cur, i, l_date_col); 
        l_clob := to_char(l_date_col, cons_date_frm);
      elsif l_rec_tab(i).col_type = cons_binary_float_code THEN --binary_float
        dbms_sql.COLUMN_VALUE(l_cur, i, l_binary_float_col); 
        l_clob := to_char(l_binary_float_col);
      elsif l_rec_tab(i).col_type = cons_binary_double_code THEN --binary_double
        dbms_sql.COLUMN_VALUE(l_cur, i, l_binary_double_col); 
        l_clob := to_char(l_binary_double_col);
--      elsif l_rec_tab(i).col_type = cons_raw_code then --raw
--        dbms_sql.column_value(l_cur, i, l_raw_col); 
--        l_clob := to_char(l_raw_col);
      elsif l_rec_tab(i).col_type = cons_rowid_code THEN --rowid
        dbms_sql.COLUMN_VALUE(l_cur, i, l_rowid_col); 
        l_clob := to_char(l_rowid_col);
      elsif l_rec_tab(i).col_type = cons_char_code THEN --char
        dbms_sql.column_value_char(l_cur, i, l_char_col); 
        l_clob := substr(l_char_col, 1, l_rec_tab(i).col_max_len - 1);
      elsif l_rec_tab(i).col_type = cons_clob_code THEN --clob
        dbms_sql.COLUMN_VALUE(l_cur, i, l_clob_col); 
        l_clob := l_clob_col;
      elsif l_rec_tab(i).col_type = cons_timestamp_code THEN --timestamp
        dbms_sql.COLUMN_VALUE(l_cur, i, l_timestamp_col); 
        l_clob := to_char(l_timestamp_col, cons_timestamp_frm);
      elsif l_rec_tab(i).col_type = cons_timestamp_wtz_code THEN --timestamp with time zone
        dbms_sql.COLUMN_VALUE(l_cur, i, l_timestamp_wtz_col); 
        l_clob := to_char(l_timestamp_wtz_col, cons_timestamp_wtz_frm);
      elsif l_rec_tab(i).col_type = cons_interval_ytm_code THEN --interval year to month
        dbms_sql.COLUMN_VALUE(l_cur, i, l_interval_ytm_col); 
        l_clob := to_char(l_interval_ytm_col);
      elsif l_rec_tab(i).col_type = cons_interval_dts_code THEN --interval day to second
        dbms_sql.COLUMN_VALUE(l_cur, i, l_interval_dts_col); 
        l_clob := to_char(l_interval_dts_col);
      elsif l_rec_tab(i).col_type = cons_urowid_code THEN --urowid
        dbms_sql.COLUMN_VALUE(l_cur, i, l_urowid_col); 
        l_clob := to_char(l_urowid_col);
      elsif l_rec_tab(i).col_type = cons_timestamp_lwtz_code THEN --timestamp with local time zone
        dbms_sql.COLUMN_VALUE(l_cur, i, l_timestamp_wltz_col); 
        l_clob := to_char(l_timestamp_wltz_col, cons_timestamp_wtz_frm);
      elsif l_rec_tab(i).col_type = cons_xmltype_code THEN --xmltype
        dbms_sql.COLUMN_VALUE(l_cur, i, l_xmltype_col); 
        l_clob := l_xmltype_col.getclobval();
      END IF;

      IF l_rec_tab(i).col_type IN (cons_clob_code, cons_char_code, cons_varchar2_code) THEN
        l_clob_line := l_clob_line||'  l_clob('||to_char(i)||') :=q'''||l_separator||l_clob||l_separator||''';'||chr(10);
      ELSIF l_rec_tab(i).col_type IN (cons_xmltype_code) THEN
        l_clob_line := l_clob_line||'  l_clob('||to_char(i)||') :=q'''||l_separator||l_clob||l_separator||''';'||chr(10);
      ELSE
        l_clob_line := l_clob_line||'  l_varchar2('||to_char(i)||') :=q'''||l_separator||l_clob||l_separator||''';'||chr(10);
      END IF;
    END loop;

    l_clob_all := l_clob_all||chr(10)||l_clob_line;

    ---------------------------------------
    -- Building INSERT - build column list
    ---------------------------------------
    l_clob_all := l_clob_all||chr(10)||
              '  insert into '||p_new_owner_name||'.'||p_new_table_name||chr(10)||
              '  ('||chr(10);

    FOR i IN 1..l_rec_tab.count
    loop
      IF i = 1 THEN
        l_clob_all := l_clob_all||'     '||l_rec_tab(i).col_name||chr(10);
      ELSE  
        l_clob_all := l_clob_all||'    ,'||l_rec_tab(i).col_name||chr(10);
      END IF;  
    END loop;    

    l_clob_all := l_clob_all||
              '  )'||chr(10)||
              '  values'||chr(10)||
              '  ('||chr(10);

    ---------------------------------------
    -- Building INSERT - build values
    ---------------------------------------
    FOR i IN 1..l_rec_tab.count
    loop
      IF i!=1 THEN
        l_clob_all := l_clob_all||'    ,';
      ELSE  
        l_clob_all := l_clob_all||'     ';
      END IF;

      IF l_rec_tab(i).col_type = cons_number_code THEN --number
        l_clob_all := l_clob_all||'to_number(l_varchar2('||to_char(i)||'))'||chr(10);
--      elsif l_rec_tab(i).col_type = cons_long_code then --long
--        l_clob := l_long_col;
      elsif l_rec_tab(i).col_type = cons_clob_code THEN --clob, xmltype
        l_clob_all := l_clob_all||'l_clob('||to_char(i)||')'||chr(10);
      ELSIF L_REC_TAB(I).COL_TYPE = CONS_XMLTYPE_CODE then --clob, xmltype
        l_clob_all := l_clob_all||'xmltype(l_clob('||to_char(i)||'))'||chr(10);
      elsif l_rec_tab(i).col_type = cons_char_code THEN --timestamp with local time zone
        l_clob_all := l_clob_all||'to_char(l_clob('||to_char(i)||'))'||chr(10);
      elsif l_rec_tab(i).col_type = cons_varchar2_code THEN --timestamp with local time zone
        l_clob_all := l_clob_all||'to_char(l_clob('||to_char(i)||'))'||chr(10);
      elsif l_rec_tab(i).col_type = cons_date_code THEN --date
        l_clob_all := l_clob_all||'to_date(l_varchar2('||to_char(i)||'),'''||cons_date_frm||''')'||chr(10);
      elsif l_rec_tab(i).col_type = cons_timestamp_code THEN --timestamp
        l_clob_all := l_clob_all||'to_timestamp(l_varchar2('||to_char(i)||'),'''||cons_timestamp_frm||''')'||chr(10);
      elsif l_rec_tab(i).col_type = cons_timestamp_wtz_code THEN --timestamp with time zone
        l_clob_all := l_clob_all||'to_timestamp_tz(l_varchar2('||to_char(i)||'),'''||cons_timestamp_wtz_frm||''')'||chr(10);
      elsif l_rec_tab(i).col_type = cons_interval_ytm_code THEN --interval year to month
        l_clob_all := l_clob_all||'to_yminterval(l_varchar2('||to_char(i)||'))'||chr(10);
      elsif l_rec_tab(i).col_type = cons_interval_dts_code THEN --interval day to second
        l_clob_all := l_clob_all||'to_dsinterval(l_varchar2('||to_char(i)||'))'||chr(10);
      elsif l_rec_tab(i).col_type = cons_timestamp_lwtz_code THEN --timestamp with local time zone
        l_clob_all := l_clob_all||'to_timestamp_tz(l_varchar2('||to_char(i)||'),'''||cons_timestamp_wtz_frm||''')'||chr(10);
      ELSE  
        l_clob_all := l_clob_all||'l_varchar2('||to_char(i)||')'||chr(10);
      END IF;  
    END loop; 

    l_clob_all := l_clob_all||'  );'||chr(10);
  END loop;

  ---------------------------------------
  -- Building INSERT - end of code
  ---------------------------------------
  l_clob_all := l_clob_all||chr(10)||'end;';
  l_clob_all := l_clob_all||chr(10)||'/';

  ---------------------------------------
  -- Close cursor
  ---------------------------------------
  dbms_sql.close_cursor(l_cur);

  RETURN l_clob_all;
END;
/
