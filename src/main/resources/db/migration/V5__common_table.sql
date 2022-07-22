WITH databases AS (SELECT *
                   FROM (VALUES ('new_citus_database'),
                                ('another_citus_database')) AS t(db_name))
SELECT DBLINK_EXEC(FORMAT('dbname=%I user=postgres', db_name), $remote$
START TRANSACTION;
CREATE TABLE test_table (user_id TEXT, data jsonb);
SELECT create_distributed_table('test_table', 'user_id');
COMMIT;
$remote$)
FROM databases;