-- ============================================================================
-- MONITOREO DE BLOQUEOS — PostgreSQL 9.5 DBA Toolkit
-- Base de datos: genesys (Ecuasanitas)
-- Autor: DBA Monitor Agent
-- Fecha: 2026-04-09
-- Compatibilidad: PostgreSQL 9.5+
-- Descripción: Scripts para detectar y resolver bloqueos en la base de datos
-- ============================================================================

-- ============================================================================
-- 1. BLOQUEOS ACTIVOS: ¿Quién bloquea a quién?
-- Muestra la cadena completa de bloqueos: proceso bloqueador → proceso bloqueado
-- ============================================================================
SELECT
    bloqueador.pid AS pid_bloqueador,
    bloqueador.usename AS usuario_bloqueador,
    bloqueador.application_name AS app_bloqueador,
    bloqueador.client_addr AS ip_bloqueador,
    bloqueador.state AS estado_bloqueador,
    bloqueador.query AS query_bloqueador,
    bloqueador.query_start AS inicio_query_bloqueador,
    NOW() - bloqueador.query_start AS duracion_bloqueador,
    bloqueado.pid AS pid_bloqueado,
    bloqueado.usename AS usuario_bloqueado,
    bloqueado.application_name AS app_bloqueado,
    bloqueado.client_addr AS ip_bloqueado,
    bloqueado.query AS query_bloqueado,
    bloqueado.query_start AS inicio_query_bloqueado,
    NOW() - bloqueado.query_start AS duracion_esperando,
    bloqueado.waiting AS esta_esperando
FROM pg_locks l_bloqueado
JOIN pg_stat_activity bloqueado ON bloqueado.pid = l_bloqueado.pid
JOIN pg_locks l_bloqueador ON l_bloqueador.locktype = l_bloqueado.locktype
    AND l_bloqueador.database IS NOT DISTINCT FROM l_bloqueado.database
    AND l_bloqueador.relation IS NOT DISTINCT FROM l_bloqueado.relation
    AND l_bloqueador.page IS NOT DISTINCT FROM l_bloqueado.page
    AND l_bloqueador.tuple IS NOT DISTINCT FROM l_bloqueado.tuple
    AND l_bloqueador.virtualxid IS NOT DISTINCT FROM l_bloqueado.virtualxid
    AND l_bloqueador.transactionid IS NOT DISTINCT FROM l_bloqueado.transactionid
    AND l_bloqueador.classid IS NOT DISTINCT FROM l_bloqueado.classid
    AND l_bloqueador.objid IS NOT DISTINCT FROM l_bloqueado.objid
    AND l_bloqueador.objsubid IS NOT DISTINCT FROM l_bloqueado.objsubid
    AND l_bloqueador.pid <> l_bloqueado.pid
JOIN pg_stat_activity bloqueador ON bloqueador.pid = l_bloqueador.pid
WHERE NOT l_bloqueado.granted
    AND l_bloqueador.granted
ORDER BY duracion_esperando DESC


-- ============================================================================
-- 2. ÁRBOL RECURSIVO DE BLOQUEOS
-- Muestra la jerarquía completa de bloqueos en forma de árbol
-- Útil cuando hay cadenas de bloqueos (A bloquea a B, B bloquea a C, etc.)
-- ============================================================================
WITH RECURSIVE bloqueos AS (
    -- Nivel raíz: procesos que bloquean pero no están bloqueados
    SELECT
        bloqueador.pid,
        bloqueador.usename,
        bloqueador.query,
        bloqueador.state,
        bloqueador.client_addr,
        bloqueador.application_name,
        bloqueador.query_start,
        0 AS nivel,
        ARRAY[bloqueador.pid] AS cadena,
        bloqueador.pid AS raiz_pid
    FROM pg_locks l_bloqueado
    JOIN pg_stat_activity bloqueado ON bloqueado.pid = l_bloqueado.pid
    JOIN pg_locks l_bloqueador ON l_bloqueador.locktype = l_bloqueado.locktype
        AND l_bloqueador.database IS NOT DISTINCT FROM l_bloqueado.database
        AND l_bloqueador.relation IS NOT DISTINCT FROM l_bloqueado.relation
        AND l_bloqueador.page IS NOT DISTINCT FROM l_bloqueado.page
        AND l_bloqueador.tuple IS NOT DISTINCT FROM l_bloqueado.tuple
        AND l_bloqueador.virtualxid IS NOT DISTINCT FROM l_bloqueado.virtualxid
        AND l_bloqueador.transactionid IS NOT DISTINCT FROM l_bloqueado.transactionid
        AND l_bloqueador.pid <> l_bloqueado.pid
    JOIN pg_stat_activity bloqueador ON bloqueador.pid = l_bloqueador.pid
    WHERE NOT l_bloqueado.granted AND l_bloqueador.granted
    -- Solo raíces: procesos que bloquean pero no esperan por nadie
    AND bloqueador.pid NOT IN (
        SELECT l2.pid FROM pg_locks l2 WHERE NOT l2.granted
    )

    UNION ALL

    -- Nivel recursivo: procesos bloqueados por los anteriores
    SELECT
        bloqueado_act.pid,
        bloqueado_act.usename,
        bloqueado_act.query,
        bloqueado_act.state,
        bloqueado_act.client_addr,
        bloqueado_act.application_name,
        bloqueado_act.query_start,
        b.nivel + 1,
        b.cadena || bloqueado_act.pid,
        b.raiz_pid
    FROM bloqueos b
    JOIN pg_locks l_bloqueador ON l_bloqueador.pid = b.pid AND l_bloqueador.granted
    JOIN pg_locks l_bloqueado ON l_bloqueado.locktype = l_bloqueador.locktype
        AND l_bloqueado.database IS NOT DISTINCT FROM l_bloqueador.database
        AND l_bloqueado.relation IS NOT DISTINCT FROM l_bloqueador.relation
        AND l_bloqueado.page IS NOT DISTINCT FROM l_bloqueador.page
        AND l_bloqueado.tuple IS NOT DISTINCT FROM l_bloqueador.tuple
        AND l_bloqueado.virtualxid IS NOT DISTINCT FROM l_bloqueador.virtualxid
        AND l_bloqueado.transactionid IS NOT DISTINCT FROM l_bloqueador.transactionid
        AND l_bloqueado.pid <> l_bloqueador.pid
        AND NOT l_bloqueado.granted
    JOIN pg_stat_activity bloqueado_act ON bloqueado_act.pid = l_bloqueado.pid
    WHERE NOT (bloqueado_act.pid = ANY(b.cadena)) -- evitar ciclos
)
SELECT
    REPEAT('  ', nivel) || '→ PID ' || pid AS arbol,
    pid,
    usename AS usuario,
    application_name AS app,
    client_addr AS ip,
    state AS estado,
    NOW() - query_start AS duracion,
    LEFT(query, 120) AS query_resumido,
    nivel,
    raiz_pid
FROM bloqueos
ORDER BY raiz_pid, nivel, pid


-- ============================================================================
-- 3. SESIONES ESPERANDO POR LOCKS (vista rápida)
-- En PG 9.5 se usa la columna "waiting" (boolean) en lugar de wait_event_type
-- ============================================================================
SELECT
    pid,
    usename AS usuario,
    application_name AS app,
    client_addr AS ip,
    datname AS base_datos,
    waiting AS esta_esperando,
    state AS estado,
    NOW() - query_start AS duracion_query,
    NOW() - state_change AS tiempo_en_estado,
    LEFT(query, 200) AS query_resumido
FROM pg_stat_activity
WHERE waiting = TRUE
ORDER BY query_start ASC


-- ============================================================================
-- 4. SESIONES "IDLE IN TRANSACTION" (potencialmente peligrosas)
-- Estas sesiones mantienen locks abiertos sin ejecutar nada
-- ============================================================================
SELECT
    pid,
    usename AS usuario,
    application_name AS app,
    client_addr AS ip,
    datname AS base_datos,
    state AS estado,
    NOW() - state_change AS tiempo_idle,
    NOW() - xact_start AS duracion_transaccion,
    LEFT(query, 200) AS ultima_query,
    backend_xid,
    backend_xmin
FROM pg_stat_activity
WHERE state = 'idle in transaction'
ORDER BY xact_start ASC


-- ============================================================================
-- 5. DETALLE COMPLETO DE LOCKS POR TABLA
-- Muestra qué locks están activos sobre cada tabla y quién los tiene
-- ============================================================================
SELECT
    l.locktype AS tipo_lock,
    d.datname AS base_datos,
    COALESCE(c.relname, 'N/A') AS tabla,
    n.nspname AS esquema,
    l.mode AS modo_lock,
    l.granted AS concedido,
    l.pid,
    a.usename AS usuario,
    a.application_name AS app,
    a.client_addr AS ip,
    a.state AS estado_sesion,
    NOW() - a.query_start AS duracion_query,
    LEFT(a.query, 150) AS query_resumido
FROM pg_locks l
LEFT JOIN pg_class c ON l.relation = c.oid
LEFT JOIN pg_namespace n ON c.relnamespace = n.oid
LEFT JOIN pg_database d ON l.database = d.oid
JOIN pg_stat_activity a ON l.pid = a.pid
WHERE l.locktype IN ('relation', 'tuple', 'transactionid')
    AND d.datname = current_database()
ORDER BY NOT l.granted, c.relname, l.mode


-- ============================================================================
-- 6. RESUMEN DE LOCKS AGRUPADOS POR TABLA
-- Vista ejecutiva: ¿cuántos locks hay por tabla?
-- ============================================================================
SELECT
    COALESCE(c.relname, 'otros') AS tabla,
    l.mode AS modo_lock,
    COUNT(*) AS cantidad,
    COUNT(*) FILTER (WHERE l.granted) AS concedidos,
    COUNT(*) FILTER (WHERE NOT l.granted) AS esperando,
    STRING_AGG(DISTINCT a.usename, ', ') AS usuarios
FROM pg_locks l
LEFT JOIN pg_class c ON l.relation = c.oid
JOIN pg_stat_activity a ON l.pid = a.pid
WHERE l.database = (SELECT oid FROM pg_database WHERE datname = current_database())
GROUP BY c.relname, l.mode
HAVING COUNT(*) FILTER (WHERE NOT l.granted) > 0
ORDER BY COUNT(*) FILTER (WHERE NOT l.granted) DESC


-- ============================================================================
-- 7. DEADLOCKS RECIENTES (del log de PostgreSQL)
-- ============================================================================
SELECT
    datname AS base_datos,
    deadlocks,
    conflicts,
    blk_read_time,
    blk_write_time
FROM pg_stat_database
WHERE datname = current_database()


-- ============================================================================
-- 8. COMANDO PARA CANCELAR UNA SESIÓN BLOQUEADORA
-- ⚠️ PRECAUCIÓN: Solo ejecutar después de verificar que el PID es correcto
-- ============================================================================

-- Opción suave: cancela la query actual (la sesión sobrevive)
-- SELECT pg_cancel_backend(<PID_BLOQUEADOR>);

-- Opción fuerte: termina la sesión completa (desconecta al usuario)
-- SELECT pg_terminate_backend(<PID_BLOQUEADOR>);

-- Cancelar TODAS las sesiones idle in transaction de más de 30 minutos
-- SELECT pg_terminate_backend(pid)
-- FROM pg_stat_activity
-- WHERE state = 'idle in transaction'
--   AND NOW() - state_change > INTERVAL '30 minutes'
--   AND pid <> pg_backend_pid();


-- ============================================================================
-- 9. CONTEO RÁPIDO DE BLOQUEOS Y SESIONES PROBLEMÁTICAS
-- Dashboard rápido para el DBA
-- ============================================================================
SELECT
    (SELECT COUNT(*) FROM pg_stat_activity WHERE waiting = TRUE) AS sesiones_esperando_lock,
    (SELECT COUNT(*) FROM pg_stat_activity WHERE state = 'idle in transaction') AS sesiones_idle_in_tx,
    (SELECT COUNT(*) FROM pg_stat_activity WHERE state = 'idle in transaction' AND NOW() - state_change > INTERVAL '5 minutes') AS idle_in_tx_mas_5min,
    (SELECT COUNT(*) FROM pg_stat_activity WHERE state = 'active') AS sesiones_activas,
    (SELECT COUNT(*) FROM pg_stat_activity) AS total_conexiones,
    (SELECT setting::int FROM pg_settings WHERE name = 'max_connections') AS max_conexiones,
    (SELECT deadlocks FROM pg_stat_database WHERE datname = current_database()) AS deadlocks_totales
