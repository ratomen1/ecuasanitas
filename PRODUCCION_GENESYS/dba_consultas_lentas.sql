-- ============================================================================
-- MONITOREO DE CONSULTAS LENTAS — PostgreSQL 9.5 DBA Toolkit
-- Base de datos: genesys (Ecuasanitas)
-- Autor: DBA Monitor Agent
-- Fecha: 2026-04-09
-- Compatibilidad: PostgreSQL 9.5+
-- Descripción: Detección y análisis de consultas que están demorando mucho
-- ============================================================================

-- ============================================================================
-- 1. CONSULTAS ACTIVAS MÁS LENTAS (en ejecución ahora mismo)
-- Las queries que llevan más tiempo ejecutándose
-- En PG 9.5 se usa "waiting" (boolean) en lugar de wait_event_type/wait_event
-- ============================================================================
SELECT
    pid,
    usename AS usuario,
    application_name AS app,
    client_addr AS ip,
    datname AS base_datos,
    state AS estado,
    waiting AS esta_esperando,
    NOW() - query_start AS duracion_query,
    NOW() - xact_start AS duracion_transaccion,
    LEFT(query, 300) AS query_resumido,
    query_start AS inicio_query
FROM pg_stat_activity
WHERE state = 'active'
    AND pid <> pg_backend_pid()
    AND query NOT ILIKE '%pg_stat_activity%'
ORDER BY query_start ASC


-- ============================================================================
-- 2. CONSULTAS ACTIVAS DE MÁS DE 1 MINUTO
-- Candidatas a investigación o cancelación
-- ============================================================================
SELECT
    pid,
    usename AS usuario,
    application_name AS app,
    client_addr AS ip,
    NOW() - query_start AS duracion,
    state AS estado,
    waiting AS esta_esperando,
    LEFT(query, 500) AS query_completa
FROM pg_stat_activity
WHERE state = 'active'
    AND NOW() - query_start > INTERVAL '1 minute'
    AND pid <> pg_backend_pid()
ORDER BY query_start ASC


-- ============================================================================
-- 3. CONSULTAS ACTIVAS DE MÁS DE 5 MINUTOS (ALERTA ROJA)
-- Estas queries necesitan atención inmediata
-- ============================================================================
SELECT
    pid,
    usename AS usuario,
    application_name AS app,
    client_addr AS ip,
    NOW() - query_start AS duracion,
    CASE
        WHEN NOW() - query_start > INTERVAL '30 minutes' THEN 'CRITICO (>30min)'
        WHEN NOW() - query_start > INTERVAL '15 minutes' THEN 'ALTO (>15min)'
        WHEN NOW() - query_start > INTERVAL '5 minutes'  THEN 'MEDIO (>5min)'
    END AS severidad,
    state AS estado,
    waiting AS esta_esperando,
    query
FROM pg_stat_activity
WHERE state IN ('active', 'idle in transaction')
    AND NOW() - query_start > INTERVAL '5 minutes'
    AND pid <> pg_backend_pid()
ORDER BY query_start ASC


-- ============================================================================
-- 4. TOP CONSULTAS MÁS LENTAS HISTÓRICAS (requiere pg_stat_statements)
-- ⚠️ Requiere la extensión pg_stat_statements habilitada
-- CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
-- En PG 9.5 las columnas se llaman total_time, mean_time, etc.
-- ============================================================================
SELECT
    LEFT(query, 300) AS query_resumida,
    calls AS veces_ejecutada,
    ROUND(total_time::numeric, 2) AS tiempo_total_ms,
    ROUND(mean_time::numeric, 2) AS tiempo_promedio_ms,
    ROUND(max_time::numeric, 2) AS tiempo_maximo_ms,
    ROUND(min_time::numeric, 2) AS tiempo_minimo_ms,
    ROUND(stddev_time::numeric, 2) AS desviacion_std_ms,
    rows AS filas_retornadas,
    ROUND((100 * total_time / SUM(total_time) OVER())::numeric, 2) AS porcentaje_tiempo_total,
    shared_blks_hit AS bloques_cache,
    shared_blks_read AS bloques_disco,
    CASE WHEN shared_blks_hit + shared_blks_read > 0
        THEN ROUND(100.0 * shared_blks_hit / (shared_blks_hit + shared_blks_read), 2)
        ELSE 100
    END AS cache_hit_ratio
FROM pg_stat_statements
WHERE dbid = (SELECT oid FROM pg_database WHERE datname = current_database())
ORDER BY total_time DESC
LIMIT 30


-- ============================================================================
-- 5. TOP CONSULTAS POR TIEMPO PROMEDIO (las más lentas individualmente)
-- ============================================================================
SELECT
    LEFT(query, 300) AS query_resumida,
    calls AS veces_ejecutada,
    ROUND(mean_time::numeric, 2) AS tiempo_promedio_ms,
    ROUND(max_time::numeric, 2) AS tiempo_maximo_ms,
    ROUND(total_time::numeric, 2) AS tiempo_total_ms,
    rows AS filas_totales,
    ROUND(rows::numeric / GREATEST(calls, 1), 0) AS filas_promedio
FROM pg_stat_statements
WHERE dbid = (SELECT oid FROM pg_database WHERE datname = current_database())
    AND calls >= 5
ORDER BY mean_time DESC
LIMIT 20


-- ============================================================================
-- 6. CONSULTAS QUE MÁS LEEN DEL DISCO (I/O intensivo)
-- Estas queries necesitan optimización de índices
-- ============================================================================
SELECT
    LEFT(query, 300) AS query_resumida,
    calls AS veces_ejecutada,
    shared_blks_read AS bloques_leidos_disco,
    shared_blks_hit AS bloques_en_cache,
    CASE WHEN shared_blks_hit + shared_blks_read > 0
        THEN ROUND(100.0 * shared_blks_read / (shared_blks_hit + shared_blks_read), 2)
        ELSE 0
    END AS porcentaje_disco,
    ROUND(total_time::numeric, 2) AS tiempo_total_ms,
    ROUND(mean_time::numeric, 2) AS tiempo_promedio_ms,
    rows AS filas_retornadas
FROM pg_stat_statements
WHERE dbid = (SELECT oid FROM pg_database WHERE datname = current_database())
    AND shared_blks_read > 100
ORDER BY shared_blks_read DESC
LIMIT 20


-- ============================================================================
-- 7. CONSULTAS CON TEMP FILES (las que desbordan work_mem)
-- Indican que se necesita aumentar work_mem o mejorar la query
-- ============================================================================
SELECT
    LEFT(query, 300) AS query_resumida,
    calls AS veces_ejecutada,
    temp_blks_read AS bloques_temp_leidos,
    temp_blks_written AS bloques_temp_escritos,
    ROUND(mean_time::numeric, 2) AS tiempo_promedio_ms,
    ROUND(total_time::numeric, 2) AS tiempo_total_ms
FROM pg_stat_statements
WHERE dbid = (SELECT oid FROM pg_database WHERE datname = current_database())
    AND (temp_blks_read > 0 OR temp_blks_written > 0)
ORDER BY temp_blks_written DESC
LIMIT 20


-- ============================================================================
-- 8. TABLAS CON SEQUENTIAL SCANS EXCESIVOS
-- Tablas que se leen secuencialmente (sin usar índices)
-- Candidatas principales para crear índices
-- ============================================================================
SELECT
    schemaname AS esquema,
    relname AS tabla,
    seq_scan AS scans_secuenciales,
    idx_scan AS scans_por_indice,
    CASE WHEN seq_scan + COALESCE(idx_scan, 0) > 0
        THEN ROUND(100.0 * seq_scan / (seq_scan + COALESCE(idx_scan, 0)), 2)
        ELSE 0
    END AS porcentaje_seq_scan,
    seq_tup_read AS filas_leidas_seq,
    idx_tup_fetch AS filas_por_indice,
    n_live_tup AS filas_vivas,
    pg_size_pretty(pg_total_relation_size(quote_ident(schemaname) || '.' || quote_ident(relname))) AS tamaño
FROM pg_stat_user_tables
WHERE seq_scan > 100
    AND n_live_tup > 10000
ORDER BY seq_tup_read DESC
LIMIT 30


-- ============================================================================
-- 9. ÍNDICES NO UTILIZADOS (candidatos para eliminar)
-- Índices que ocupan espacio pero no se usan
-- ============================================================================
SELECT
    schemaname AS esquema,
    relname AS tabla,
    indexrelname AS indice,
    idx_scan AS veces_usado,
    pg_size_pretty(pg_relation_size(quote_ident(schemaname) || '.' || quote_ident(indexrelname))) AS tamaño_indice,
    pg_relation_size(quote_ident(schemaname) || '.' || quote_ident(indexrelname)) AS bytes_indice
FROM pg_stat_user_indexes
WHERE idx_scan = 0
    AND schemaname = 'public'
ORDER BY pg_relation_size(quote_ident(schemaname) || '.' || quote_ident(indexrelname)) DESC
LIMIT 30


-- ============================================================================
-- 10. ÍNDICES DUPLICADOS O REDUNDANTES
-- ============================================================================
SELECT
    pg_size_pretty(SUM(pg_relation_size(idx))::bigint) AS tamaño,
    (ARRAY_AGG(idx))[1] AS indice1,
    (ARRAY_AGG(idx))[2] AS indice2,
    (ARRAY_AGG(idx))[3] AS indice3
FROM (
    SELECT
        indexrelid::regclass AS idx,
        (indrelid::text || E'\n' || indclass::text || E'\n'
         || indkey::text || E'\n' || COALESCE(indexprs::text, '') || E'\n'
         || COALESCE(indpred::text, '')) AS clave
    FROM pg_index
) sub
GROUP BY clave
HAVING COUNT(*) > 1
ORDER BY SUM(pg_relation_size(idx)) DESC


-- ============================================================================
-- 11. PARÁMETROS DE CONFIGURACIÓN RELEVANTES PARA RENDIMIENTO
-- Ajustado para PG 9.5 (sin jit, max_parallel_workers, idle_in_transaction_session_timeout)
-- ============================================================================
SELECT
    name AS parametro,
    setting AS valor,
    unit AS unidad,
    short_desc AS descripcion
FROM pg_settings
WHERE name IN (
    'shared_buffers', 'effective_cache_size', 'work_mem',
    'maintenance_work_mem', 'max_connections',
    'random_page_cost', 'effective_io_concurrency',
    'wal_buffers', 'checkpoint_completion_target',
    'max_wal_size', 'min_wal_size', 'statement_timeout',
    'lock_timeout', 'log_min_duration_statement',
    'track_activity_query_size', 'default_statistics_target',
    'autovacuum', 'autovacuum_max_workers',
    'autovacuum_vacuum_scale_factor', 'autovacuum_analyze_scale_factor',
    'max_worker_processes', 'checkpoint_timeout',
    'deadlock_timeout', 'log_checkpoints', 'log_lock_waits'
)
ORDER BY name


-- ============================================================================
-- 12. RESET DE ESTADÍSTICAS DE pg_stat_statements
-- ⚠️ Ejecutar solo cuando se quiera empezar de cero las estadísticas
-- ============================================================================
-- SELECT pg_stat_statements_reset();
