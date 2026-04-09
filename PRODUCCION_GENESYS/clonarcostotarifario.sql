/**
                 * Clona un costo tarifario con sus rangos asociados, aplicando un incremento porcentual
                 * a los valores. La función crea un nuevo registro de costo vigente a partir de la fecha
                 * especificada, mientras actualiza la fecha de fin de vigencia del registro original.
                 *
                 * @param codigos - Código del tarifario a modificar
                 * @param fechahasta - Fecha hasta la cual será vigente el costo original (formato 'yyyy-MM-dd')
                 * @param incremento - Valor decimal que representa el incremento a aplicar (ej: 3)
                 * @return boolean - TRUE si la operación se completó exitosamente
                 */
CREATE or REPLACE FUNCTION clonarcostotarifario(codigos character, fechahasta character, incremento numeric) RETURNS boolean
    LANGUAGE plpgsql
AS
$$
DECLARE
    v_tarifario_id      int8;
    costo_id_origen   int8;
    costo_id_nuevo    int8;
    rango_id_nuevo    int8;
    costogenero_id    int8;
    cursor_rangos     REFCURSOR;
    r_rango           rangocosto%ROWTYPE;
    fecha_hasta_date  date;
    fecha_desde_nueva date;
    genero_letra      char;
BEGIN
    fecha_hasta_date := TO_DATE(fechaHasta, 'yyyy-MM-dd');
    fecha_desde_nueva := fecha_hasta_date + INTERVAL '1 day';

    SELECT id INTO  v_tarifario_id FROM tarifario WHERE codigo = codigos;

    -- Corregido usando alias de tabla "c" para evitar ambigüedad
    SELECT id INTO costo_id_origen FROM costo c
    WHERE c.tarifario_id =  v_tarifario_id AND c.hasta IS NULL AND c.servicio_id = 54;

    SELECT valor INTO costo_id_nuevo FROM generador WHERE nombre = 'Costo';
    SELECT valor INTO rango_id_nuevo FROM generador WHERE nombre = 'RangoCosto';
    SELECT valor INTO costogenero_id FROM generador WHERE nombre = 'CostoGenero';

    -- 1. Crear nuevo registro de costo
                    INSERT INTO public.costo
                    (id, desde, detallegenerorango, hasta, numeroespecies, preciocompra,
                     regla, valor, criteriorango_id, establecimiento_id, sede_id, servicio_id,
                     tarifario_id, tipo_id, creacion, fechaoperaciondesde, fechaoperacionhasta,
                     observacion, retroactivo, activo, descripcionregla, tipocosto)
                    SELECT
                        costo_id_nuevo, fecha_desde_nueva, detallegenerorango, NULL, -- El nuevo costo tiene fecha inicio = día siguiente y hasta = NULL (vigente)
                        numeroespecies, preciocompra, regla, valor, criteriorango_id,
                        establecimiento_id, sede_id, servicio_id, tarifario_id, tipo_id,
                        creacion, fechaoperaciondesde, fechaoperacionhasta, observacion,
                        retroactivo, activo, descripcionregla, tipocosto
                    FROM public.costo WHERE id = costo_id_origen; -- Copia todos los datos del costo original al nuevo

                    -- 2. Actualizar fecha hasta del registro original
                    UPDATE costo SET hasta = fecha_hasta_date WHERE id = costo_id_origen; -- Establece la fecha límite para el costo original

                    -- 3. Actualizar generador de costos
                    UPDATE generador SET valor = costo_id_nuevo + 1 WHERE nombre = 'Costo'; -- Incrementa el contador de IDs para costos

                    -- 4. Clonar rangos de costo y sus géneros
                    OPEN cursor_rangos FOR SELECT * FROM rangocosto WHERE costo_id = costo_id_origen; -- Abre un cursor para recorrer todos los rangos del costo original
                    FETCH cursor_rangos INTO r_rango; -- Obtiene el primer rango

                    WHILE FOUND LOOP -- Mientras haya rangos por procesar
                        -- Crear nuevo rango
                        INSERT INTO public.rangocosto
                        (id, desde, genero, hasta, valor, costo_id, unidadtiempodesde_id, unidadtiempohasta_id)
                        VALUES (
                               rango_id_nuevo, r_rango.desde, r_rango.genero, r_rango.hasta, r_rango.valor,
                               costo_id_nuevo, r_rango.unidadtiempodesde_id, r_rango.unidadtiempohasta_id
                           ); -- Crea un nuevo registro de rango asociado al nuevo costo

                        -- Clonar registros de género con incremento (M y F)
                        FOREACH genero_letra IN ARRAY ARRAY['M', 'F'] LOOP -- Itera sobre los géneros Masculino y Femenino
                            INSERT INTO public.costogenero
                            (id, genero, preciocompra, valor, rangocosto_id, valor_con_descuento)
                            SELECT
                                costogenero_id, genero, preciocompra,
                                CASE
                                    WHEN valor_con_descuento IS NULL THEN valor + incremento
                                    ELSE valor
                                END,
                                rango_id_nuevo,
                                CASE
                                    WHEN valor_con_descuento IS NOT NULL THEN valor_con_descuento + incremento
                                    ELSE NULL
                                END
                            FROM public.costogenero
                            WHERE rangocosto_id = r_rango.id AND genero = genero_letra; -- Obtiene datos del género correspondiente en el rango original

                            costogenero_id := costogenero_id + 1; -- Incrementa el contador de ID para costogenero
                        END LOOP;

                        rango_id_nuevo := rango_id_nuevo + 1; -- Incrementa el contador de ID para rangos
                        FETCH cursor_rangos INTO r_rango; -- Obtiene el siguiente rango
                    END LOOP;
                    CLOSE cursor_rangos; -- Cierra el cursor de rangos

                    -- 5. Actualizar generadores
                    UPDATE generador SET valor = rango_id_nuevo WHERE nombre = 'RangoCosto'; -- Actualiza el contador de IDs para rangos
                    UPDATE generador SET valor = costogenero_id WHERE nombre = 'CostoGenero'; -- Actualiza el contador de IDs para costogenero

                    RETURN TRUE; -- Retorna éxito si todo el proceso se completó correctamente
                END;
                $$;

                ALTER FUNCTION clonarcostotarifario(char, char, numeric) OWNER TO postgres; -- Asigna la propiedad de la función al usuario postgres

--select clonarcostotarifario('8690', '2025-06-30', 3);
/*
select * from tarifario

select * from costo where tarifario_id = (select id from tarifario where codigo = '8690')  --5638

select * from rangocosto where costo_id = 5638

select * from costogenero where rangocosto_id in (select id from rangocosto where costo_id = 5638)*/

select * from costo order by 1 desc

select * from rangocosto order by 1 desc