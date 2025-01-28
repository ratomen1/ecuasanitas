SELECT
    c.numero as contrato,
    c.estado as estadocontrato,
    f.numero as familia,
    f.estadofamilia,
    a.numero as afiliado,
    a.estadoafiliacion,
    e.nombre as nombreafiliado,
    e.numero as cedula
FROM afiliacion a
         left join contrato c on a.contrato_id = c.id
         left join familia f on a.familia_id = f.id
         left JOIN entidad e ON e.id = a.afiliado_id
WHERE a.contrato_id IS NOT NULL