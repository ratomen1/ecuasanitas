SELECT
    DISTINCT d.afiliacion_id,
             c.numero AS contrato,
             f.numero AS familia,
             A.numero AS afiliado,
             cn.tipoPlan,
             (SELECT obtener_edad( e.fechanacimiento,'2023-06-01' )) AS edad,
             s.codigo,
             e.discapacitado,
             a.antiguedad_id,
             CASE
                 WHEN r.valorReingreso IS NULL THEN 0.0
                 ELSE r.valorReingreso
                 END,
             sancion.clave,
             o.modalidadcobro,
             a.esextranjero,
             con.fechainicio AS fechainicionivel,
             (CASE
                  WHEN n.nombre ILIKE '%POOL%'
                      OR n.nombreplan ILIKE '%POOL%' THEN TRUE
                  ELSE FALSE
                 END) AS espool,
             p.id AS plannivelid,
             p.limitecomercializacion AS planLimitecomercializacion,
             CAST(nna.nivel AS int8) AS nivelnoaplicaId,
             c.observacion AS observacionContrato,
             p.tipocontrato AS plantipo,
             (SELECT string_agg(tiposervicio, ',') FROM promocionweb p WHERE '2023-06-01' BETWEEN p.desde AND p.hasta) AS servicioPromocion,
             c.id AS contratoId,
             o.id,
             e.nombre,
             c.vendedor_id,
             vd.codigo AS codigoVendedor,
             uvde.nombre AS nombreVendedor,
             (SELECT
                  es.nombre
              FROM supervision s
                       LEFT JOIN usuario us ON us.id = s.supervisor_id
                       LEFT JOIN entidad es ON es.id = us.entidad_id
              WHERE s.supervisor_id IS NOT NULL
                AND s.supervisado_id = uvd.id
              LIMIT 1
             ) AS supervisor,
             c.comisionista_id,
             tac.id AS tipoAsesorId,
             (CASE
                  WHEN s.codigo = 'VN' THEN o.pagosadelantados
                  ELSE NULL
                 END) AS pagosadelantados,
             r.ingreso,
             r.egreso,
             r.porcentajesiniestralidad,
             c.porcentajedescuentotr,
             aa.estadoafiliacion AS estadoAfiliacionAtiguedad,
             aa.fechaexclusion AS fechaExclusionAntiguedad,
             (CASE
                  WHEN st.id IS NULL THEN FALSE
                  ELSE TRUE
                 END) AS tieneSolicitudTraspaso,
             CAST(DATE_PART('year', AGE(ar.fechaexclusion, ar.fechainicioafiliacion)) AS INTEGER) AS aniosantiguedad,
             CAST(DATE_PART('day',(now()-(ar.fechapago + INTERVAL '1 month'))) AS INTEGER) AS diasimpago,
             (CASE
                  WHEN a.esreingreso IS NULL THEN FALSE
                  ELSE a.esreingreso
                 END ) AS esReingreso,
             ar.numero AS contratoantiguedad,
             ar.id AS afiliacionidantiguedad,
             a.fechainicio AS fechainicioNuevaAfiliacion,
             ar.fechaexclusion,
             (CASE
                  WHEN rm.presentadeclaracion IS NULL THEN FALSE
                  ELSE rm.presentadeclaracion
                 END) AS presentadeclaracion,
             sepagacomisionporreingreso(s.codigo,
                                        CAST(DATE_PART('year', AGE(ar.fechaexclusion, ar.fechainicioafiliacion)) AS INTEGER),
                                        CAST(DATE_PART('day',(now()-(ar.fechapago + INTERVAL '1 month'))) AS INTEGER),
                                        ar.fechaexclusion,
                                        a.fechainicio) AS tieneRenovacion,
             o.numerosolicitud
FROM
    obligacion o
        LEFT JOIN solicitudvinculacion sv ON sv.contratoid = o.contrato_id AND sv.numerosolicitud = o.numerosolicitud
        LEFT JOIN solicitudtraspaso st ON st.contratonuevoid = o.contrato_id AND st.fecha = '2023-06-01' AND st.numerosolicitud = o.numerosolicitud
        LEFT JOIN entrada sancion ON sancion.id = sv.sancion_id
        LEFT JOIN detalle d ON d.obligacion_id = o.ID
        LEFT JOIN afiliacion A ON A.ID = d.afiliacion_id
        LEFT JOIN revisionmedica rm ON rm.afiliacion_id = a.id
        LEFT JOIN LATERAL (
        SELECT
            aa.estadoafiliacion,
            aa.fechaexclusion ,
            aa.contrato_id,
            aa.afiliado_id
        FROM
            afiliacion aa
        WHERE
            aa.contrato_id = a.antiguedad_id
          AND aa.afiliado_id = a.afiliado_id
          AND aa.estadoafiliacion IN ('ACT', 'EXC')
        LIMIT 1
        ) aa ON aa.contrato_id = a.antiguedad_id AND aa.afiliado_id = a.afiliado_id
        LEFT JOIN entidad e ON e.ID = A.afiliado_id
        LEFT JOIN contrato c ON c.id = A.contrato_id
        LEFT JOIN asesorcomercial ac ON ac.id = o.asesorcomericial_id
        LEFT JOIN entrada tac ON tac.id = ac.tipousuario_id
        LEFT JOIN nivel n ON n.id = c.nivel_id
        LEFT JOIN plan p ON p.id = n.id
        LEFT JOIN LATERAL (
        SELECT
            ar.afiliado_id ,
            ar.contrato_id ,
            ca.fechapago,
            ca.fechainicio,
            ar.fechainicio AS fechainicioafiliacion,
            ar.fechaexclusion,
            ca.numero,
            ar.id,
            ROW_NUMBER() OVER (PARTITION BY ar.afiliado_id
                ORDER BY
                    ca.fechapago DESC) AS ROW_NUMBER
        FROM afiliacion ar
                 LEFT JOIN contrato ca ON ca.id = ar.contrato_id
        WHERE ar.estadoafiliacion = 'EXC'
        ) ar ON
        ar.afiliado_id = a.afiliado_id
            AND ar.ROW_NUMBER = 1
            AND ar.contrato_id <> a.contrato_id
        LEFT JOIN nivelesnoaplica nna ON CAST(nna.nivel AS int) = n.id
        LEFT JOIN (
        SELECT
            c.estado,
            c.nivel_id,
            c.fechainicio,
            ROW_NUMBER() OVER (PARTITION BY c.nivel_id
                ORDER BY
                    c.fechainicio ASC) AS ROW_NUMBER
        FROM
            contrato c
        WHERE
            c.estado IN ('ACT', 'ANU')
    ) AS con ON
        con.nivel_id = n.id
            AND con.ROW_NUMBER = 1
        LEFT JOIN familia f ON f.id = A.familia_id
        LEFT JOIN contratoNivel cn ON cn.contrato_id = c.id
        LEFT JOIN servicio s ON s.id = o.servicio_id
        LEFT JOIN (
        SELECT * FROM calculo_reingreso('2023-06-01')
    )r ON r.contrato = c.numero AND r.familia = (CASE WHEN c.tipoContrato = 'C' THEN f.numero ELSE 0 END)
        AND r.afiliacion = a.numero
        LEFT JOIN asesorcomercial vd ON vd.id = c.vendedor_id
        LEFT JOIN usuario uvd ON uvd.id = vd.usuario_id
        LEFT JOIN entidad uvde ON uvde.id = uvd.entidad_id
WHERE
    o.fechapagocomision = '2023-06-01'
  AND d.afiliacion_id IS NOT NULL
  AND d.activo = TRUE
ORDER BY
    s.codigo ASC
