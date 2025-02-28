SELECT c.numero            contrato,
       --n.nombreplan,
       et.nombre           titular,
       c.estado,
       --c.fechainicio,
       --ge.nombre           grupo_empresarial,
       --det.familias,
       --det.afiliados,
       det.cuota,
       --det.coberturas,
       --det.imp,
       ROUND(det.total, 2) total
FROM contrato c
         LEFT JOIN nivel n ON n.id = c.nivel_id
         LEFT JOIN titular t ON t.contrato_id = c.id AND t.familia_id IS NULL
         LEFT JOIN entidad et ON et.id = t.entidad_id
         LEFT JOIN entrada ge ON ge.id = c.grupoempresarial_id
         LEFT JOIN LATERAL (
    SELECT * FROM obtener_cuota_mensual_vigente('2025-02-01', c.id)
    ) cm ON cm.contratoid = c.id
         LEFT JOIN LATERAL (
    SELECT cuotamensual_id,
           COUNT(DISTINCT (CASE WHEN d.codigogrupo = 'CN' THEN d.titularfamilia_id ELSE NULL END)) familias,
           COUNT(DISTINCT (CASE WHEN d.codigogrupo = 'CN' THEN d.afiliacion_id ELSE NULL END))     afiliados,
           SUM(CASE WHEN d.codigogrupo = 'CN' THEN total ELSE 0 END)                               cuota,
           SUM(CASE WHEN d.codigogrupo = 'COB' THEN total ELSE 0 END)                              coberturas,
           SUM(CASE WHEN d.codigogrupo = 'IMP' THEN total ELSE 0 END)                              imp,
           SUM(d.total)                                                                            total
    FROM detalle d
    WHERE d.cuotamensual_id = cm.cuotamensual_id
--	where d.cuotamensual_id = 1416030
      AND d.esdesglose IS TRUE
    GROUP BY d.cuotamensual_id
    ) det ON det.cuotamensual_id = cm.cuotamensual_id
WHERE c.estado IN ('ACT', 'SUS') --, 'ANU'
  AND cm.cuotamensual_id IS NOT NULL
ORDER BY c.numero