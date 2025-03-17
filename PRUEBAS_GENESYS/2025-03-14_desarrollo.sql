SELECT 
                  (SELECT nombre FROM entidad WHERE id = u.entidad_id) AS asesorcomercial, 
                  ac.codigo AS codigoAsesorComercial, 
                  (CASE WHEN c.numero IS NOT NULL 
                          THEN c.numero 
                          ELSE (SELECT numero FROM contrato WHERE id =(SELECT contrato_id FROM titular WHERE id = d.titularfamilia_id)) 
                          END 
                  ) AS contrato, 
                  (CASE WHEN f.numero IS NOT NULL 
                          THEN f.numero 
                          ELSE (SELECT numero FROM familia WHERE id =(SELECT familia_id FROM titular WHERE id = d.titularfamilia_id)) 
                          END 
                  ) AS familia, 
                  A.numero AS afiliado, 
                  e.numero AS cedula, 
                  e.nombre AS nombreAfiliado, 
                  (CASE WHEN o.numerosolicitud IS NOT NULL THEN o.numerosolicitud ELSE 
                    (CASE WHEN a.numerosolicitud IS NOT NULL 
                          THEN a.numerosolicitud 
                          ELSE (SELECT numerosolicitud FROM familia WHERE id =(SELECT familia_id FROM titular WHERE id = d.titularfamilia_id)) 
                          END 
                    ) 
                  END )AS numerosolicitud, 
                  o.sede, 
                  d.afiliacion_id, 
                  d.titularfamilia_id ,
                  cn.tipoPlan, 
                  (SELECT obtener_edad(e.fechanacimiento, '2025-02-01')) AS edad,
                  (SELECT descripcion FROM rangos_edad WHERE (SELECT obtener_edad(e.fechanacimiento, '2025-02-01'))  BETWEEN edad_minima AND edad_maxima) AS rangoEdad,
                  s.codigo AS tipoVenta, 
                  e.discapacitado, 
                  (SELECT numero FROM contrato WHERE id = a.antiguedad_id) as antiguedad, 
                  (SELECT afiliacion_id 
                          FROM declaracionembarazo 
                          WHERE 
                          '2025-02-01' BETWEEN fechainiciocobertura AND fechafincobertura 
                          AND afiliacion_id =d.afiliacion_id 
                   ) AS declaracionEmbarazo, 
                   d.codigoGrupo, 
                   (SELECT (codigo || ' ' || nombre || CASE WHEN monto IS NULL THEN '' ELSE '-' || CAST(monto AS VARCHAR) END) FROM servicio WHERE id = d.servicio_id) AS codigo, 
                   d.activo, 
                   d.valorcomision, 
                   o.modalidadCobro AS formaPago, 
                   CASE WHEN true THEN
                   (SELECT buscar_nombre_supervisor(o.sede,ac.usuario_id)) ELSE 
                   (SELECT nombresupervisor FROM datos_supervisor_desde_comision('2025-02-01',ac.id)) END AS supervisor, 
                   cn.plan, 
                   cn.nivel, 
                   c.codigotarifario, 
                   c.fechainicio, 
                   e.fechanacimiento, 
                   rpc.fechapago AS fechaCaja,
                   ac.fechaingreso AS fechaIngresoAsesorComercial, 
                   (SELECT clave FROM entrada WHERE id = ac.tipousuario_id) AS tipoAsesorComercial, 
                   A.estadoafiliacion, 
                   d.valor AS valorCobertura, 
                   (SELECT nombreplan FROM nivel WHERE id = c.nivel_id) AS nombrePlan, 
                   CASE WHEN r.valorReingreso IS NULL THEN 0.0 ELSE r.valorReingreso END, 
                   sv.sancion_id AS sancion, 
                   d.preciocompra, 
                   ti.nombre AS tipoIdentificacion, 
                   A.fechaInicio AS fechaInicioAfiliacion, 
                   e.lugarTrabajo AS lugarTrabajoAfiliado, 
                   c.fechaPago AS fechaPagoContrato, 
                  case when e.genero ='F' then 'FEMENINO' 
                       when e.genero ='M' then 'MASCULINO' 
                       else ''
                  END as genero, 
                 etp.nombre AS asesorPropietario, 
                 eap.nombre AS aprobador, 
                 case when (select se_paga_comision_por_reingreso( 
                                                                              s.codigo, 
                                                                              CAST((ar.fechaexclusion - ar.fechainicioafiliacion) AS integer), 
                                                                              CAST(DATE_PART('day', (now() - (ar.fechapago + interval '1 month'))) AS integer), 
                                                                              ar.fechaexclusion, 
                                                                              a.fechaInicio, 
                                                                              c.numero) 
                                                               ) then 'SI' else 'NO' end as sePagaComisionReingreso, 
               pm.monto as montoPlanMedico 
            FROM obligacion o
                   LEFT JOIN detalle d ON d.obligacion_id = o.id 
                   LEFT JOIN afiliacion A ON A.ID = d.afiliacion_id 
                   LEFT JOIN entidad e ON e.ID = A.afiliado_id
                   LEFT JOIN tipoidentificacion ti ON ti.id = e.tipoidentificacion_id 
                   LEFT JOIN contrato c ON c.id = CASE WHEN A.contrato_id IS NULL THEN o.contrato_id ELSE A.contrato_id END  
                   LEFT JOIN planmedico pm on pm.codigo = c.planmedico 
                   LEFT JOIN familia f ON f.id = A.familia_id 
                   LEFT JOIN contratoNivel cn ON cn.contrato_id = c.id 
                   LEFT JOIN servicio s ON s.id = o.servicio_id 
                   LEFT JOIN asesorcomercial ac ON ac.id = o.comisionista_id 
                   LEFT JOIN usuario u on ac.usuario_id = u.id 
                   LEFT JOIN (SELECT * FROM calculo_reingreso('2025-02-01'))  
                     r ON r.contrato = c.numero and r.familia = (CASE WHEN c.tipoContrato = 'C' THEN f.numero ELSE 0 END) and r.afiliacion = a.numero  
                   LEFT JOIN 
                            LATERAL (SELECT fechapago,contratoid,fechaproduccion,numerosolicitud
                            FROM registropagocaja
                            WHERE contratoid = c.id
                            AND fechaproduccion = '2025-02-01'
                            AND numerosolicitud = (CASE WHEN o.numerosolicitud IS NOT NULL THEN o.numerosolicitud ELSE a.numerosolicitud END) LIMIT 1) rpc
                   ON rpc.contratoid = c.id 
                   AND rpc.fechaproduccion = '2025-02-01' 
                   AND rpc.numerosolicitud = (CASE WHEN o.numerosolicitud IS NOT NULL THEN o.numerosolicitud ELSE a.numerosolicitud END) 
                   LEFT JOIN solicitudvinculacion sv ON c.id = sv.contratoid AND sv.numerosolicitud = o.numerosolicitud 
                   LEFT JOIN asesorcomercial ap ON ap.id = o.asesorpropietarionivel 
                   LEFT JOIN usuario up ON up.id = ap.usuario_id 
                   LEFT JOIN entidad etp ON etp.id = up.entidad_id 
                   LEFT JOIN usuario uap ON uap.id = a.aprobadorid 
                   LEFT JOIN entidad eap ON eap.id = uap.entidad_id 
                   LEFT JOIN LATERAL ( 
                               SELECT 
                                       ar.afiliado_id , 
                                                                ar.contrato_id , 
                                                                ca.fechapago, 
                                                                ca.fechainicio, 
                                                                ar.fechainicio AS fechainicioafiliacion, 
                                                                ar.fechaexclusion, 
                                                                           ca.numero, 
                                                                ROW_NUMBER() OVER (PARTITION BY ar.afiliado_id ORDER BY ca.fechapago DESC) AS ROW_NUMBER 
                                                         FROM afiliacion ar 
                                                         LEFT JOIN contrato ca ON ca.id = ar.contrato_id 
                                                         WHERE ar.estadoafiliacion = 'EXC' 
                                                               ) ar ON ar.afiliado_id = a.afiliado_id AND ar.ROW_NUMBER = 1 AND ar.contrato_id <> a.contrato_id 
                            WHERE
                   o.fechapagocomision = '2025-02-01' 
                   AND d.codigogrupo <> 'IMP'


--  21229 rows


select * from entidad where numero = '1711152791'

select * from contrato where numero = 518888

select * from entrada where clave = 'DIRECCION_IP_WEBSERVICES_MAILER'
