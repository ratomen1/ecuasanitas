SELECT ''                                                                                                          AS nivel_id,
       ''                                                                                                          AS cedulaafiliado,
       p.nombre                                                                                                    AS nombreafiliado,
       ''                                                                                                          AS contrato,
       ''                                                                                                          AS familia,
       ''                                                                                                          AS afiliacion,
       'CEDULA'                                                                                                    AS tipo_identificacion,
       p.cedula,
       CASE
           WHEN ARRAY_LENGTH(STRING_TO_ARRAY(p.nombre, ' '), 1) > 4 THEN ''
           ELSE SPLIT_PART(p.nombre, ' ', 3) END                                                                   AS primer_nombre,
       CASE
           WHEN ARRAY_LENGTH(STRING_TO_ARRAY(p.nombre, ' '), 1) > 4 THEN ''
           ELSE SPLIT_PART(p.nombre, ' ', 4) END                                                                   AS segundo_nombre,
       CASE
           WHEN ARRAY_LENGTH(STRING_TO_ARRAY(p.nombre, ' '), 1) > 4 THEN p.nombre
           ELSE SPLIT_PART(p.nombre, ' ', 1) END                                                                   AS primer_apellido,
       CASE
           WHEN ARRAY_LENGTH(STRING_TO_ARRAY(p.nombre, ' '), 1) > 4 THEN ''
           ELSE SPLIT_PART(p.nombre, ' ', 2) END                                                                   AS segundo_apellido,
       ''                                                                                                          AS email,
       SUBSTRING(p.fechanacimiento FROM 1 FOR 4)                                                                   AS anio_nacimiento,
       SUBSTRING(p.fechanacimiento FROM 6 FOR 2)                                                                   AS mes_nacimiento,
       SUBSTRING(p.fechanacimiento FROM 9 FOR 2)                                                                   AS dia_nacimiento,
       ''                                                                                                          AS parentesco,
       (CASE WHEN p.condicioncedulado ILIKE '%DISCAPACIDAD%' THEN 'SI' ELSE 'NO' END) as discapacitado,
       p.estadocivil                                                                                               AS estado_civil,
       p.genero,
       '' as transferencia,
       '' as contratoOrigen,
       '' as prepagaanterior,
       '' as coberturasindividuales,
       '' as coberturasfamiliares,
       '' as contratantefamilia,
       '' as parentescocontratante
FROM   persona p
WHERE
    cedula IN ('1103506562',
               '2100752191',
               '2100279617',
               '1753912128',
               '1721132445',
               '1722114814',
               '0401250469',
               '1723269005',
               '1724831597',
               '1751703941')

select * from persona order by 1 desc