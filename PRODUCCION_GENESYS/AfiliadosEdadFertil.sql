SELECT
    c.numero as contrato,
    a.fechapagocomision as fechainicioAfiliacion,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, a.fechapagocomision)) * 12 +
    EXTRACT(MONTH FROM AGE(CURRENT_DATE, a.fechapagocomision)) AS meses_transcurridos,
    e.fechanacimiento,
    e.email as correoafiliacion,
    c.correo as correocontrato,
    e.nombre,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, e.fechanacimiento)) AS edad
FROM entidad e
         left join afiliacion a on a.afiliado_id = e.id and a.estadoafiliacion = 'ACT'
         left join contrato c on c.id = a.contrato_id
         left join contratonivel cn on cn.contrato_id = c.id and cn.tipoplan = 'F'
         left join familia f ON a.familia_id = f.id
WHERE e.fechanacimiento IS NOT NULL
  AND e.genero = 'F'
  AND EXTRACT(YEAR FROM AGE(CURRENT_DATE, e.fechanacimiento)) BETWEEN 20 AND 40
  and a.estadoafiliacion = 'ACT'
  and c.estado = 'ACT'
  and cn.tipoplan = 'F'
  and a.fechapagocomision >= '2024-08-01'
ORDER BY
    e.fechanacimiento DESC;




