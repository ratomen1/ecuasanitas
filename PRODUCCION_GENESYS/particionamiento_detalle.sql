-- ============================================
-- PARTICIONAMIENTO DE LA TABLA DETALLE POR ID
-- ============================================
-- Este script particiona la tabla detalle por rangos de ID
-- para mejorar el rendimiento de las consultas

-- IMPORTANTE:
-- 1. Ejecutar en horario de bajo tráfico
-- 2. Hacer backup completo antes de ejecutar
-- 3. El proceso puede tomar varias horas dependiendo del tamaño de la tabla
-- 4. La tabla estará bloqueada durante parte del proceso

-- ============================================
-- PASO 1: ANÁLISIS PREVIO - Ver distribución de datos
-- ============================================

-- Ver el rango de IDs y calcular cuántas particiones necesitamos
SELECT
    MIN(id) AS id_minimo,
    MAX(id) AS id_maximo,
    COUNT(*) AS total_registros,
    MAX(id) - MIN(id) AS rango_ids,
    ROUND((MAX(id) - MIN(id))::numeric / 10000000, 2) AS particiones_sugeridas_10M
FROM public.detalle;

-- Ver distribución aproximada de registros por rango de 10 millones
SELECT
    FLOOR(id / 10000000) * 10000000 AS rango_inicio,
    COUNT(*) AS total_registros,
    MIN(id) AS id_min,
    MAX(id) AS id_max,
    pg_size_pretty(
        COUNT(*) *
        (SELECT avg(pg_column_size(d.*)) FROM public.detalle d LIMIT 1000)::bigint
    ) AS tamaño_estimado
FROM public.detalle
GROUP BY FLOOR(id / 10000000)
ORDER BY rango_inicio;

-- ============================================
-- PASO 2: CREAR LA TABLA PARTICIONADA
-- ============================================

-- Renombrar la tabla original
ALTER TABLE public.detalle RENAME TO detalle_old;

-- Renombrar índices existentes
DO $$
DECLARE
    idx record;
BEGIN
    FOR idx IN
        SELECT indexname
        FROM pg_indexes
        WHERE schemaname = 'public'
        AND tablename = 'detalle_old'
    LOOP
        EXECUTE format('ALTER INDEX IF EXISTS %I RENAME TO %I',
            idx.indexname,
            idx.indexname || '_old'
        );
    END LOOP;
END$$;

-- Crear la nueva tabla particionada
CREATE TABLE public.detalle (
    id bigint NOT NULL,
    cantidad numeric,
    descripcion character varying(255),
    especies integer,
    indice integer,
    total numeric,
    valor numeric,
    beneficiario_id bigint,
    deudor_id bigint,
    ordencobro_id bigint,
    padre_id bigint,
    servicio_id bigint,
    titular_id bigint,
    costo_id bigint,
    esdesglose boolean,
    afiliacion_id bigint,
    comisionista_id bigint,
    valorcomision numeric,
    titularcontrato_id bigint,
    titularfamilia_id bigint,
    descuento numeric,
    castigo numeric,
    cuotamensual_id bigint,
    descuentopromocional numeric,
    base numeric,
    porcentaje numeric,
    codigogrupo character varying(6),
    obligacion_id bigint,
    servicioreferenciado_id bigint,
    remplazarenclonar boolean,
    activo boolean,
    costoid bigint,
    preciocompra numeric,
    rangocostoid bigint,
    costo numeric,
    costoindividual numeric,
    usuarios integer,
    medico character varying(255),
    valor_old numeric,
    valordescontado numeric,
    descuentotarifa numeric,
    esdescuentotarifa boolean,
    itemdescuentoid bigint,
    refreembolso character varying(255),
    tipodescuento character varying(15),
    condpromocionwebid bigint
) PARTITION BY RANGE (id);

-- Copiar comentarios de la tabla
COMMENT ON TABLE public.detalle IS 'Tabla particionada por rangos de ID';

-- ============================================
-- PASO 3: CREAR PARTICIONES POR RANGOS DE ID
-- ============================================
-- AJUSTAR los rangos según el resultado del PASO 1
-- Aquí creo particiones de 10 millones de registros cada una

-- Partición 1: IDs 0 a 10 millones
CREATE TABLE public.detalle_p01 PARTITION OF public.detalle
    FOR VALUES FROM (MINVALUE) TO (10000000);

-- Partición 2: IDs 10M a 20M
CREATE TABLE public.detalle_p02 PARTITION OF public.detalle
    FOR VALUES FROM (10000000) TO (20000000);

-- Partición 3: IDs 20M a 30M
CREATE TABLE public.detalle_p03 PARTITION OF public.detalle
    FOR VALUES FROM (20000000) TO (30000000);

-- Partición 4: IDs 30M a 40M
CREATE TABLE public.detalle_p04 PARTITION OF public.detalle
    FOR VALUES FROM (30000000) TO (40000000);

-- Partición 5: IDs 40M a 50M
CREATE TABLE public.detalle_p05 PARTITION OF public.detalle
    FOR VALUES FROM (40000000) TO (50000000);

-- Partición 6: IDs 50M a 60M
CREATE TABLE public.detalle_p06 PARTITION OF public.detalle
    FOR VALUES FROM (50000000) TO (60000000);

-- Partición 7: IDs 60M a 70M
CREATE TABLE public.detalle_p07 PARTITION OF public.detalle
    FOR VALUES FROM (60000000) TO (70000000);

-- Partición 8: IDs 70M a 80M
CREATE TABLE public.detalle_p08 PARTITION OF public.detalle
    FOR VALUES FROM (70000000) TO (80000000);

-- Partición 9: IDs 80M a 90M
CREATE TABLE public.detalle_p09 PARTITION OF public.detalle
    FOR VALUES FROM (80000000) TO (90000000);

-- Partición 10: IDs 90M a 100M
CREATE TABLE public.detalle_p10 PARTITION OF public.detalle
    FOR VALUES FROM (90000000) TO (100000000);

-- Partición para IDs futuros (mayores a 100M)
CREATE TABLE public.detalle_p_future PARTITION OF public.detalle
    FOR VALUES FROM (100000000) TO (MAXVALUE);

-- ============================================
-- PASO 4: RECREAR ÍNDICES EN LA TABLA PARTICIONADA
-- ============================================

-- Índice en la clave primaria (se creará automáticamente en cada partición)
ALTER TABLE public.detalle ADD PRIMARY KEY (id);

-- Índices importantes basados en las columnas más usadas
CREATE INDEX idx_detalle_obligacion_id ON public.detalle(obligacion_id);
CREATE INDEX idx_detalle_afiliacion_id ON public.detalle(afiliacion_id);
CREATE INDEX idx_detalle_servicio_id ON public.detalle(servicio_id);
CREATE INDEX idx_detalle_ordencobro_id ON public.detalle(ordencobro_id);

-- Índice compuesto para consultas de detalles activos
CREATE INDEX idx_detalle_activo_afiliacion ON public.detalle(activo, afiliacion_id)
WHERE activo = TRUE;

-- Índice para coberturas con comisión
CREATE INDEX idx_detalle_codigogrupo_comision ON public.detalle(codigogrupo, valorcomision)
WHERE codigogrupo = 'COB' AND valorcomision > 0;

-- Índice para deudor
CREATE INDEX idx_detalle_deudor_id ON public.detalle(deudor_id)
WHERE deudor_id IS NOT NULL;

-- Índice para cuota mensual
CREATE INDEX idx_detalle_cuotamensual_id ON public.detalle(cuotamensual_id)
WHERE cuotamensual_id IS NOT NULL;

-- ============================================
-- PASO 5: MIGRAR DATOS (OPCIÓN A - Rápida pero bloquea)
-- ============================================

-- Insertar todos los datos de una vez
-- ⚠️ ADVERTENCIA: Esto bloqueará la tabla durante la inserción
BEGIN;
SET maintenance_work_mem = '2GB'; -- Aumentar memoria para la inserción
INSERT INTO public.detalle SELECT * FROM public.detalle_old;
COMMIT;

-- ============================================
-- PASO 5: MIGRAR DATOS (OPCIÓN B - Lenta pero no bloquea tanto)
-- ============================================
-- Migrar por lotes para evitar bloqueos largos
-- Descomentar y ajustar según tus rangos de ID

/*
-- Migrar partición 1
INSERT INTO public.detalle
SELECT * FROM public.detalle_old
WHERE id < 10000000;

-- Migrar partición 2
INSERT INTO public.detalle
SELECT * FROM public.detalle_old
WHERE id >= 10000000 AND id < 20000000;

-- Migrar partición 3
INSERT INTO public.detalle
SELECT * FROM public.detalle_old
WHERE id >= 20000000 AND id < 30000000;

-- Migrar partición 4
INSERT INTO public.detalle
SELECT * FROM public.detalle_old
WHERE id >= 30000000 AND id < 40000000;

-- Continuar con las demás particiones...
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
    MIN(id) AS id_min,
    MAX(id) AS id_max,
    pg_size_pretty(pg_relation_size(tableoid)) AS tamaño_tabla,
    pg_size_pretty(pg_total_relation_size(tableoid)) AS tamaño_total
FROM public.detalle
GROUP BY tableoid
ORDER BY particion;

-- Verificar integridad de datos clave
SELECT
    'detalle_old' AS tabla,
    COUNT(DISTINCT obligacion_id) AS obligaciones,
    COUNT(DISTINCT afiliacion_id) AS afiliaciones,
    SUM(total) AS suma_total
FROM public.detalle_old
UNION ALL
SELECT
    'detalle' AS tabla,
    COUNT(DISTINCT obligacion_id) AS obligaciones,
    COUNT(DISTINCT afiliacion_id) AS afiliaciones,
    SUM(total) AS suma_total
FROM public.detalle;

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
    AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
    AND ccu.table_schema = tc.table_schema
WHERE tc.table_schema = 'public'
  AND tc.table_name = 'detalle_old'
  AND tc.constraint_type = 'FOREIGN KEY';

-- Recrear las foreign keys (AJUSTAR según el resultado anterior)
-- Ejemplos comunes:
/*
ALTER TABLE public.detalle ADD CONSTRAINT fk_detalle_obligacion
    FOREIGN KEY (obligacion_id) REFERENCES public.obligacion(id);

ALTER TABLE public.detalle ADD CONSTRAINT fk_detalle_afiliacion
    FOREIGN KEY (afiliacion_id) REFERENCES public.afiliacion(id);

ALTER TABLE public.detalle ADD CONSTRAINT fk_detalle_servicio
    FOREIGN KEY (servicio_id) REFERENCES public.servicio(id);

ALTER TABLE public.detalle ADD CONSTRAINT fk_detalle_ordencobro
    FOREIGN KEY (ordencobro_id) REFERENCES public.ordencobro(id);
*/

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

-- Actualizar estadísticas de toda la tabla
VACUUM ANALYZE public.detalle;

-- Analizar cada partición individualmente
DO $$
DECLARE
    partition_name TEXT;
BEGIN
    FOR partition_name IN
        SELECT tablename
        FROM pg_tables
        WHERE schemaname = 'public'
        AND tablename LIKE 'detalle_p%'
    LOOP
        EXECUTE format('VACUUM ANALYZE public.%I', partition_name);
        RAISE NOTICE 'Analizando partición: %', partition_name;
    END LOOP;
END$$;

-- ============================================
-- PASO 10: PROBAR CONSULTAS
-- ============================================

-- Probar consulta típica
EXPLAIN ANALYZE
SELECT
    d.id,
    d.descripcion,
    d.total,
    d.valorcomision
FROM public.detalle d
WHERE d.obligacion_id = 123456
  AND d.activo = TRUE;

-- Ver qué particiones se usan en una consulta por ID
EXPLAIN (COSTS OFF, VERBOSE)
SELECT * FROM public.detalle
WHERE id BETWEEN 5000000 AND 5001000;

-- Comparar rendimiento entre tabla original y particionada
EXPLAIN (ANALYZE, BUFFERS)
SELECT COUNT(*)
FROM public.detalle_old
WHERE obligacion_id IN (SELECT id FROM obligacion LIMIT 100);

EXPLAIN (ANALYZE, BUFFERS)
SELECT COUNT(*)
FROM public.detalle
WHERE obligacion_id IN (SELECT id FROM obligacion LIMIT 100);

-- ============================================
-- PASO 11: SI TODO ESTÁ BIEN - ELIMINAR TABLA ORIGINAL
-- ============================================
-- ⚠️ ADVERTENCIA: Solo ejecutar después de verificar que todo funciona correctamente
-- ⚠️ ADVERTENCIA: Tener backup completo antes de ejecutar

-- Eliminar tabla antigua (comentado por seguridad)
-- DROP TABLE public.detalle_old CASCADE;

-- O renombrarla como backup con fecha
-- ALTER TABLE public.detalle_old RENAME TO detalle_backup_20251017;

-- ============================================
-- MANTENIMIENTO FUTURO
-- ============================================

-- Función para crear particiones automáticamente cuando se necesiten
CREATE OR REPLACE FUNCTION crear_particion_detalle_automatica()
RETURNS TRIGGER AS $$
DECLARE
    partition_name TEXT;
    start_id BIGINT;
    end_id BIGINT;
BEGIN
    -- Calcular el rango de la partición necesaria
    start_id := (NEW.id / 10000000) * 10000000;
    end_id := start_id + 10000000;
    partition_name := 'detalle_p' || LPAD((start_id / 10000000)::TEXT, 3, '0');

    -- Intentar crear la partición si no existe
    BEGIN
        EXECUTE format(
            'CREATE TABLE IF NOT EXISTS public.%I PARTITION OF public.detalle
             FOR VALUES FROM (%s) TO (%s)',
            partition_name, start_id, end_id
        );
        RAISE NOTICE 'Partición % creada para ID %', partition_name, NEW.id;
    EXCEPTION WHEN duplicate_table THEN
        -- La partición ya existe, continuar
        NULL;
    END;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Nota: En PostgreSQL no se puede usar BEFORE INSERT trigger en tablas particionadas
-- para crear particiones automáticamente. Las particiones deben existir antes.
-- Esta función es de referencia para crear particiones manualmente.

-- Script para crear nuevas particiones manualmente
-- Ejecutar cuando el ID se acerque al límite de la última partición
/*
CREATE TABLE public.detalle_p11 PARTITION OF public.detalle
    FOR VALUES FROM (100000000) TO (110000000);

CREATE TABLE public.detalle_p12 PARTITION OF public.detalle
    FOR VALUES FROM (110000000) TO (120000000);
*/
