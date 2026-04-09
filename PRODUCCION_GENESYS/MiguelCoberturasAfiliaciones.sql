SELECT
    dt.nombre as sede,
    c.numero as contrato,
    c.estado as estadocontrato,
    c.pasarelacobro,
    f.numero as familia,
    f.estadofamilia,
    a.numero as afiliacion,
    a.estadoafiliacion,
    cc.codigoservicio,
    cc.estadocoberturacontratada,
    ccs.valor coberturaSiam,
    e.numero as cedula,
    e.nombre as nombre,
    s.numero,
    s.fechapago
FROM obligacion o
left join contrato c on c.id = o.contrato_id
left join sede sd on sd.id = c.sede_id
left join divisionterritorial dt on dt.id = sd.divisionterritorial_id
left join afiliacion a on a.contrato_id = c.id
left JOIN familia f ON f.id = a.familia_id
left join entidad e on e.id = a.afiliado_id
left join solicitud s on s.numero = a.numerosolicitud
left join coberturacontratada cc on cc.afiliacion_id = a.id
left join entrada ccs on ccs.clave = substring(cc.codigoservicio from 1 for 2) and ccs.catalogo_id = 186
WHERE o.fechapagocomision BETWEEN '2025-01-01' AND '2025-04-01'
and o.servicio_id = 76
and substring(cc.codigoservicio from 1 for 2) in ('MM')
and cc.estadocoberturacontratada in ('ACT','EXC')
--and c.numero = 609117

select * from entidad where  numero = '1723870117'  -- 02-21

select * from afiliacion where afiliado_id = 718201


-- 2266
-- 8020


select * from entrada where catalogo_id = 186