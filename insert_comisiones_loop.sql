-- insert_comisiones_loop.sql
-- Crea una tabla temporal (persistente en la BD) y recorre meses desde 2022-01-01 hasta 2025-09-01
-- Insertando el resultado agregado de la consulta original para cada fecha

-- Si prefieres una TEMP TABLE que solo exista en la sesión, cambia CREATE TABLE por CREATE TEMP TABLE.

DROP TABLE IF EXISTS public.temp_comisiones_mes;
CREATE TABLE public.temp_comisiones_mes (
  numero text,
  fechainicio date,
  total_valor numeric
);

DO $$
DECLARE
  d date := '2022-01-01';
  last_date date := '2025-09-01';
BEGIN
  WHILE d <= last_date LOOP
    INSERT INTO public.temp_comisiones_mes (numero, fechainicio, total_valor)
    SELECT
      con.numero,
      d as fechainicio,
      COALESCE(SUM(dc.valorcomision), 0) AS total_valor
    FROM comision c
      LEFT JOIN detallecomision dc ON dc.comision_id = c.id
      LEFT JOIN afiliacion a ON a.id = dc.afiliacion_id
      LEFT JOIN contrato con ON con.id = a.contrato_id
      LEFT JOIN asesorcomercial ac ON ac.id = c.asesorcomercial_id
    WHERE c.fechainicioproduccion = d
      AND dc.afiliacion_id IS NOT NULL
      AND c.claveclasecomision = 'COMISION'
      AND c.asesorcomercial_id > 0
      AND ac.codigo <> '0'
    GROUP BY con.numero;

    d := (d + INTERVAL '1 month')::date;
  END LOOP;
END
$$ LANGUAGE plpgsql;

-- Al finalizar, puedes consultar los resultados:
-- SELECT * FROM public.temp_comisiones_mes ORDER BY fechainicio, numero;

