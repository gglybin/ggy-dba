#!/bin/bash

for ii in $(psql -tc "select datname from pg_database where datallowconn"); do
  psql -d $ii -tc "SELECT rpad (e.extname, 30) AS Name \
                        , rpad (e.extversion, 10) as Version \
                        , rpad ('$ii', 50) \
                     FROM pg_catalog.pg_extension e \
                 GROUP BY Name, Version
                 ORDER BY 3
             -- WHERE e.extname not in ('plpgsql')"
done
