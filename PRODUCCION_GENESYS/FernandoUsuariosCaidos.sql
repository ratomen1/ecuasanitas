----------------- script para usuarios caidos fin de mes se entrga a Rubén ----------
SELECT
    '2025-03-01' AS FECHA_REPORTE,
    dru.tipousuario,
    dru.idafiliacion,
    dru.fechaalta,
    dru.fechapagocomision,
    dru.fechaexclusion,
    dru.fechareporte,
    dru.motivoexclusion,
    dru.estadoafiliacion,
    dru.antiguedad,
    dru.afiliado,
    dru.familia,
    dru.plan,
    dru.tipoplan,
    dru.nivel,
    dru.codigosede,
    dru.sede,
    dru.numerocontrato,
    dru.estadocontrato,
    dru.fechainiciocontrato,
    dru.fechaanulacioncontrato,
    dru.fechapagocontrato,
    dru.tipodetalle,
    dru.fechaguardado,
    concat (c.numero , '-', (CASE WHEN c.tipocontrato <> 'C' THEN 0 ELSE f.numero END ) , '-', a.numero),
    p.monto AS montoplanmedico,
    sc.codigo SEDE_CODIGO,
    dtsede.nombre SEDE,
    c.nivel_id ,
    entidad_t.numero cedula_titular,
    entidad_t.nombre nombre_titular,
    c.numero CONTRATO,
    entidad_t.nombre titular,
    (CASE WHEN c.tipocontrato <> 'C' THEN 0 ELSE f.numero END ) FAMILIA,
    a.numero USUARIO,
    e.nombre NOMBRE_USUARIO,
    e.fechanacimiento FECHA_NACIMIENTO,
    date_part('year', age(e.fechanacimiento)) EDAD_ANIOS,
    date_part('mon', age(e.fechanacimiento)) EDAD_MESES,
    ti.nombre TIPO_IDENTIFICACION,
    e.numero CEDULA,
    a.fechapagocomision FECHA_PAGO_COMISION,
    epa.nombre,
    e.genero SEXO,
    a.fechainicio FECHA_INGRESO,
    a.estadoafiliacion ESTADO,
    a.motivoexclusion MOTIVO_EXCLUSION,
    a.fechaexclusion FECHA_EXCLUSION,
    a.fechasolicitudexclusion FECHA_SOLICITUD_EXCLUSION,
    a.esreingreso REINGRESO,
    c.fechapago FECHA_PAGO_CONTRATO,
    c.estado ESTADO_CONTRATO,
    c.fechainicio FECHA_INICIO_CONTRATO,
    c.fecharenovacion FECHA_RENOVACION_CONTRATO,
    c.fechavencimiento FECHA_VENCIMIENTO_CONTRATO,
    etp.nombre TIPO_CONTRATO,
    ep.nombre PLAN,
    enc.nombre NIVEL,
    n7.nombreplan nivelCompleto,
    conv.clave codigoConvenio,
    conv.nombre CONVENIO,
    ac.codigo codigo_asedor,
    vend.nombre vendedor,
    (case when ant.id is not null then 'SI' else 'NO' END) ES_REINGRESO,
    ant.numero CONTRATO_ANTERIOR,
    a.fechaalta FECHA_ALTA,
    fp.nombre,
    e.discapacitado,
    (CASE WHEN date_part('year', age(e.fechanacimiento)) >= 65 THEN true ELSE false END ) terceraEdad,
    case when obtener_edad(e.fechanacimiento, a.fechaalta) >= 65 then true else false end terceraEdadAnterior,
    de.fechadeclaracion fechadeclaracionembarazo
FROM DetalleReporteUsuario dru
left join contrato c on c.numero = dru.numerocontrato
left join afiliacion a on a.id = dru.idafiliacion
LEFT JOIN planmedico p ON p.codigo = c.planmedico
left join familia f on f.id = a.familia_id
left join entidad e on e.id = a.afiliado_id
left join tipoidentificacion ti on ti.id = e.tipoidentificacion_id
left join contratonivel cn on cn.contrato_id = c.id
left join entrada ep on ep.clave = cn.plan and ep.catalogo_id = 86
left join entrada etp on etp.clave = cn.tipoPlan and etp.catalogo_id = 94
left join entrada enc on enc.clave = cn.nivel and enc.catalogo_id = 87
left join entrada conv on conv.id = c.convenio_id and conv.catalogo_id = 56
left join contrato ant on ant.id = a.antiguedad_id
left join sede sc on sc.id = c.sede_id
left join divisionterritorial dtsede on dtsede.id = sc.divisionterritorial_id
left join entrada epa on epa.id = a.parentesco_id
left join autorizacioncobro au on au.contrato_id = c.id
left join entrada fp on fp.id = au.tiporecaudacion_id and fp.catalogo_id = 41
left join entrada tc on tc.id = au.tipocuenta_id and tc.catalogo_id = 54
left join institucionfinanciera ifi on ifi.id = au.emisor_id
left join nivel n7 on n7.id = c.nivel_id
left join titular t on t.contrato_id = c.id and t.familia_id is null
left join entidad entidad_t on entidad_t.id = t.entidad_id
left join asesorcomercial ac on ac.id = c.vendedor_id
left join usuario u on u.id = ac.usuario_id
left join entidad vend on vend.id = u.entidad_id
left join declaracionembarazo de on de.afiliacion_id = a.id
WHERE reporteusuario_id = (select id from reporteusuario where fechareporte = '2025-03-01')
  and dru.tipousuario in ('EXCLUIDOS','MOROSOS','TRASPASOS_CAIDOS')
  AND dru.fechareporte = '2025-03-01'





