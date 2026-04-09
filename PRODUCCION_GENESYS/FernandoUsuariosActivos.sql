----------------- script para usuarios activos fin de mes se entrga a Rubén ----------
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
    dtsede.nombre SEDE,
    c.numero CONTRATO,
    (CASE WHEN c.tipocontrato <> 'C' THEN 0 ELSE f.numero END ) familia,
    a.numero usuario,
    e.fechanacimiento FECHA_NACIMIENTO,
    a.fechapagocomision FECHA_PAGO_COMISION,
    a.fechainicio FECHA_INGRESO,
    e.genero SEXO,
    c.estado ESTADO_CONTRATO,
    c.fecharenovacion FECHA_RENOVACION_CONTRATO,
    etp.nombre TIPO_CONTRATO,
    ep.nombre plan,
    enc.nombre nivel,
    n7.nombreplan nivelCompleto
FROM DetalleReporteUsuario dru
left join afiliacion a on a.id = dru.idafiliacion
left join contrato c on c.numero = dru.numerocontrato
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
and dru.tipousuario in ('ACT_ANTIGUOS','ACT_NUEVOS','TRASPASOS_NUEVOS')
AND dru.fechareporte = '2025-03-01'





