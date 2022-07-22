CREATE DATABASE new_citus_database;
SELECT DBLINK_EXEC('dbname=new_citus_database user=postgres', $remote$
CREATE EXTENSION citus;
$remote$);
-- Creates database on every worker
SELECT run_command_on_workers($cmd$CREATE DATABASE new_citus_database;$cmd$);
-- Connect to the fresh database on worker nodes and create the Citus extension
WITH citus_workers AS (SELECT node_name FROM citus_get_active_worker_nodes())
SELECT DBLINK_EXEC(FORMAT('host=%s dbname=new_citus_database user=postgres', node_name), $remote$
CREATE EXTENSION citus;
$remote$)
FROM citus_workers;
-- Add workers to the fresh database on the coordinator
WITH citus_workers AS (SELECT node_name FROM citus_get_active_worker_nodes() ORDER BY node_name)
SELECT DBLINK_EXEC('dbname=new_citus_database user=postgres', format($remote$
    SELECT citus_add_node('%s', 5432);
COMMIT ;
$remote$, node_name))
FROM citus_workers;
