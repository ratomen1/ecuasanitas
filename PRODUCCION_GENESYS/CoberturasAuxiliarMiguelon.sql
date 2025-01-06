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
  AND c.fechapagocomision = '2024-12-01'
  AND o.servicio_id = 76
  and co.tipocontrato = 'F';


SELECT count(id_cobertura) FROM coberturasAuxiliar