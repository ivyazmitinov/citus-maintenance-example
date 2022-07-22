WITH databases AS (SELECT *
                   FROM (VALUES ('new_citus_database'),
                                ('another_citus_database')) AS t(db_name))
SELECT DBLINK_EXEC(FORMAT('dbname=%I user=postgres', db_name), $remote$
START TRANSACTION;
CREATE VIEW test_table_view AS SELECT * FROM test_table;
COMMIT;
$remote$)
FROM databases;