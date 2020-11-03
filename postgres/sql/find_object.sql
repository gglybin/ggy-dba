--#-----------------------------------------------------------------------------------
--# File Name    : find_object.sql
--#
--# Description  : Script tries to find if object(s) with provided name are exist.
--#
--# Call Syntax  : psql=# \i find_object.sql
--#-----------------------------------------------------------------------------------

select
    nsp.nspname as SchemaName
    ,cls.relname as ObjectName
    ,rol.rolname as ObjectOwner
    ,case cls.relkind
        when 'r' then 'TABLE'
        when 'm' then 'MATERIALIZED_VIEW'
        when 'i' then 'INDEX'
        when 'S' then 'SEQUENCE'
        when 'v' then 'VIEW'
        when 'c' then 'TYPE'
        else cls.relkind::text
    end as ObjectType
from pg_class cls
join pg_roles rol
	on rol.oid = cls.relowner
join pg_namespace nsp
	on nsp.oid = cls.relnamespace
where nsp.nspname not in ('information_schema', 'pg_catalog')
    and nsp.nspname not like 'pg_toast%'
    -- and rol.rolname = 'you_user_name'
    -- and cls.relkind = 'object_type_here'
    -- and cls.relname = 'object_name_here'
order by nsp.nspname, cls.relkind, cls.relname;
