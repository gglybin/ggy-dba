--#-----------------------------------------------------------------------------------
--# File Name    : param_info.sql
--#
--# Description  : Shows current value of given parameter(s).
--#
--# Call Syntax  : bash$ psql -v param=\'parameter_to_check\' -f param_info.sql
--#
--# Example      : bash$ psql -v param=\'wal%\' -f param_info.sql
--#
--# References   : https://edu.postgrespro.ru/dba1/dba1_03_tools_configuration.html
--#-----------------------------------------------------------------------------------

\echo ''
\echo '##'
\echo '## From config file:'
\echo '##'
\echo ''

select name
       ,setting
       ,sourcefile
       ,applied
from   pg_file_settings
where  name like :param
-- and    applied='t'
order  by name, applied desc;

--
-- Note: Представление pg_file_settings показывает лишь содержимое файлов конфигурации, реальные значения параметров могут отличаться.
--

\echo ''
\echo '##'
\echo '## From instance:'
\echo '##'
\echo ''

select name
       ,setting
       ,unit
       ,sourcefile
       ,pending_restart
       ,context
from   pg_settings
where  name like :param
order  by name;

--
-- Note: - name, setting, unit - название и значение параметра,
--       - boot_val - значение по умолчанию,
--       - reset_val - если параметр был изменен во время сеанса, то командой RESET можно восстановить это значение,
--       - source - источник текущего значения параметра,
--       - pending_restart - значение изменено в файле конфигурации, но для применения требуется перезапуск сервера.
--       - context:
--            - internal - изменить нельзя, задано при установке,
--            - postmaster - требуется перезапуск сервера,
--            - sighup - требуется перечитать файлы конфигурации,
--            - superuser - суперпользователь может изменить для своего сеанса,
--            - user - любой пользователь может изменить для своего сеанса.
--

--
-- Change: psql> ALTER SYSTEM SET work_mem TO '16MB'; -- запишет в "postgresql.auto.conf", чтобы применить онлайн нужно перечитать конфиг.
--
--         psql> SELECT pg_reload_conf();    -- (!!!) применит новое значение, если для параметра context != postmaster , иначе потребуется рестрат инстанса.
--          or
--         bash$ pg_ctl reload
--
-- Reset:  psql> ALTER SYSTEM RESET work_mem; -- удалит значение параметра из файла "postgresql.auto.conf".
--
