
SELECT
    c.numero,
    a.codigo ,
    (p.contratorepresentacion::json)->>'codigoAsesor' AS codigoAsesorWeb,
    (p.contratorepresentacion::json)->>'codigoVendedor' AS codigoVendedorWeb
FROM
    obligacion o
        LEFT JOIN contrato c ON c.id = o.contrato_id
        LEFT JOIN asesorcomercial a ON a.id = c.vendedor_id
        LEFT JOIN preventaweb p ON p.numerocontrato = c.numero
        LEFT JOIN nivel n ON n.id = c.nivel_id AND n.nombreplan ILIKE '%pool%'
WHERE
    o.fechapagocomision = '2026-01-01'
  AND o.servicio_id = 76
  AND n.nombreplan ILIKE '%pool%'
--AND c.numero = 603251














