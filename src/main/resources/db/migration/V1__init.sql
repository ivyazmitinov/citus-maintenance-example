CREATE EXTENSION dblink;
CREATE OR REPLACE PROCEDURE public.execute_on_databases_with_citus(statement TEXT)
    LANGUAGE plpgsql AS
$$
DECLARE
    db_name TEXT;
BEGIN
    FOREACH db_name IN ARRAY (SELECT ARRAY_AGG(datname)
                              FROM pg_database
                              WHERE EXISTS(SELECT *
                                           FROM DBLINK(FORMAT('dbname=%s', datname),
                                                       $cmd$SELECT TRUE FROM pg_extension WHERE extname = 'citus'$cmd$) AS t(citus_installed BOOLEAN))
                                AND datname NOT IN ('template0', 'template1'))
        LOOP
            RAISE NOTICE 'EXECUTING ON %', db_name;
            EXECUTE FORMAT('SELECT * FROM dblink_exec(''dbname=%s'', $_CMD_$%s$_CMD_$);', db_name,
                           statement);
        END LOOP;
END
$$;

CREATE OR REPLACE PROCEDURE public.execute_on_production_databases_with_citus(statement TEXT)
    LANGUAGE plpgsql AS
$$
DECLARE
    db_name TEXT;
BEGIN
    FOREACH db_name IN ARRAY (SELECT ARRAY_AGG(datname)
                              FROM pg_database
                              WHERE EXISTS(SELECT *
                                           FROM DBLINK(FORMAT('dbname=%s', datname),
                                                       $cmd$SELECT TRUE FROM pg_extension WHERE extname = 'citus'$cmd$) AS t(citus_installed BOOLEAN))
                                AND datname NOT IN ('template0', 'template1', 'maintenance'))
        LOOP
            EXECUTE FORMAT('SELECT * FROM dblink_exec(''dbname=%s'', $_CMD_$%s$_CMD_$);', db_name,
                           statement);
        END LOOP;
END
$$;

CREATE OR REPLACE PROCEDURE public.execute_on_all_databases(statement TEXT)
    LANGUAGE plpgsql AS
$$
DECLARE
    db_name TEXT;
BEGIN
    for db_name IN (SELECT datname
                    FROM pg_database
                    WHERE datname NOT IN ('template0')
                    ORDER BY datname)
        LOOP
            -- Обновить функции на существующих базах, включая template0
            EXECUTE FORMAT('SELECT * FROM dblink_exec(''dbname=%s'', $_CMD_$%s$_CMD_$);', db_name, statement);
        end loop;
END
$$;

CREATE OR REPLACE PROCEDURE public.execute_on_databases_on_all_nodes_with_citus(statement TEXT)
    LANGUAGE plpgsql AS
$$
DECLARE
    db_name TEXT;
    node    TEXT;
BEGIN
    FOREACH db_name IN ARRAY (SELECT ARRAY_AGG(datname)
                              FROM pg_database
                              WHERE EXISTS(SELECT *
                                           FROM DBLINK(FORMAT('dbname=%s', datname),
                                                       $cmd$SELECT TRUE FROM pg_extension WHERE extname = 'citus'$cmd$) AS t(citus_installed BOOLEAN))
                                AND datname NOT IN ('template0', 'template1', 'maintenance'))
        LOOP
            EXECUTE FORMAT('SELECT * FROM dblink_exec(''dbname=%s'', $_CMD_$%s$_CMD_$);', db_name,
                           statement);
            FOR node IN (SELECT node_name FROM citus_get_active_worker_nodes())
                LOOP
                    EXECUTE FORMAT('SELECT * FROM dblink_exec(''dbname=%s host=%s'', $_CMD_$%s$_CMD_$);',
                                   db_name,
                                   node,
                                   statement);
                END LOOP;
        END LOOP;
END
$$;



