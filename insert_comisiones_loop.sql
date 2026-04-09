-- insert_comisiones_loop.sql
-- Crea una tabla persistente en public y recorre meses desde 2022-01-01 hasta 2025-09-01
-- Insertando el resultado agregado de la consulta original para cada fecha

-- Si prefieres que la tabla exista solo en la sesión, cambia CREATE TABLE por CREATE TEMP TABLE.

DROP TABLE IF EXISTS public.temp_comisiones_mes_19;
CREATE TABLE public.temp_comisiones_mes_19 (
  numero text,
  fechainicio date,
  total_valor numeric
);

DO $$
DECLARE
  d date := '2022-01-01';
  last_date date := '2025-10-01';
BEGIN
  WHILE d <= last_date LOOP
    INSERT INTO public.temp_comisiones_mes_19 (numero, fechainicio, total_valor)
    SELECT
      con.numero,
      d as fechainicio,
      COALESCE(SUM(dc.valorcomision), 0) AS total_valor
    FROM comision c
      LEFT JOIN detallecomision dc ON dc.comision_id = c.id and c.estado = 'ACTIVA'
      LEFT JOIN afiliacion a ON a.id = dc.afiliacion_id
      LEFT JOIN contrato con ON con.id = a.contrato_id
      LEFT JOIN asesorcomercial ac ON ac.id = c.asesorcomercial_id
    -- Usar el cast a date por si fechainicioproduccion es timestamp
    WHERE c.fechainicioproduccion::date = d
      AND dc.afiliacion_id IS NOT NULL
      AND c.claveclasecomision = 'COMISION'
      and dc.descripcion ILIKE ANY (values('%COMISIÓN POR VENTAS PARA ASESOR COMERCIAL%'),
                                          ('%COMISION POR VENTAS PARA ASESOR COMERCIAL FREELANCE%'),
                                          ('%COMISION POR VENTAS PARA ASESOR COMERCIAL VIP%'),
                                          ('%COMISION POR VENTAS PARA COORDINADORES CORPORATIVOS%'),
                                          ('%COMISION CALL CENTER%'),
                                          ('%COMISION BALCON%'))
      and c.asesorcomercial_id > 0
      AND ac.codigo <> '0'
      and dc.valorcomision > 0
    GROUP BY con.numero;

    RAISE NOTICE 'Inserted for %', d;

    d := (d + INTERVAL '1 month')::date;
  END LOOP;
END
$$ LANGUAGE plpgsql;

-- Al finalizar (en cualquier sesión), puedes consultar los resultados:
-- SELECT * FROM public.temp_comisiones_mes_2021 ORDER BY fechainicio, numero;

-- Nota: la herramienta de análisis estático del entorno puede mostrar "Unable to resolve table '...'
-- porque no tiene conexión a la base de datos ni el catálogo de tablas; eso no indica un error de sintaxis.
