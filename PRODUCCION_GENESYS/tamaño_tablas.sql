-- Consulta para obtener el tamaño de todas las tablas en la base de datos
-- Ordenadas por tamaño total (tabla + índices) de mayor a menor

SELECT
    schemaname AS esquema,
    tablename AS tabla,
    pg_size_pretty(pg_total_relation_size(quote_ident(schemaname)||'.'||quote_ident(tablename))) AS tamaño_total,
    pg_size_pretty(pg_relation_size(quote_ident(schemaname)||'.'||quote_ident(tablename))) AS tamaño_tabla,
    pg_size_pretty(pg_total_relation_size(quote_ident(schemaname)||'.'||quote_ident(tablename)) - pg_relation_size(quote_ident(schemaname)||'.'||quote_ident(tablename))) AS tamaño_indices,
    pg_total_relation_size(quote_ident(schemaname)||'.'||quote_ident(tablename)) AS bytes_totales
FROM pg_tables
WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
ORDER BY pg_total_relation_size(quote_ident(schemaname)||'.'||quote_ident(tablename)) DESC;

-- Resumen por esquema
SELECT
    schemaname AS esquema,
    COUNT(*) AS num_tablas,
    pg_size_pretty(SUM(pg_total_relation_size(quote_ident(schemaname)||'.'||quote_ident(tablename)))) AS tamaño_total
FROM pg_tables
WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
GROUP BY schemaname
ORDER BY SUM(pg_total_relation_size(quote_ident(schemaname)||'.'||quote_ident(tablename))) DESC;

-- Tamaño total de la base de datos
SELECT
    pg_database.datname AS base_datos,
    pg_size_pretty(pg_database_size(pg_database.datname)) AS tamaño
FROM pg_database
WHERE datname = current_database();

-- Tamaño total del esquema dwh
SELECT
  pg_size_pretty(SUM(pg_total_relation_size(quote_ident(schemaname)||'.'||quote_ident(tablename)))) AS tamaño_total,
  SUM(pg_total_relation_size(quote_ident(schemaname)||'.'||quote_ident(tablename))) AS bytes_totales
FROM pg_tables
WHERE schemaname = 'dwh';

-- Detalle por tabla dentro del esquema dwh
SELECT
  tablename AS tabla,
  pg_size_pretty(pg_total_relation_size(quote_ident(schemaname)||'.'||quote_ident(tablename))) AS tamaño_total,
  pg_size_pretty(pg_relation_size(quote_ident(schemaname)||'.'||quote_ident(tablename))) AS tamaño_tabla,
  pg_size_pretty(pg_total_relation_size(quote_ident(schemaname)||'.'||quote_ident(tablename)) - pg_relation_size(quote_ident(schemaname)||'.'||quote_ident(tablename))) AS tamaño_indices,
  pg_total_relation_size(quote_ident(schemaname)||'.'||quote_ident(tablename)) AS bytes_totales
FROM pg_tables
WHERE schemaname = 'dwh'
ORDER BY pg_total_relation_size(quote_ident(schemaname)||'.'||quote_ident(tablename)) DESC;

