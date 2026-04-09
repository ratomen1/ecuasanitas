select
    c.nivel_id nivelid,
    n.nombreplan,
--'' nivel_anterior_id,
--'' nombreplan_anterior,
    sc.codigo SEDE_CODIGO,
    dtsede.nombre SEDE,
    ac.codigo codigo_asesor,
    ta.nombre tipo_asesor,
    ea.nombre nombre_asesor,
    c.numero contrato,
    et.numero cedula_titular,
    et.nombre titular_contrato,
    etp.nombre TIPO_CONTRATO,
    ep.nombre PLAN,
    enc.nombre NIVEL_CONTRATO,
    c.estado estado_contrato,
    c.fechainicio,
    c.fechapago fecha_pago_contrato,
    c.fechacancelacion fecha_anulacion,
    c.fechaavisocancelacion fecha_aviso_anulacion,
    c.observacion es_venta_web,
    c.numerosolicitud,
    af.afiliados numero_afiliados,
    af.transferencias afiliados_transferencia,
    rv.factura,
    s.codigo tx,
    s.nombre nombretx,
    d.fechaemision fechaserviciotx,
    d.fechaconciliacion fecha_pago_caja,
    rv.cuotaneta valor_base,
    rv.descuentotarifa,
    (rv.cuotaneta - rv.descuentotarifa ) cuota_neta,
    round(rv.descuentocuota * 100 /(rv.cuotaneta - rv.descuentotarifa ), 2) porcentaje_desc_cuota,
    rv.descuentocuota,
    rv.totalcuota,
    rv.cobneta valor_neto_coberturas,
    round((case when rv.cobneta > 0 then rv.descuentocob * 100 /rv.cobneta else 0 end), 2) porcentaje_desc_coberturas_,
    rv.descuentocob descuento_coberturas,
    rv.totalcob total_coberturas,
    rv.subtotal,
    rv.sca impuesto,
    rv.totalpagar
from (
         select * from dblink ('dbname=luca',format ('select rv.id,
			rv.receivablestatuscode status,
			fa.factura,
			drv.cuotaneta,
			drv.descuentocuota,
			drv.descuentotarifa,
			drv.totalcuota,
			drv.cobneta,
			drv.descuentocob,
			drv.totalcob,
			rv.total subtotal,
			(rv.paymentreference - rv.total) sca,
			rv.paymentreference totalPagar
			from receivable.receivable rv
			left join receivable.credit c on c.id = rv.credit_id
			left join receivable.entry e on e.id = c.entry_id
			left join lateral (
				select receivable_id,
				sum(case when d.entry_id = 121 then value_ else 0 end) cuotaNeta,
				sum(case when d.entry_id = 121 then (discount - coalesce(discountfee, 0)) else 0 end) descuentoCuota,
				sum(case when d.entry_id = 121 then discountfee else 0 end) descuentotarifa,
				sum(case when d.entry_id = 121 then total else 0 end) totalCuota,
				sum(case when d.entry_id <> 121 then value_ else 0 end) cobNeta,
				sum(case when d.entry_id <> 121 then discount else 0 end) descuentoCob,
				sum(case when d.entry_id <> 121 then total else 0 end) totalCob
				from receivable.detail d
				where d.receivable_id = rv.id
				and priority > 0
				group by receivable_id
			) drv on drv.receivable_id = rv.id
			left join  (
				select receivableid, string_agg(distinct rp.vouchernumberreference, '' '') factura
				from income.deposit d
				left join income.payment p on p.id = d.payment_id
				left join income.receiptreport rp on rp.id = p.receiptreport_id
				where d.financialstatuscode = ''VALID''
				and p.financialstatuscode = ''VALID''
				and d.creationdate >= ''2023-01-01''
				group by receivableid
			) fa on fa.receivableid = rv.id
			where e.key_ = ''VN''
			and rv.emission between ''2025-05-01'' and ''2025-05-16''
			and rv.receivablestatuscode in (''CREDIT.PAID'', ''CREDIT.IN_AGREEMENT'')
			and rv.discount > 0'
                                             )) AS ab (id bigint,
                                                       status varchar,
                                                       factura varchar,
                                                       cuotaneta numeric,
                                                       descuentocuota numeric,
                                                       descuentotarifa numeric,
                                                       totalcuota numeric,
                                                       cobneta numeric,
                                                       descuentocob numeric,
                                                       totalcob numeric,
                                                       subtotal numeric,
                                                       sca numeric,
                                                       totalpagar numeric)
     ) rv
         left join detalleemision d on d.ordencobroid = rv.id
         left join servicio s on s.id = d.servicio_id
         left join contrato c on c.id = d.contrato_id
         left join nivel n on n.id = c.nivel_id
         left join sede sc on sc.id = c.sede_id
         left join divisionterritorial dtsede on dtsede.id = sc.divisionterritorial_id
         left join asesorcomercial ac on ac.id = c.vendedor_id
         left join usuario ua on ua.id = ac.usuario_id
         left join entidad ea on ea.id = ua.entidad_id
         left join entrada ta on ta.catalogo_id = 61 and ta.id = ac.tipousuario_id
         left join titular t on t.contrato_id  = c.id and t.familia_id is null
         left join entidad et on et.id = t.entidad_id
         left join contratonivel cn on cn.contrato_id = c.id
         left join entrada ep on ep.clave = cn.plan and ep.catalogo_id = 86
         left join entrada etp on etp.clave = cn.tipoPlan and etp.catalogo_id = 94
         left join entrada enc on enc.clave = cn.nivel and enc.catalogo_id = 87
         left join lateral (
    select a.contrato_id,
           count(a.id) afiliados,
           count(case when a.antiguedad_id is not null then a.id else null end ) transferencias
    from afiliacion a
    where a.contrato_id = c.id
      and a.estadoafiliacion in ('ACT','EXC')
    group by 1
    ) af on af.contrato_id = c.id
--left join renovacioncorporativa r on r.contratoid = c.id and r.fecharenovacion >= '2025-01-01'
--left join nivel na on na.id = r.planactualid
where c.estado in ('ACT','SUS','ANU')
  and c.tipocontrato = 'F'
  and rv.descuentocuota = 0
order by contrato;