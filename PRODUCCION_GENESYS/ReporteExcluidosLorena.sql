SELECT
    dt.nombre as sede,
    c.numero as contrato,
    ec.nombre as titularcontrato,
    f.numero as familia,
    a.numero as numeroUsuario,
    a.fechaexclusion,
    a.motivoexclusion
FROM afiliacion a
         left join familia f on a.familia_id = f.id
         left join contrato c on c.id = a.contrato_id
         left join sede s on s.id = c.sede_id
         left join titular tc on tc.contrato_id = c.id and tc.familia_id is null
         left join entidad ec on ec.id = tc.entidad_id
         left join divisionterritorial dt on dt.id = s.divisionterritorial_id
WHERE a.fechaexclusion BETWEEN '2023-01-01' AND '2024-12-31'
  AND a.estadoafiliacion = 'EXC'
  and tc.familia_id is null