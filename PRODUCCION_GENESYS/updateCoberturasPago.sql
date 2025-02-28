
WITH afiliacion_excluida AS (
    SELECT id, afiliado_id
    FROM afiliacion
    WHERE estadoafiliacion = 'EXC'
      AND fechaexclusion = '2025-02-01'
),
cobertura_excluida AS (
    SELECT afiliacion_id, codigoservicio, pago
    FROM coberturacontratada
    WHERE estadocoberturacontratada = 'EXC'
           AND fechaexclusion = '2025-01-31'
)
SELECT
    cc.id,
    cc.codigoservicio,
    cc.pago,
    ce.codigoservicio AS codigo_servicio_subconsulta,
    ce.pago AS pago_subconsulta,
    CONCAT('UPDATE coberturacontratada SET pago = ''', ce.pago, ''', fechaultimamodificacion = ''2025-02-28 11:58:31.617000'' WHERE id = ', cc.id, ';') AS update_query
FROM coberturacontratada cc
LEFT JOIN afiliacion_excluida ae ON ae.afiliado_id = (
    SELECT afiliado_id
    FROM afiliacion
    WHERE id = cc.afiliacion_id
)
LEFT JOIN cobertura_excluida ce ON ce.afiliacion_id = ae.id
AND ce.codigoservicio ILIKE SUBSTRING(cc.codigoservicio FROM 1 FOR 2) || '%'
WHERE ce.codigoservicio IS NOT NULL
AND ce.pago IS NOT NULL
AND cc.afiliacion_id IN (
                           190007310237704,
                           190007310237705,
                           190007310237706
);

