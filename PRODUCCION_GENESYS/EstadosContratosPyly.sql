SELECT
    numero AS contrato,
    estado ,
    (CASE WHEN estado='ANU' THEN fechacancelacion ELSE NULL END) AS fechaanulacion ,
    (CASE WHEN estado='ANU' THEN motivoanulacion ELSE NULL END) AS motivoanulacion
FROM contrato
WHERE numero IN (
                 542414,
                 262942,
                 585861,
                 286672,
                 188382,
                 254164,
                 514667,
                 240920,
                 602989,
                 593976,
                 503189
    )