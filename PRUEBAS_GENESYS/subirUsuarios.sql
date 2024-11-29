SELECT  * FROM  reporteusuario

select count(id) from detallereporteusuario

select * from detallereporteusuario limit 5

SELECT
    *,
    pid,
    usename,
    application_name,
    client_addr,
    backend_start,
    state
FROM
    pg_stat_activity
WHERE client_addr = '192.168.21.11';

SELECT
    query,
    total_time,
    calls,
    mean_time,
    rows
FROM
    pg_stat_statements
ORDER BY
    total_time DESC
LIMIT 10;




