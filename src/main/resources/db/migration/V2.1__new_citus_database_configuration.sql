ALTER DATABASE new_citus_database SET WORK_MEM = '256MB';
SELECT run_command_on_workers($cmd$
ALTER DATABASE new_citus_database SET WORK_MEM = '256MB';
    $cmd$);