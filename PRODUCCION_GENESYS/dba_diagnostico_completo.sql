-- ============================================================================
-- DIAGNÓSTICO COMPLETO DBA — PostgreSQL 9.5 Health Check
-- Base de datos: genesys (Ecuasanitas)
-- Autor: DBA Monitor Agent
-- Fecha: 2026-04-09
-- Compatibilidad: PostgreSQL 9.5+
-- Descripción: Reporte completo del estado de la base de datos.
--              Ejecutar todas las queries de arriba a abajo para obtener
--              un diagnóstico general. Ideal para correr 1 vez al día o
--              antes/después de operaciones masivas.
-- ============================================================================


-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ 1. INFORMACIÓN GENERAL DEL SERVIDOR                                    ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
SELECT
    version() AS version_postgres,
    current_database() AS base_datos,
    current_user AS usuario_actual,
    inet_server_addr() AS ip_servidor,
    inet_server_port() AS puerto,
    pg_postmaster_start_time() AS inicio_servidor,
    NOW() - pg_postmaster_start_time() AS uptime,
    pg_size_pretty(pg_database_size(current_database())) AS tamaño_bd,
    (SELECT COUNT(*) FROM pg_stat_activity) AS conexiones_actuales,
    (SELECT setting FROM pg_settings WHERE name = 'max_connections') AS max_conexiones


-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ 2. PARÁMETROS DE MEMORIA Y RENDIMIENTO                                 ║
-- ║    Ajustado para PG 9.5 (sin jit, parallel workers, idle_in_tx_timeout)║
-- ╚══════════════════════════════════════════════════════════════════════════╝
SELECT
    name AS parametro,
    setting AS valor_actual,
    unit AS unidad,
    boot_val AS valor_por_defecto,
    CASE WHEN setting <> boot_val THEN 'MODIFICADO' ELSE 'Default' END AS estado,
    short_desc AS descripcion
FROM pg_settings
WHERE name IN (
    -- Memoria
    'shared_buffers', 'effective_cache_size', 'work_mem', 'maintenance_work_mem',
    'huge_pages', 'temp_buffers', 'wal_buffers',
    -- Conexiones
    'max_connections', 'superuser_reserved_connections',
    -- WAL
    'wal_level', 'max_wal_size', 'min_wal_size', 'checkpoint_completion_target',
    'checkpoint_timeout',
    -- Workers (PG 9.5 solo tiene max_worker_processes)
    'max_worker_processes',
    -- Planner
    'random_page_cost', 'seq_page_cost', 'effective_io_concurrency',
    'default_statistics_target',
    -- Timeouts
    'statement_timeout', 'lock_timeout', 'deadlock_timeout',
    -- Logging
    'log_min_duration_statement', 'log_checkpoints', 'log_lock_waits',
    'log_temp_files',
    -- Autovacuum
    'autovacuum', 'autovacuum_max_workers', 'autovacuum_naptime',
    'autovacuum_vacuum_threshold', 'autovacuum_analyze_threshold',
    'autovacuum_vacuum_scale_factor', 'autovacuum_analyze_scale_factor',
    -- Track
    'track_activity_query_size', 'track_io_timing'
)
ORDER BY
    CASE
        WHEN category ILIKE '%memory%' THEN 1
        WHEN category ILIKE '%connection%' THEN 2
        WHEN category ILIKE '%wal%' THEN 3
        WHEN category ILIKE '%query%' THEN 4
        ELSE 5
    END, name


-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ 3. EXTENSIONES INSTALADAS                                               ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
SELECT
    extname AS extension,
    extversion AS version,
    n.nspname AS esquema,
    CASE
        WHEN extname = 'pg_stat_statements' THEN 'Estadisticas de queries'
        WHEN extname = 'dblink' THEN 'Conexion cruzada entre BDs'
        WHEN extname = 'pgcrypto' THEN 'Funciones criptograficas'
        WHEN extname = 'pg_trgm' THEN 'Busqueda por trigramas'
        WHEN extname = 'unaccent' THEN 'Quitar acentos'
        WHEN extname = 'plpgsql' THEN 'PL/pgSQL'
        ELSE ''
    END AS descripcion
FROM pg_extension e
LEFT JOIN pg_namespace n ON e.extnamespace = n.oid
ORDER BY extname


-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ 4. ESTADÍSTICAS DE LA BASE DE DATOS                                     ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
SELECT
    datname AS base_datos,
    numbackends AS conexiones,
    xact_commit AS commits,
    xact_rollback AS rollbacks,
    CASE WHEN xact_commit + xact_rollback > 0
        THEN ROUND(100.0 * xact_rollback / (xact_commit + xact_rollback), 4)
        ELSE 0
    END AS pct_rollback,
    blks_read AS bloques_disco,
    blks_hit AS bloques_cache,
    CASE WHEN blks_hit + blks_read > 0
        THEN ROUND(100.0 * blks_hit / (blks_hit + blks_read), 2)
        ELSE 100
    END AS cache_hit_pct,
    tup_returned AS filas_retornadas,
    tup_fetched AS filas_obtenidas,
    tup_inserted AS inserts,
    tup_updated AS updates,
    tup_deleted AS deletes,
    conflicts AS conflictos,
    temp_files AS archivos_temp,
    pg_size_pretty(temp_bytes::bigint) AS bytes_temp,
    deadlocks,
    pg_size_pretty(pg_database_size(datname)) AS tamaño,
    stats_reset AS ultimo_reset
FROM pg_stat_database
WHERE datname IN ('genesys', 'luca')
ORDER BY datname


-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ 5. TOP 20 TABLAS MÁS GRANDES                                           ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
SELECT
    ROW_NUMBER() OVER (ORDER BY pg_total_relation_size(quote_ident(schemaname)||'.'||quote_ident(relname)) DESC) AS rank,
    schemaname AS esquema,
    relname AS tabla,
    n_live_tup AS filas_vivas,
    n_dead_tup AS filas_muertas,
    pg_size_pretty(pg_relation_size(quote_ident(schemaname)||'.'||quote_ident(relname))) AS tamaño_datos,
    pg_size_pretty(pg_total_relation_size(quote_ident(schemaname)||'.'||quote_ident(relname))
        - pg_relation_size(quote_ident(schemaname)||'.'||quote_ident(relname))) AS tamaño_indices,
    pg_size_pretty(pg_total_relation_size(quote_ident(schemaname)||'.'||quote_ident(relname))) AS tamaño_total,
    seq_scan AS scans_seq,
    idx_scan AS scans_idx,
    CASE WHEN seq_scan + COALESCE(idx_scan, 0) > 0
        THEN ROUND(100.0 * COALESCE(idx_scan, 0) / (seq_scan + COALESCE(idx_scan, 0)), 1)
        ELSE NULL
    END AS pct_idx_scan,
    last_autovacuum::date AS ultimo_autovacuum,
    last_autoanalyze::date AS ultimo_autoanalyze
FROM pg_stat_user_tables
ORDER BY pg_total_relation_size(quote_ident(schemaname)||'.'||quote_ident(relname)) DESC
LIMIT 20


-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ 6. ÍNDICES: Eficiencia y uso                                            ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

-- 6a. Tablas con ratio de index scan bajo (necesitan más índices)
SELECT
    schemaname AS esquema,
    relname AS tabla,
    seq_scan AS scans_secuenciales,
    idx_scan AS scans_por_indice,
    CASE WHEN seq_scan + COALESCE(idx_scan, 0) > 0
        THEN ROUND(100.0 * seq_scan / (seq_scan + COALESCE(idx_scan, 0)), 1)
        ELSE 0
    END AS pct_seq_scan,
    n_live_tup AS filas,
    pg_size_pretty(pg_total_relation_size(quote_ident(schemaname)||'.'||quote_ident(relname))) AS tamaño
FROM pg_stat_user_tables
WHERE seq_scan > 50 AND n_live_tup > 10000
    AND schemaname = 'public'
ORDER BY seq_tup_read DESC
LIMIT 15


-- 6b. Índices no utilizados (candidatos para eliminar)
SELECT
    schemaname AS esquema,
    relname AS tabla,
    indexrelname AS indice,
    idx_scan AS veces_usado,
    pg_size_pretty(pg_relation_size(i.indexrelid)) AS tamaño
FROM pg_stat_user_indexes i
WHERE idx_scan = 0
    AND schemaname = 'public'
    AND NOT EXISTS (
        SELECT 1 FROM pg_constraint c WHERE c.conindid = i.indexrelid
    )
ORDER BY pg_relation_size(i.indexrelid) DESC
LIMIT 20


-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ 7. AUTOVACUUM: Estado y necesidades                                     ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
SELECT
    schemaname AS esquema,
    relname AS tabla,
    n_live_tup AS filas_vivas,
    n_dead_tup AS filas_muertas,
    CASE WHEN n_live_tup > 0
        THEN ROUND(100.0 * n_dead_tup / n_live_tup, 2)
        ELSE 0
    END AS pct_muertas,
    last_vacuum,
    last_autovacuum,
    last_analyze,
    last_autoanalyze,
    vacuum_count,
    autovacuum_count,
    analyze_count,
    autoanalyze_count,
    -- Calcular si necesita vacuum basado en threshold de autovacuum
    CASE WHEN n_dead_tup > (
        (SELECT setting::int FROM pg_settings WHERE name = 'autovacuum_vacuum_threshold')
        + (SELECT setting::float FROM pg_settings WHERE name = 'autovacuum_vacuum_scale_factor') * n_live_tup
    ) THEN 'NECESITA VACUUM'
    ELSE 'OK'
    END AS estado_vacuum
FROM pg_stat_user_tables
WHERE n_dead_tup > 0
ORDER BY n_dead_tup DESC
LIMIT 25


-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ 8. CHECKPOINTS Y I/O                                                    ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
SELECT
    checkpoints_timed AS checkpoints_programados,
    checkpoints_req AS checkpoints_forzados,
    CASE WHEN checkpoints_timed + checkpoints_req > 0
        THEN ROUND(100.0 * checkpoints_req / (checkpoints_timed + checkpoints_req), 2)
        ELSE 0
    END AS pct_forzados,
    ROUND(checkpoint_write_time::numeric / 1000, 2) AS escritura_seg,
    ROUND(checkpoint_sync_time::numeric / 1000, 2) AS sync_seg,
    buffers_checkpoint,
    buffers_clean AS buffers_bgwriter,
    buffers_backend,
    CASE WHEN buffers_checkpoint + buffers_clean + buffers_backend > 0
        THEN ROUND(100.0 * buffers_backend / (buffers_checkpoint + buffers_clean + buffers_backend), 2)
        ELSE 0
    END AS pct_backend_writes,
    maxwritten_clean AS bgwriter_limit_alcanzado,
    buffers_alloc AS buffers_nuevos,
    stats_reset AS desde
FROM pg_stat_bgwriter


-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ 9. XID WRAPAROUND — Prevención                                         ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
SELECT
    c.oid::regclass AS tabla,
    age(c.relfrozenxid) AS edad_xid,
    ROUND(100.0 * age(c.relfrozenxid) / 2000000000, 4) AS pct_wraparound,
    CASE
        WHEN age(c.relfrozenxid) > 1500000000 THEN 'URGENTE'
        WHEN age(c.relfrozenxid) > 1000000000 THEN 'ALTO'
        WHEN age(c.relfrozenxid) > 500000000  THEN 'ATENCION'
        ELSE 'OK'
    END AS estado,
    pg_size_pretty(pg_total_relation_size(c.oid)) AS tamaño
FROM pg_class c
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE c.relkind = 'r'
    AND n.nspname NOT IN ('pg_catalog', 'information_schema')
ORDER BY age(c.relfrozenxid) DESC
LIMIT 15


-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ 10. TABLAS ESPECÍFICAS DE ECUASANITAS — Salud                           ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
SELECT
    relname AS tabla,
    n_live_tup AS filas_vivas,
    n_dead_tup AS filas_muertas,
    seq_scan AS scans_seq,
    idx_scan AS scans_idx,
    pg_size_pretty(pg_total_relation_size(quote_ident(schemaname)||'.'||quote_ident(relname))) AS tamaño_total,
    last_autovacuum::date AS ultimo_vacuum,
    last_autoanalyze::date AS ultimo_analyze
FROM pg_stat_user_tables
WHERE relname IN (
    'contrato', 'afiliacion', 'entidad', 'detalleemision', 'erroremision',
    'obligacion', 'detalle', 'coberturacontratada', 'nivel', 'planmedico',
    'comision', 'detallecomision', 'autorizacioncobro', 'familia',
    'titular', 'preventaweb', 'generador', 'vigenciaafiliacion',
    'transferenciamasiva', 'procesotransferenciamasiva', 'cuotapendiente'
)
ORDER BY pg_total_relation_size(quote_ident(schemaname)||'.'||quote_ident(relname)) DESC


-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ 11. RESUMEN FINAL — Indicadores clave                                   ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
SELECT
    'Health Check Completado' AS reporte,
    NOW() AS fecha,
    current_database() AS base_datos,
    pg_size_pretty(pg_database_size(current_database())) AS tamaño,
    (SELECT ROUND(100.0 * blks_hit / GREATEST(blks_hit + blks_read, 1), 2)
     FROM pg_stat_database WHERE datname = current_database()) AS cache_hit_pct,
    (SELECT COUNT(*) FROM pg_stat_activity) AS conexiones,
    (SELECT deadlocks FROM pg_stat_database WHERE datname = current_database()) AS deadlocks,
    (SELECT MAX(age(relfrozenxid)) FROM pg_class WHERE relkind = 'r') AS max_xid_age,
    (SELECT SUM(n_dead_tup) FROM pg_stat_user_tables) AS total_filas_muertas,
    (SELECT COUNT(*) FROM pg_stat_user_indexes WHERE idx_scan = 0 AND schemaname = 'public') AS indices_sin_uso
