-- ============================================
-- PARTICIONAMIENTO DE LA TABLA DETALLE
-- ============================================
-- Este script particiona la tabla detalle por fechapagocomision
-- para mejorar el rendimiento de las consultas

-- IMPORTANTE:
-- 1. Ejecutar en horario de bajo tráfico
-- 2. Hacer backup completo antes de ejecutar
-- 3. El proceso puede tomar varias horas dependiendo del tamaño de la tabla
-- 4. La tabla estará bloqueada durante parte del proceso

-- ============================================
-- PASO 1: ANÁLISIS PREVIO - Ver distribución de datos
-- ============================================

-- Ver cuántos registros hay por año en fechapagocomision
SELECT
    DATE_TRUNC('year', d.fechapagocomision) AS año,
    COUNT(*) AS total_registros,
    pg_size_pretty(COUNT(*) *
        (SELECT avg_width FROM pg_stats
         WHERE schemaname = 'public'
         AND tablename = 'detalle'
         LIMIT 1)::bigint) AS tamaño_estimado
FROM public.detalle d
WHERE d.fechapagocomision IS NOT NULL
GROUP BY DATE_TRUNC('year', d.fechapagocomision)
ORDER BY año DESC;

-- Ver rango de fechas
SELECT
    MIN(fechapagocomision) AS fecha_minima,
    MAX(fechapagocomision) AS fecha_maxima,
    COUNT(*) AS total_registros,
    COUNT(*) FILTER (WHERE fechapagocomision IS NULL) AS registros_sin_fecha
FROM public.detalle;

-- ============================================
-- PASO 2: CREAR LA TABLA PARTICIONADA
-- ============================================

-- Renombrar la tabla original
ALTER TABLE public.detalle RENAME TO detalle_old;

-- Renombrar la clave primaria
ALTER INDEX IF EXISTS detalle_pkey RENAME TO detalle_old_pkey;

-- Crear la nueva tabla particionada
CREATE TABLE public.detalle (
    LIKE public.detalle_old INCLUDING DEFAULTS INCLUDING CONSTRAINTS
) PARTITION BY RANGE (fechapagocomision);

-- Copiar comentarios de la tabla
COMMENT ON TABLE public.detalle IS 'Tabla particionada por fechapagocomision';

-- ============================================
-- PASO 3: CREAR PARTICIONES
-- ============================================

-- Partición para fechas NULL (importante!)
CREATE TABLE public.detalle_null PARTITION OF public.detalle
    FOR VALUES FROM (MINVALUE) TO ('2020-01-01');

-- Particiones por año desde 2020
CREATE TABLE public.detalle_2020 PARTITION OF public.detalle
    FOR VALUES FROM ('2020-01-01') TO ('2021-01-01');

CREATE TABLE public.detalle_2021 PARTITION OF public.detalle
    FOR VALUES FROM ('2021-01-01') TO ('2022-01-01');

CREATE TABLE public.detalle_2022 PARTITION OF public.detalle
    FOR VALUES FROM ('2022-01-01') TO ('2023-01-01');

CREATE TABLE public.detalle_2023 PARTITION OF public.detalle
    FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');

CREATE TABLE public.detalle_2024 PARTITION OF public.detalle
    FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

CREATE TABLE public.detalle_2025 PARTITION OF public.detalle
    FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');

-- Partición para fechas futuras
CREATE TABLE public.detalle_2026 PARTITION OF public.detalle
    FOR VALUES FROM ('2026-01-01') TO ('2027-01-01');

CREATE TABLE public.detalle_future PARTITION OF public.detalle
    FOR VALUES FROM ('2027-01-01') TO (MAXVALUE);

-- ============================================
-- PASO 4: RECREAR ÍNDICES EN LA TABLA PARTICIONADA
-- ============================================

-- Índice en la clave primaria (se creará automáticamente en cada partición)
ALTER TABLE public.detalle ADD PRIMARY KEY (id);

-- Índices importantes basados en tu consulta
CREATE INDEX idx_detalle_obligacion_id ON public.detalle(obligacion_id);
CREATE INDEX idx_detalle_afiliacion_id ON public.detalle(afiliacion_id);
CREATE INDEX idx_detalle_servicio_id ON public.detalle(servicio_id);

-- Índice en la columna de partición (fechapagocomision)
CREATE INDEX idx_detalle_fechapagocomision ON public.detalle(fechapagocomision);

-- Índice compuesto para la consulta común
CREATE INDEX idx_detalle_activo_afiliacion ON public.detalle(activo, afiliacion_id)
WHERE activo = TRUE;

-- Índice para coberturaSinComision
CREATE INDEX idx_detalle_codigogrupo ON public.detalle(codigogrupo, valorcomision)
WHERE codigogrupo = 'COB' AND valorcomision > 0;

-- ============================================
-- PASO 5: MIGRAR DATOS (OPCIÓN A - Rápida pero bloquea)
-- ============================================

-- Insertar todos los datos de una vez
-- ⚠️ ADVERTENCIA: Esto bloqueará la tabla durante la inserción
BEGIN;
INSERT INTO public.detalle SELECT * FROM public.detalle_old;
COMMIT;

-- ============================================
-- PASO 5: MIGRAR DATOS (OPCIÓN B - Lenta pero no bloquea tanto)
-- ============================================
-- Migrar por lotes para evitar bloqueos largos

/*
-- Migrar datos NULL primero
INSERT INTO public.detalle
SELECT * FROM public.detalle_old
WHERE fechapagocomision IS NULL OR fechapagocomision < '2020-01-01';

-- Migrar por año
INSERT INTO public.detalle
SELECT * FROM public.detalle_old
WHERE fechapagocomision >= '2020-01-01' AND fechapagocomision < '2021-01-01';

INSERT INTO public.detalle
SELECT * FROM public.detalle_old
WHERE fechapagocomision >= '2021-01-01' AND fechapagocomision < '2022-01-01';

INSERT INTO public.detalle
SELECT * FROM public.detalle_old
WHERE fechapagocomision >= '2022-01-01' AND fechapagocomision < '2023-01-01';

INSERT INTO public.detalle
SELECT * FROM public.detalle_old
WHERE fechapagocomision >= '2023-01-01' AND fechapagocomision < '2024-01-01';

INSERT INTO public.detalle
SELECT * FROM public.detalle_old
WHERE fechapagocomision >= '2024-01-01' AND fechapagocomision < '2025-01-01';

INSERT INTO public.detalle
SELECT * FROM public.detalle_old
WHERE fechapagocomision >= '2025-01-01' AND fechapagocomision < '2026-01-01';

INSERT INTO public.detalle
SELECT * FROM public.detalle_old
WHERE fechapagocomision >= '2026-01-01';
*/

-- ============================================
-- PASO 6: VERIFICAR LA MIGRACIÓN
-- ============================================

-- Comparar totales
SELECT 'Tabla original' AS tabla, COUNT(*) AS total FROM public.detalle_old
UNION ALL
SELECT 'Tabla particionada' AS tabla, COUNT(*) AS total FROM public.detalle;

-- Ver distribución por partición
SELECT
    tableoid::regclass AS particion,
    COUNT(*) AS registros,
    MIN(fechapagocomision) AS fecha_min,
    MAX(fechapagocomision) AS fecha_max,
    pg_size_pretty(pg_relation_size(tableoid)) AS tamaño
FROM public.detalle
GROUP BY tableoid
ORDER BY particion;

-- ============================================
-- PASO 7: RECREAR FOREIGN KEYS Y CONSTRAINTS
-- ============================================

-- Listar las foreign keys de la tabla original
SELECT
    tc.constraint_name,
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.table_name = 'detalle_old'
  AND tc.constraint_type = 'FOREIGN KEY';

-- Recrear las foreign keys (AJUSTAR según el resultado anterior)
-- Ejemplo:
-- ALTER TABLE public.detalle ADD CONSTRAINT fk_detalle_obligacion
--     FOREIGN KEY (obligacion_id) REFERENCES public.obligacion(id);
-- ALTER TABLE public.detalle ADD CONSTRAINT fk_detalle_afiliacion
--     FOREIGN KEY (afiliacion_id) REFERENCES public.afiliacion(id);

-- ============================================
-- PASO 8: ACTUALIZAR PERMISOS
-- ============================================

-- Copiar permisos de la tabla original
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT grantee, privilege_type
        FROM information_schema.role_table_grants
        WHERE table_schema = 'public' AND table_name = 'detalle_old'
    LOOP
        EXECUTE format('GRANT %s ON public.detalle TO %s',
                      r.privilege_type, r.grantee);
    END LOOP;
END$$;

-- ============================================
-- PASO 9: VACUUM Y ANALYZE
-- ============================================

-- Actualizar estadísticas
VACUUM ANALYZE public.detalle;

-- Analizar cada partición
VACUUM ANALYZE public.detalle_null;
VACUUM ANALYZE public.detalle_2020;
VACUUM ANALYZE public.detalle_2021;
VACUUM ANALYZE public.detalle_2022;
VACUUM ANALYZE public.detalle_2023;
VACUUM ANALYZE public.detalle_2024;
VACUUM ANALYZE public.detalle_2025;
VACUUM ANALYZE public.detalle_2026;
VACUUM ANALYZE public.detalle_future;

-- ============================================
-- PASO 10: PROBAR CONSULTAS
-- ============================================

-- Probar que las consultas funcionan igual
EXPLAIN ANALYZE
SELECT
    COUNT(*)
FROM public.detalle d
JOIN obligacion o ON o.id = d.obligacion_id
WHERE o.fechapagocomision = '2025-10-01'
  AND d.afiliacion_id IS NOT NULL
  AND d.activo = TRUE;

-- Ver qué particiones se están usando
EXPLAIN (COSTS OFF, VERBOSE)
SELECT * FROM public.detalle
WHERE fechapagocomision = '2025-10-01';

-- ============================================
-- PASO 11: SI TODO ESTÁ BIEN - ELIMINAR TABLA ORIGINAL
-- ============================================
-- ⚠️ ADVERTENCIA: Solo ejecutar después de verificar que todo funciona correctamente
-- ⚠️ ADVERTENCIA: Tener backup completo antes de ejecutar

-- Eliminar tabla antigua (comentado por seguridad)
-- DROP TABLE public.detalle_old CASCADE;

-- O renombrarla como backup
-- ALTER TABLE public.detalle_old RENAME TO detalle_backup_20250317;

-- ============================================
-- MANTENIMIENTO FUTURO
-- ============================================

-- Crear particiones nuevas cada año
-- Ejemplo para crear partición de 2027:
/*
CREATE TABLE public.detalle_2027 PARTITION OF public.detalle
    FOR VALUES FROM ('2027-01-01') TO ('2028-01-01');
*/

-- Script para crear automáticamente la partición del próximo año
CREATE OR REPLACE FUNCTION crear_particion_detalle_proximo_año()
RETURNS void AS $$
DECLARE
    año_actual INT;
    año_siguiente INT;
    nombre_particion TEXT;
BEGIN
    año_actual := EXTRACT(YEAR FROM CURRENT_DATE);
    año_siguiente := año_actual + 1;
    nombre_particion := 'detalle_' || año_siguiente;

    -- Verificar si la partición ya existe
    IF NOT EXISTS (
        SELECT 1 FROM pg_class
        WHERE relname = nombre_particion
    ) THEN
        EXECUTE format(
            'CREATE TABLE public.%I PARTITION OF public.detalle
             FOR VALUES FROM (%L) TO (%L)',
            nombre_particion,
            año_siguiente || '-01-01',
            (año_siguiente + 1) || '-01-01'
        );

        RAISE NOTICE 'Partición % creada exitosamente', nombre_particion;
    ELSE
        RAISE NOTICE 'La partición % ya existe', nombre_particion;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Ejecutar la función para crear la partición del próximo año
-- SELECT crear_particion_detalle_proximo_año();

