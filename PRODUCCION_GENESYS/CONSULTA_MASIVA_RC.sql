SELECT ti.nombre                                                     AS tipo_identificacion,
       e.numero                                                      AS cedula,
       e.primernombre,
       e.segundonombre,
       e.primerapellido,
       e.segundoapellido,
       e.email,
       EXTRACT(YEAR FROM e.fechanacimiento)                          AS anio_nacimiento,
       EXTRACT(MONTH FROM e.fechanacimiento)                         AS mes_nacimiento,
       EXTRACT(DAY FROM e.fechanacimiento)                           AS dia_nacimiento,
       ''                                                            AS parentesco,
       CASE WHEN e.discapacitado = TRUE THEN 'SI' ELSE 'NO' END      AS discapacitado,
       CASE
           WHEN e.estadocivil = 'SO' THEN 'SOLTERO'
           WHEN e.estadocivil = 'CA' THEN 'CASADO'
           WHEN e.estadocivil = 'DI' THEN 'DIVORCIADO'
           WHEN e.estadocivil = 'VI' THEN 'VIUDO'
           WHEN e.estadocivil = 'UN' THEN 'EN UNION DE HECHO'
           WHEN e.estadocivil = 'SE' THEN 'SEPARADO'
           WHEN e.estadocivil = 'TO' THEN 'TODOS'
           ELSE 'DESCONOCIDO' END                                    AS estado_civil,
       CASE WHEN e.genero = 'M' THEN 'MASCULINO' ELSE 'FEMENINO' END AS genero,
       'NO'                                                          AS transferencia,
       ''                                                            AS contratoOrigen,
       ''                                                            AS prepagaanterior,
       ''                                                            AS coberturasindividuales,
       ''                                                            AS coberturasfamiliares,
       ''                                                            AS contratantefamilia,
       ''                                                            AS parentescocontratante
FROM entidad e
left JOIN tipoidentificacion ti ON e.tipoidentificacion_id = ti.id
WHERE e.numero IN ( '1314075902', '1725809121', '0930031828', '0103588760', '1724429657' )