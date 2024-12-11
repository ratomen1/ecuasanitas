--Consulta de todas las coberturas con descuento solo ventas web
SELECT
    a.id as afiliadoId,
    c.id as coberturaid,
    co.fechainicio as fechainiciocontrato,
    c.fechapagocomision as fechapagocomisioncobertura,
    pw.id,
    pw.valor,
    pw.tiposervicio,
    co.numero as contrato,
    f.numero as familia,
    a.numero as afiliado,
    c.codigoservicio,
    (case when c.coberturaimplicita = true then 'SI' else 'NO' end) as coberturaimplicita
FROM coberturacontratada c
LEFT JOIN contrato co ON co.id = c.contrato_id
LEFT JOIN familia f ON f.id = c.familia_id
LEFT JOIN afiliacion a ON a.contrato_id = co.id and a.id = c.afiliacion_id
LEFT JOIN obligacion o ON o.contrato_id = co.id and o.fechapagocomision = c.fechapagocomision and o.servicio_id = 76
LEFT JOIN preventaweb p ON p.numerocontrato = co.numero
LEFT JOIN promocionweb pw ON pw.id = (p.contratorepresentacion::json->>'promocionAplicadaId')::bigint
WHERE c.id IN (SELECT * FROM coberturasAuxiliar)
  AND c.fechapagocomision = '2024-11-01'
  AND o.servicio_id = 76
  AND co.tipocontrato = 'F'
AND CO.numero = 605013
--AND co.fechainicio = '2024-11-01';




--Consulta de todas las coberturas con descuento
select distinct c.id coberturacontratadaid, c.codigoservicio, c.coberturaimplicita, co.numero contrato,
                f.numero familia,
                a.numero usuario,
                co.fechainicio, co.tipocontrato, n.nombreplan, d.contrato_id, d.descripcion, d.fechaemision, d.valor, d.total,
                det.*
FROM coberturacontratada c
         left join contrato co on co.id = c.contrato_id
         left join afiliacion a on a.id = c.afiliacion_id
         left join familia f ON f.id = c.familia_id
         left join nivel n on n.id = co.nivel_id
         left join detalleemision d on d.contrato_id = co.id
         left join lateral (
    select obligacion_id,
           sum(valor) valor,
           sum(descuentotarifa) descuentoTarif,
           sum(valordescontado) valordescontado,
           sum(descuento) descuento,
           sum(total) total
    from detalle det
    where det.obligacion_id = d.obligacionid
      and servicio_id = 1243
    group by 1
    ) det on det.obligacion_id = d.obligacionid
WHERE c.id IN (SELECT * FROM coberturasAuxiliar)
  and c.fechapagocomision = '2024-11-01'
  AND co.tipocontrato = 'F'
  and  d.servicio_id = 76
  and d.estado = 'PAGADO'
order by 2
