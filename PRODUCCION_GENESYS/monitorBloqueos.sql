

-- PG 9.5: usar "waiting" en lugar de "wait_event_type = 'Lock'"
SELECT * FROM pg_stat_activity a WHERE a.waiting = TRUE ORDER BY backend_start ASC

SELECT * FROM pg_stat_activity a WHERE a.backend_xmin IS NOT NULL --AND client_port IN (-1)


SELECT * FROM pg_stat_statements ORDER BY total_time DESC;

SELECT * FROM pg_stat_bgwriter;

SELECT pg_database.datname, pg_size_pretty(pg_database_size(pg_database.datname)) AS size
FROM pg_database;

SELECT relname, seq_scan, seq_tup_read, idx_scan, idx_tup_fetch
FROM pg_stat_all_tables;

SELECT version();

SELECT user, pid, client_addr, query, query_start, NOW() - query_start AS elapsed
FROM pg_stat_activity
WHERE query != '<IDLE>'
  and pid = 474261
ORDER BY elapsed DESC;



SELECT
    pid,
    usename,
    application_name,
    client_addr,
    client_port,
    datname,
    query,
    state
FROM
    pg_stat_activity
WHERE
    state = 'idle in transaction'


SELECT query, total_time
FROM pg_stat_statements
---WHERE total_time > 1000; -- Aquí, 1000 representa 1 segundo (en milisegundos)

--muestra el tamaño de las tablas de mayo a menor
SELECT
    schemaname || '.' || tablename AS table_full_name,
    pg_size_pretty(pg_total_relation_size(schemaname || '.' || tablename)) AS total_size
FROM
    pg_tables
ORDER BY
    pg_total_relation_size(schemaname || '.' || tablename) DESC;


SELECT pg_size_pretty(pg_database_size('genesys')) AS size;

SELECT
    schemaname,
    tablename,
    pg_size_pretty(total_size) AS total_size
FROM (
         SELECT
             schemaname,
             tablename,
             pg_total_relation_size(schemaname || '.' || tablename) AS total_size
         FROM pg_tables
     ) AS table_sizes
WHERE schemaname = 'audit'
ORDER BY total_size desc ;

SELECT
    schemaname,
    pg_size_pretty(sum(total_size)) AS total_size
FROM (
         SELECT
             schemaname,
             pg_total_relation_size(schemaname || '.' || tablename) AS total_size
         FROM pg_tables
     ) AS table_sizes
GROUP BY schemaname
ORDER BY total_size DESC;

-- Para ver los detalles de un proceso segun su pid
-- Entrar a postgres via terminal en la maquina donde esta instalado el postgres
-- psql -U postgres
-- Ejecutar
-- \x
-- Para ver todos los detalles de los procesos
-- select * from pg_stat_activity;
-- Para ver segun el numero de pid
-- select * from pg_stat_activity where pid = 1234;

select * from pg_stat_activity WHERE query ILIKE '%public%'

SELECT nspname AS esquema,
       pg_size_pretty(SUM(pg_total_relation_size(c.oid))) AS tamaño
FROM pg_class c
         JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE nspname NOT IN ('pg_catalog', 'information_schema')
  AND c.relkind = 'r'
GROUP BY nspname
ORDER BY SUM(pg_total_relation_size(c.oid)) DESC;


SELECT COUNT(*) AS total_conexiones
FROM pg_stat_activity;











