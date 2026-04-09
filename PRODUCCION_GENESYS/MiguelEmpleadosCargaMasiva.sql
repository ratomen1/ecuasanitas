SELECT
    c.nivel_id,
    etf.numero as cedulatitularfamilia,
    etf.nombre as nombretitularfamilia,
    case WHEN etf.numero = e.numero THEN 'SI' ELSE 'NO' END as titularIgualAfiliado,
    c.numero as contrato,
    f.numero as familia,
    a.numero as afiliacion,
    ti.nombre as tipo_identificacion,
    e.numero as cedula,
    e.primernombre,
    e.segundonombre,
    e.primerapellido,
    e.segundoapellido,
    e.email,
    EXTRACT(YEAR FROM e.fechanacimiento) as anio_nacimiento,
    EXTRACT(MONTH FROM e.fechanacimiento) as mes_nacimiento,
    EXTRACT(DAY FROM e.fechanacimiento) as dia_nacimiento,
    ep.nombre as parentesco,
    case when e.discapacitado = true then 'SI' else 'NO' end as discapacitado,
    CASE
        WHEN e.estadocivil = 'SO' THEN 'SOLTERO'
        WHEN e.estadocivil = 'CA' THEN 'CASADO'
        WHEN e.estadocivil = 'DI' THEN 'DIVORCIADO'
        WHEN e.estadocivil = 'VI' THEN 'VIUDO'
        WHEN e.estadocivil = 'UN' THEN 'EN UNION DE HECHO'
        WHEN e.estadocivil = 'SE' THEN 'SEPARADO'
        WHEN e.estadocivil = 'TO' THEN 'TODOS'
        ELSE 'DESCONOCIDO'
    END as estado_civil,
    case when e.genero = 'M' then 'MASCULINO' else 'FEMENINO' end as genero,
    'SI' as transferencia,
    c.numero as contratoOrigen,
    '' as prepagaanterior,
    coberturas.codigoservicio as coberturasindividuales,
    '' as coberturasfamiliares,
    '' as contratantefamilia,
    '' as parentescocontratante
FROM contrato c
left join afiliacion a on c.id = a.contrato_id and a.estadoafiliacion = 'REG'
left join titular tf on a.familia_id = tf.familia_id
left join entidad etf on tf.entidad_id = etf.id
left join familia f on a.familia_id = f.id
left join entrada ep on ep.id = a.parentesco_id
left join entidad e on a.afiliado_id = e.id
left join tipoidentificacion ti on e.tipoidentificacion_id = ti.id
left join LATERAL (
    SELECT
        cc.afiliacion_id,
        STRING_AGG(cc.codigoservicio::text, ',') AS codigoservicio
    FROM coberturacontratada cc
    WHERE cc.afiliacion_id = a.id
      AND cc.estadocoberturacontratada = 'REG'
      AND cc.coberturaimplicita = FALSE
    GROUP BY cc.afiliacion_id
    ) as coberturas on coberturas.afiliacion_id = a.id
WHERE c.id in (2009128)
and a.estadoafiliacion = 'REG'
and c.estado in ('REG');


SELECT
    ti.nombre as tipo_identificacion,
    e.numero as cedula,
    e.primernombre,
    e.segundonombre,
    e.primerapellido,
    e.segundoapellido,
    e.email,
    EXTRACT(YEAR FROM e.fechanacimiento) as anio_nacimiento,
    EXTRACT(MONTH FROM e.fechanacimiento) as mes_nacimiento,
    EXTRACT(DAY FROM e.fechanacimiento) as dia_nacimiento,
    '' as parentesco,
    case when e.discapacitado = true then 'SI' else 'NO' end as discapacitado,
    CASE
        WHEN e.estadocivil = 'SO' THEN 'SOLTERO'
        WHEN e.estadocivil = 'CA' THEN 'CASADO'
        WHEN e.estadocivil = 'DI' THEN 'DIVORCIADO'
        WHEN e.estadocivil = 'VI' THEN 'VIUDO'
        WHEN e.estadocivil = 'UN' THEN 'EN UNION DE HECHO'
        WHEN e.estadocivil = 'SE' THEN 'SEPARADO'
        WHEN e.estadocivil = 'TO' THEN 'TODOS'
        ELSE 'DESCONOCIDO'
    END as estado_civil,
    case when e.genero = 'M' then 'MASCULINO' else 'FEMENINO' end as genero,
    'NO' as transferencia,
    '' as contratoOrigen,
    '' as prepagaanterior,
    '' as coberturasindividuales,
    '' as coberturasfamiliares,
    '' as contratantefamilia,
    '' as parentescocontratante
FROM entidad e
left join tipoidentificacion ti on e.tipoidentificacion_id = ti.id
WHERE e.numero IN ('1103506562');



SELECT
    cc.afiliacion_id,
    STRING_AGG(cc.codigoservicio::text, ',') AS codigoservicio
FROM coberturacontratada cc
WHERE cc.afiliacion_id = 190007310142036
  AND cc.estadocoberturacontratada = 'ACT'
  AND cc.coberturaimplicita = FALSE
GROUP BY cc.afiliacion_id







