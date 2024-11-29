
SELECT
    es.nombre AS supervisor,
    es.numero AS cedulasupervisor,
    a.id AS idasesor,
    e.nombre AS asesor,
    e.numero AS cedualaasesor,
    a.fechaingreso ,
    eta.nombre AS tipoasesor,
    e.email ,
    a.codigo ,
    a.porcentagereliquidacion ,
    a.comisiona ,
    a.compartir_en_sala_supervisor ,
    d.nombre AS sede
FROM
    asesorcomercial a
        LEFT JOIN entrada eta ON eta.id = a.tipousuario_id
        LEFT JOIN usuario u ON u.id = a.usuario_id
        LEFT JOIN lugartrabajo l ON l.usuario_id = u.id AND l.principal = TRUE
        LEFT JOIN establecimiento et ON et.id = l.establecimiento_id
        LEFT JOIN sede s ON s.id = et.sede_id
        LEFT JOIN divisionterritorial d ON d.id = s.divisionterritorial_id
        LEFT JOIN entidad e ON e.id = u.entidad_id
        LEFT JOIN LATERAL (
        SELECT spv.supervisado_id,spv.supervisor_id FROM supervision spv WHERE spv.supervisado_id = u.id AND spv.supervisado_id IS NOT NULL AND spv.supervisor_id IS NOT NULL LIMIT 1
        ) sup ON sup.supervisado_id = u.id
        LEFT JOIN usuario us ON us.id = sup.supervisor_id
        LEFT JOIN entidad es ON es.id = us.entidad_id
WHERE a.activo = TRUE
  AND u.activo = TRUE
--AND eta.clave = 'INTERNO'

