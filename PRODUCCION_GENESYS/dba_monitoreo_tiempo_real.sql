-- ============================================================================
-- MONITOREO EN TIEMPO REAL — PostgreSQL 9.5 DBA Toolkit Completo
-- Base de datos: genesys (Ecuasanitas)
-- Autor: DBA Monitor Agent
-- Fecha: 2026-04-09
-- Compatibilidad: PostgreSQL 9.5+
-- Descripción: Dashboard completo de monitoreo DBA para ejecución periódica
-- ============================================================================

-- ████████████████████████████████████████████████████████████████████████████
-- SECCIÓN A: DASHBOARD RÁPIDO — Ejecutar cada 30 segundos
-- ████████████████████████████████████████████████████████████████████████████

-- ============================================================================
-- A1. RESUMEN GENERAL DEL SERVIDOR (ejecutar primero)
-- Un solo resultado con toda la salud del servidor
-- En PG 9.5: "waiting" reemplaza a "wait_event_type = 'Lock'"
-- ============================================================================
SELECT
    current_database() AS base_datos,
    pg_postmaster_start_time() AS servidor_iniciado,
    NOW() - pg_postmaster_start_time() AS uptime,
    (SELECT COUNT(*) FROM pg_stat_activity) AS conexiones_totales,
    (SELECT COUNT(*) FROM pg_stat_activity WHERE state = 'active') AS conexiones_activas,
    (SELECT COUNT(*) FROM pg_stat_activity WHERE state = 'idle') AS conexiones_idle,
    (SELECT COUNT(*) FROM pg_stat_activity WHERE state = 'idle in transaction') AS idle_in_transaction,
    (SELECT COUNT(*) FROM pg_stat_activity WHERE waiting = TRUE) AS esperando_lock,
    (SELECT COUNT(*) FROM pg_stat_activity WHERE state = 'active' AND NOW() - query_start > INTERVAL '1 minute') AS queries_lentas_1min,
    (SELECT COUNT(*) FROM pg_stat_activity WHERE state = 'active' AND NOW() - query_start > INTERVAL '5 minutes') AS queries_lentas_5min,
    (SELECT setting::int FROM pg_settings WHERE name = 'max_connections') AS max_conexiones,
    ROUND(100.0 * (SELECT COUNT(*) FROM pg_stat_activity)::numeric /
        (SELECT setting::int FROM pg_settings WHERE name = 'max_connections'), 1) AS porcentaje_conexiones,
    pg_size_pretty(pg_database_size(current_database())) AS tamaño_bd,
    (SELECT deadlocks FROM pg_stat_database WHERE datname = current_database()) AS deadlocks_acumulados


-- ============================================================================
-- A2. ESTADÍSTICAS DE CACHE HIT RATIO (debe ser > 99%)
-- Si es menor al 99%, considerar aumentar shared_buffers
-- ============================================================================
SELECT
    'Base de datos' AS tipo,
    ROUND(100.0 * SUM(blks_hit) / GREATEST(SUM(blks_hit + blks_read), 1), 2) AS cache_hit_ratio_pct,
    SUM(blks_hit) AS bloques_cache,
    SUM(blks_read) AS bloques_disco,
    SUM(xact_commit) AS transacciones_commit,
    SUM(xact_rollback) AS transacciones_rollback,
    SUM(tup_returned) AS filas_retornadas,
    SUM(tup_fetched) AS filas_obtenidas,
    SUM(tup_inserted) AS filas_insertadas,
    SUM(tup_updated) AS filas_actualizadas,
    SUM(tup_deleted) AS filas_eliminadas,
    SUM(temp_files) AS archivos_temporales,
    pg_size_pretty(SUM(temp_bytes)::bigint) AS tamaño_temp_files
FROM pg_stat_database
WHERE datname = current_database()


-- ============================================================================
-- A3. CACHE HIT RATIO POR TABLA (las peores primero)
-- ============================================================================
SELECT
    schemaname AS esquema,
    relname AS tabla,
    heap_blks_read AS bloques_leidos,
    heap_blks_hit AS bloques_cache,
    CASE WHEN heap_blks_hit + heap_blks_read > 0
        THEN ROUND(100.0 * heap_blks_hit / (heap_blks_hit + heap_blks_read), 2)
        ELSE 100
    END AS cache_hit_pct,
    n_live_tup AS filas_vivas,
    pg_size_pretty(pg_total_relation_size(quote_ident(schemaname) || '.' || quote_ident(relname))) AS tamaño
FROM pg_statio_user_tables
WHERE heap_blks_read > 100
ORDER BY cache_hit_pct ASC, heap_blks_read DESC
LIMIT 20


-- ████████████████████████████████████████████████████████████████████████████
-- SECCIÓN B: ACTIVIDAD EN TIEMPO REAL
-- ████████████████████████████████████████████████████████████████████████████

-- ============================================================================
-- B1. TODAS LAS SESIONES ACTIVAS CON DETALLE
-- Equivalente a un "top" de PostgreSQL
-- En PG 9.5 no existe backend_type; se filtra por pid <> pg_backend_pid()
-- ============================================================================
SELECT
    pid,
    usename AS usuario,
    application_name AS app,
    client_addr AS ip,
    datname AS base_datos,
    state AS estado,
    waiting AS esta_esperando,
    CASE
        WHEN state = 'active' THEN NOW() - query_start
        WHEN state = 'idle in transaction' THEN NOW() - state_change
        ELSE NULL
    END AS duracion,
    LEFT(query, 200) AS query_resumida
FROM pg_stat_activity
WHERE pid <> pg_backend_pid()
ORDER BY
    CASE state
        WHEN 'active' THEN 1
        WHEN 'idle in transaction' THEN 2
        WHEN 'idle' THEN 3
        ELSE 4
    END,
    query_start ASC


-- ============================================================================
-- B2. SESIONES AGRUPADAS POR ESTADO Y USUARIO
-- Resumen ejecutivo de quién está conectado y haciendo qué
-- ============================================================================
SELECT
    usename AS usuario,
    application_name AS app,
    state AS estado,
    COUNT(*) AS cantidad,
    STRING_AGG(DISTINCT client_addr::text, ', ') AS ips
FROM pg_stat_activity
WHERE pid <> pg_backend_pid()
GROUP BY usename, application_name, state
ORDER BY COUNT(*) DESC


-- ============================================================================
-- B3. SESIONES AGRUPADAS POR IP DE ORIGEN
-- Útil para detectar servidores de aplicación con demasiadas conexiones
-- ============================================================================
SELECT
    COALESCE(client_addr::text, 'local') AS ip_origen,
    COUNT(*) AS total_conexiones,
    COUNT(*) FILTER (WHERE state = 'active') AS activas,
    COUNT(*) FILTER (WHERE state = 'idle') AS idle,
    COUNT(*) FILTER (WHERE state = 'idle in transaction') AS idle_in_tx,
    STRING_AGG(DISTINCT usename, ', ') AS usuarios,
    STRING_AGG(DISTINCT application_name, ', ') FILTER (WHERE application_name <> '') AS apps
FROM pg_stat_activity
WHERE pid <> pg_backend_pid()
GROUP BY client_addr
ORDER BY total_conexiones DESC


-- ████████████████████████████████████████████████████████████████████████████
-- SECCIÓN C: TABLAS Y MANTENIMIENTO
-- ████████████████████████████████████████████████████████████████████████████

-- ============================================================================
-- C1. TABLAS QUE NECESITAN VACUUM URGENTE
-- Tablas con muchas filas muertas que necesitan limpieza
-- ============================================================================
SELECT
    schemaname AS esquema,
    relname AS tabla,
    n_live_tup AS filas_vivas,
    n_dead_tup AS filas_muertas,
    CASE WHEN n_live_tup > 0
        THEN ROUND(100.0 * n_dead_tup / n_live_tup, 2)
        ELSE 0
    END AS porcentaje_muertas,
    last_vacuum AS ultimo_vacuum,
    last_autovacuum AS ultimo_autovacuum,
    last_analyze AS ultimo_analyze,
    last_autoanalyze AS ultimo_autoanalyze,
    vacuum_count AS total_vacuums,
    autovacuum_count AS total_autovacuums,
    pg_size_pretty(pg_total_relation_size(quote_ident(schemaname) || '.' || quote_ident(relname))) AS tamaño
FROM pg_stat_user_tables
WHERE n_dead_tup > 1000
ORDER BY n_dead_tup DESC
LIMIT 25


-- ============================================================================
-- C2. VERIFICAR SI HAY VACUUM CORRIENDO
-- pg_stat_progress_vacuum no existe en PG 9.5, usamos pg_stat_activity
-- ============================================================================
SELECT
    pid,
    usename AS usuario,
    datname AS base_datos,
    state AS estado,
    NOW() - query_start AS duracion,
    LEFT(query, 200) AS query_resumido
FROM pg_stat_activity
WHERE query ILIKE '%vacuum%'
    AND state = 'active'
    AND pid <> pg_backend_pid()


-- ============================================================================
-- C3. TABLAS MÁS GRANDES CON ESTIMADO DE BLOAT (hinchazón)
-- Tablas que podrían necesitar VACUUM FULL
-- ============================================================================
SELECT
    schemaname AS esquema,
    relname AS tabla,
    n_live_tup AS filas_vivas,
    n_dead_tup AS filas_muertas,
    pg_size_pretty(pg_relation_size(quote_ident(schemaname) || '.' || quote_ident(relname))) AS tamaño_datos,
    pg_size_pretty(pg_total_relation_size(quote_ident(schemaname) || '.' || quote_ident(relname))
        - pg_relation_size(quote_ident(schemaname) || '.' || quote_ident(relname))) AS tamaño_indices,
    pg_size_pretty(pg_total_relation_size(quote_ident(schemaname) || '.' || quote_ident(relname))) AS tamaño_total,
    CASE WHEN n_live_tup > 0
        THEN ROUND(pg_relation_size(quote_ident(schemaname) || '.' || quote_ident(relname))::numeric / n_live_tup, 0)
        ELSE 0
    END AS bytes_por_fila
FROM pg_stat_user_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(quote_ident(schemaname) || '.' || quote_ident(relname)) DESC
LIMIT 25


-- ████████████████████████████████████████████████████████████████████████████
-- SECCIÓN D: WAL (XLOG en PG 9.5) Y REPLICACIÓN
-- ████████████████████████████████████████████████████████████████████████████

-- ============================================================================
-- D1. ESTADO DEL WAL (XLOG en PG 9.5)
-- En PG 9.5 las funciones se llaman pg_current_xlog_location(), etc.
-- ============================================================================
SELECT
    pg_current_xlog_location() AS posicion_xlog_actual,
    pg_xlogfile_name(pg_current_xlog_location()) AS archivo_xlog_actual,
    pg_size_pretty(pg_xlog_location_diff(pg_current_xlog_location(), '0/0')::bigint) AS xlog_total_escrito,
    (SELECT setting FROM pg_settings WHERE name = 'max_wal_size') AS max_wal_size_mb,
    (SELECT setting FROM pg_settings WHERE name = 'wal_level') AS nivel_wal,
    (SELECT setting FROM pg_settings WHERE name = 'archive_mode') AS modo_archivo


-- ============================================================================
-- D2. ESTADO DE REPLICACIÓN (si existe)
-- En PG 9.5: sent_location, write_location, flush_location, replay_location
-- No existen write_lag/flush_lag/replay_lag (PG 10+)
-- ============================================================================
SELECT
    client_addr AS ip_replica,
    application_name AS app,
    state AS estado,
    sync_state AS tipo_sync,
    sent_location,
    write_location,
    flush_location,
    replay_location,
    pg_size_pretty(pg_xlog_location_diff(sent_location, replay_location)::bigint) AS retraso_bytes
FROM pg_stat_replication


-- ████████████████████████████████████████████████████████████████████████████
-- SECCIÓN E: CHECKPOINT Y I/O
-- ████████████████████████████████████████████████████████████████████████████

-- ============================================================================
-- E1. ESTADÍSTICAS DE BGWRITER Y CHECKPOINTS
-- ============================================================================
SELECT
    checkpoints_timed AS checkpoints_programados,
    checkpoints_req AS checkpoints_forzados,
    ROUND(100.0 * checkpoints_req / GREATEST(checkpoints_timed + checkpoints_req, 1), 2) AS pct_checkpoints_forzados,
    checkpoint_write_time / 1000 AS tiempo_escritura_seg,
    checkpoint_sync_time / 1000 AS tiempo_sync_seg,
    buffers_checkpoint AS buffers_checkpoint,
    buffers_clean AS buffers_bgwriter,
    buffers_backend AS buffers_backend,
    ROUND(100.0 * buffers_backend / GREATEST(buffers_checkpoint + buffers_clean + buffers_backend, 1), 2) AS pct_buffers_backend,
    maxwritten_clean AS bgwriter_detenido_por_max,
    buffers_alloc AS buffers_asignados,
    stats_reset AS ultimo_reset
FROM pg_stat_bgwriter


-- ████████████████████████████████████████████████████████████████████████████
-- SECCIÓN F: MONITOREO DE TRANSACCIONES LARGAS (XID Wraparound)
-- ████████████████████████████████████████████████████████████████████████████

-- ============================================================================
-- F1. EDAD DE LAS TRANSACCIONES (Prevención de XID Wraparound)
-- ⚠️ Si age() se acerca a 2 mil millones, necesitas VACUUM FREEZE urgente
-- ============================================================================
SELECT
    c.oid::regclass AS tabla,
    age(c.relfrozenxid) AS edad_xid,
    pg_size_pretty(pg_total_relation_size(c.oid)) AS tamaño,
    ROUND(100.0 * age(c.relfrozenxid) / 2147483647, 4) AS pct_hacia_wraparound
FROM pg_class c
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE c.relkind = 'r'
    AND n.nspname NOT IN ('pg_catalog', 'information_schema')
ORDER BY age(c.relfrozenxid) DESC
LIMIT 20


-- ============================================================================
-- F2. EDAD DEL XID POR BASE DE DATOS
-- ============================================================================
SELECT
    datname AS base_datos,
    age(datfrozenxid) AS edad_xid,
    ROUND(100.0 * age(datfrozenxid) / 2147483647, 4) AS pct_hacia_wraparound,
    pg_size_pretty(pg_database_size(datname)) AS tamaño
FROM pg_database
WHERE datallowconn
ORDER BY age(datfrozenxid) DESC


-- ████████████████████████████████████████████████████████████████████████████
-- SECCIÓN G: FUNCIONES PL/pgSQL PARA MONITOREO CONTINUO
-- ████████████████████████████████████████████████████████████████████████████

-- ============================================================================
-- G1. FUNCIÓN: Snapshot de actividad (guardar estado periódicamente)
-- Ejecutar con: SELECT * FROM dba_snapshot_actividad();
-- ============================================================================
-- CREATE OR REPLACE FUNCTION dba_snapshot_actividad()
-- RETURNS TABLE (
--     momento TIMESTAMP,
--     total_conexiones INT,
--     activas INT,
--     idle INT,
--     idle_in_tx INT,
--     esperando_lock INT,
--     queries_lentas INT
-- ) AS $$
-- BEGIN
--     RETURN QUERY
--     SELECT
--         NOW()::TIMESTAMP,
--         (SELECT COUNT(*)::INT FROM pg_stat_activity),
--         (SELECT COUNT(*)::INT FROM pg_stat_activity WHERE state = 'active'),
--         (SELECT COUNT(*)::INT FROM pg_stat_activity WHERE state = 'idle'),
--         (SELECT COUNT(*)::INT FROM pg_stat_activity WHERE state = 'idle in transaction'),
--         (SELECT COUNT(*)::INT FROM pg_stat_activity WHERE waiting = TRUE),
--         (SELECT COUNT(*)::INT FROM pg_stat_activity WHERE state = 'active' AND NOW() - query_start > INTERVAL '1 minute');
-- END;
-- $$ LANGUAGE plpgsql;


-- ████████████████████████████████████████████████████████████████████████████
-- SECCIÓN H: ACCIONES DE EMERGENCIA DBA
-- ████████████████████████████████████████████████████████████████████████████

-- ============================================================================
-- H1. CANCELAR QUERIES LENTAS DE MÁS DE 30 MINUTOS
-- ⚠️ PRECAUCIÓN: Verificar antes de ejecutar
-- ============================================================================
-- SELECT pid, usename, NOW() - query_start AS duracion, LEFT(query, 100) AS query_resumida,
--        pg_cancel_backend(pid) AS cancelada
-- FROM pg_stat_activity
-- WHERE state = 'active'
--   AND NOW() - query_start > INTERVAL '30 minutes'
--   AND pid <> pg_backend_pid();


-- ============================================================================
-- H2. TERMINAR SESIONES IDLE IN TRANSACTION DE MÁS DE 1 HORA
-- ⚠️ PRECAUCIÓN: Desconecta al usuario
-- ============================================================================
-- SELECT pid, usename, NOW() - state_change AS tiempo_idle, LEFT(query, 100) AS ultima_query,
--        pg_terminate_backend(pid) AS terminada
-- FROM pg_stat_activity
-- WHERE state = 'idle in transaction'
--   AND NOW() - state_change > INTERVAL '1 hour'
--   AND pid <> pg_backend_pid();


-- ============================================================================
-- H3. TERMINAR TODAS LAS CONEXIONES DE UN USUARIO ESPECÍFICO
-- ⚠️ PRECAUCIÓN: Solo para emergencias
-- ============================================================================
-- SELECT pid, pg_terminate_backend(pid) AS terminada
-- FROM pg_stat_activity
-- WHERE usename = 'nombre_usuario_aqui'
--   AND pid <> pg_backend_pid();


-- ============================================================================
-- H4. VERIFICAR EXTENSIONES INSTALADAS
-- Útil para confirmar si pg_stat_statements está disponible
-- ============================================================================
SELECT
    extname AS extension,
    extversion AS version,
    n.nspname AS esquema
FROM pg_extension e
LEFT JOIN pg_namespace n ON e.extnamespace = n.oid
ORDER BY extname
