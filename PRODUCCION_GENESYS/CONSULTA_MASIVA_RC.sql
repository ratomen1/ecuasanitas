SELECT
    '' AS nivel_id,
    '' as cedulaafiliado,
    p.nombre as nombreafiliado,
    '' as contrato,
    '' as familia,
    '' as afiliacion,
    'CEDULA' as tipo_identificacion,
    p.cedula,
    CASE
        WHEN array_length(string_to_array(p.nombre, ' '), 1) > 4 THEN ''
        ELSE split_part(p.nombre, ' ', 3)
        END AS primer_nombre,
    CASE
        WHEN array_length(string_to_array(p.nombre, ' '), 1) > 4 THEN ''
        ELSE split_part(p.nombre, ' ', 4)
        END AS segundo_nombre,
    CASE
        WHEN array_length(string_to_array(p.nombre, ' '), 1) > 4 THEN p.nombre
        ELSE split_part(p.nombre, ' ', 1)
        END AS primer_apellido,
    CASE
        WHEN array_length(string_to_array(p.nombre, ' '), 1) > 4 THEN ''
        ELSE split_part(p.nombre, ' ', 2)
        END AS segundo_apellido,
    '' AS email,
    substring(p.fechanacimiento FROM 1 FOR 4) as anio_nacimiento,
    substring(p.fechanacimiento FROM 6 FOR 2) as mes_nacimiento,
    substring(p.fechanacimiento FROM 9 FOR 2) as dia_nacimiento,
    '' as parentesco,
    CASE
        WHEN p.condicioncedulado ILIKE '%DISCAPACIDAD%' THEN 'SI'
        ELSE 'NO'
        END as discapacidad,
    p.estadocivil as estado_civil,
    --p.genero,
    '' as transferencia,
    '' as contratoOrigen,
    '' as prepagaanterior,
    '' as coberturasindividuales,
    '' as coberturasfamiliares,
    '' as contratantefamilia,
    '' as parentescocontratante
FROM
    persona p
WHERE
    cedula IN (
        SELECT
            cedula
        FROM
            entidad e );


SELECT * FROM persona WHERE condicioncedulado ILIKE '%DISCAPACIDAD%';