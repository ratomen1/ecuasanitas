-- ============================================
-- ANÁLISIS COMPLETO DE LA TABLA public.detalle
-- ============================================

-- 1. Información básica de la tabla
SELECT
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size('public.detalle')) AS tamaño_total,
    pg_size_pretty(pg_relation_size('public.detalle')) AS tamaño_tabla,
    pg_size_pretty(pg_total_relation_size('public.detalle') - pg_relation_size('public.detalle')) AS tamaño_indices
FROM pg_tables
WHERE schemaname = 'public' AND tablename = 'detalle';

-- 2. Número de registros
SELECT
    COUNT(*) AS total_registros,
    pg_size_pretty(pg_total_relation_size('public.detalle')) AS tamaño_total
FROM public.detalle;

-- 3. Información de columnas
SELECT
    column_name,
    data_type,
    character_maximum_length,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'detalle'
ORDER BY ordinal_position;

-- 4. Índices existentes
SELECT
    indexname,
    indexdef,
    pg_size_pretty(pg_relation_size(indexrelid)) AS tamaño_indice
FROM pg_indexes
JOIN pg_class ON pg_class.relname = indexname
WHERE schemaname = 'public'
  AND tablename = 'detalle';

-- 5. Estadísticas de uso de índices
SELECT
    schemaname,
    tablename,
    indexname,
    idx_scan AS veces_usado,
    idx_tup_read AS registros_leidos,
    idx_tup_fetch AS registros_obtenidos,
    pg_size_pretty(pg_relation_size(indexrelid)) AS tamaño
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
  AND tablename = 'detalle'
ORDER BY idx_scan DESC;

-- 6. Índices NO usados (candidatos a eliminar)
SELECT
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(pg_relation_size(indexrelid)) AS tamaño_desperdiciado
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
  AND tablename = 'detalle'
  AND idx_scan = 0
  AND indexname NOT LIKE '%pkey%';

-- 7. Análisis de bloating (hinchazón de tabla)
SELECT
    schemaname,
    tablename,
    pg_size_pretty(pg_relation_size(relid)) AS tamaño_actual,
    ROUND(100 * pg_relation_size(relid) / NULLIF(pg_total_relation_size(relid), 0), 2) AS porcentaje_tabla,
    n_dead_tup AS tuplas_muertas,
    n_live_tup AS tuplas_vivas,
    ROUND(100.0 * n_dead_tup / NULLIF(n_live_tup + n_dead_tup, 0), 2) AS porcentaje_bloat,
    last_vacuum,
    last_autovacuum,
    last_analyze,
    last_autoanalyze
FROM pg_stat_user_tables
WHERE schemaname = 'public'
  AND tablename = 'detalle';

-- 8. Consultas lentas relacionadas con la tabla detalle
SELECT
    query,
    calls AS veces_ejecutada,
    ROUND(total_exec_time::numeric, 2) AS tiempo_total_ms,
    ROUND(mean_exec_time::numeric, 2) AS tiempo_promedio_ms,
    ROUND(max_exec_time::numeric, 2) AS tiempo_maximo_ms,
    ROUND(stddev_exec_time::numeric, 2) AS desviacion_std_ms,
    rows AS filas_retornadas
FROM pg_stat_statements
WHERE query ILIKE '%detalle%'
  AND query NOT ILIKE '%pg_stat%'
ORDER BY mean_exec_time DESC
LIMIT 20;

-- 9. Verificar si necesita VACUUM
SELECT
    schemaname,
    tablename,
    n_live_tup AS tuplas_vivas,
    n_dead_tup AS tuplas_muertas,
    CASE
        WHEN n_live_tup > 0
        THEN ROUND(100.0 * n_dead_tup / n_live_tup, 2)
        ELSE 0
    END AS porcentaje_bloat,
    last_autovacuum,
    last_autoanalyze
FROM pg_stat_user_tables
WHERE schemaname = 'public'
  AND tablename = 'detalle';

-- 10. Columnas más consultadas (requiere habilitar track_io_timing)
SELECT
    attname AS columna,
    n_distinct AS valores_distintos,
    null_frac AS porcentaje_nulos,
    avg_width AS ancho_promedio_bytes,
    correlation AS correlacion
FROM pg_stats
WHERE schemaname = 'public'
  AND tablename = 'detalle'
ORDER BY n_distinct DESC;

