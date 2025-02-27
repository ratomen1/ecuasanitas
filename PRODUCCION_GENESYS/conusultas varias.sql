select numerosolicitud,* from contrato where numero = 605432;  -- 2006183

select numerosolicitud,* from afiliacion where contrato_id= 2006183;

SELECT numerosolicitud,* FROM coberturacontratada WHERE contrato_id = 2006183;

select * from solicitud where numero = 108330;

select * from registropagocaja where numerosolicitud = 108330;

select * from solicitudvinculacion where numerosolicitud in (108330,-108330);

select * from solicitudvinculacion where contratoid = 2006183;

select * from solicitudvinculacion where contratoid = 2006183;

select * from autorizacioncobro where contrato_id = 1943801;

select * from entidad where id = 552441;

SELECT * FROM plan WHERE id IN (4302,4303,4304);

SELECT * FROM nivelesnoaplica ORDER BY 1 DESC;

SELECT * FROM planbroker ORDER BY 1 DESC;

select * from documentacionasesor where id = 108331; -- 241821

SELECT * FROM nivel WHERE id = 0;

select * from afiliacion where id in (

                                      190007310218688,
                                      190007310214159,
                                      190007310214159,
                                      190007310219312,
                                      190007310219312,
                                      190007310211638,
                                      190007310211638,
                                      190007310204688,
                                      190007310204688,
                                      190007310201923,
                                      190007310201923,
                                      190007310219317,
                                      190007310219317,
                                      190007310201928,
                                      190007310201928,
                                      190007310218457,
                                      190007310218457,
                                      190007310219722,
                                      190007310219722,
                                      190007310221097,
                                      190007310221097,
                                      190007310218455,
                                      190007310218455,
                                      190007310214151,
                                      190007310214151,
                                      190007310214150,
                                      190007310214150,
                                      190007310223125,
                                      190007310223125,
                                      190007310211702

    );

select * from documentacionasesor order by 1 desc

select * from preventaweb where contratorepresentacion ilike '%0930103395%'

select * from entrada where valor = 'd30d182d-67e6-439f-98c8-238382e87381'

select * from ventawebincompleta order by 1 DESC

select * from documentacionasesor where id = 108334;  --  605204

SELECT * FROM asesorcomercial WHERE id = 2989;


SELECT * FROM asesorcomercial WHERE id = 2989;

select * from nivel where id = 334;

select * from documentacionasesor where id = 108337; -- 605204

select * from audit.documentacionasesor_aud where id = 108345;

select * from audit.documentacionasesor_aud where id = 108337;


select * from documentacionasesor where id = 1298523;

select * from audit.documentacionasesor_aud where id = 1298523;

select * from InconsistenciaDocumentacionAsesor order by 1 desc

select * from contrato c where c.numero = 601914;

select * from titular where contrato_id = 2002658;

select * from afiliacion where familia_id in (
    select titular.familia_id from titular where contrato_id = 2002658
    ) and numerosolicitud = 1298480 and estadoafiliacion = 'REG';

select * from familia where id in (
    190007473699,
        190007473703,
190007473700,
190007473701,
190007473702,
190007473778,
190007473774,
190007473775,
190007473776,
190007468503,
190007468503,
190007473777
    ) and numerosolicitud = 1298480;

select * from coberturacontratada WHERE familia_id in (
                                                       190007473699,
                                                       190007473700,
                                                       190007473701,
                                                       190007473702,
                                                       190007473703,
                                                       190007473774,
                                                       190007473775,
                                                       190007473776,
                                                       190007473777,
                                                       190007473778
    ) and numerosolicitud = 1298480;


SELECT * FROM entrada where catalogo_id = 199;

Se utiliza en el proyecto genesys-api en la clase ContratoResourcePlaceToPay en el metodo crearSuscripcion para controlar que una preventa se ejecute dos veces.

select * from afiliacion where familia_id = 190007468503;

select * from coberturacontratada where afiliacion_id in (190007310228885,
    190007310228884
    );

select * from afiliacion where contrato_id = 2002658  and estadoafiliacion = 'REG';

select * from ducumentacion where id = 108343;   --

select * from documentacionasesor where id = 108343; --605498

select * from documentacionasesor where id = 108336; --561498



select * from documentacionasesor order by 1 desc

select * from contrato where numero = 605738;

select * from afiliacion where contrato_id = 2006499;

select * from coberturacontratada where contrato_id = 2006499;

select * from asesorcomercial where codigo = '1002';

select * from supervision where supervisado_id = 4394;

select * from rolusuario where usuario_id = 4394;

select contrato.sede_id,vendedor_id,comisionista_id,* from contrato where numero = 605334;

select * from documentacionasesor where id = 108339;  --605492

select * from documentacionasesor where id = 108251;  --5954

select * from documentacionasesor where id = 108335;  --602220 jose

select * from documentacionasesor where id = 108251;  --605867 jose


select * from contrato where numero = 601914;

select * from afiliacion where contrato_id = 2002658;

select * from familia where id in (
select familia_id from titular where contrato_id = 2002658
    ) order by numero

select * from afiliacion where familia_id in (
    190007473699,
        190007473700,
190007473701,
190007473702,
190007473703,
190007473774,
190007473775,
190007473776,
190007473777,
190007473778);

select * from coberturacontratada where familia_id in (
                                                       190007473699,
                                                       190007473700,
                                                       190007473701,
                                                       190007473702,
                                                       190007473703,
                                                       190007473774,
                                                       190007473775,
                                                       190007473776,
                                                       190007473777,
                                                       190007473778
    );


select * from plan where nombre ilike '%POOL COLEGIO DE ABOGADOS DE PICHINCHA $ 10,000%';

select id,descripcion,llave from coordenadascontrato order by 1 desc

select * from asesorcomercial where codigo = '999992';

select * from supervision where supervisor_id = 5250;

select * from contrato where numero = 605877;

select * from afiliacion where contrato_id = 2006637;

select * from coberturacontratada where contrato_id = 2006637;

select * from preventaweb where contratorepresentacion ilike '%1727094490%';

select * from documentacionasesor where id = 108351; -- 156305

SELECT * FROM afiliacion a WHERE a.id IN (190007310100325,190007310100326)

190007310100325 -- 621823  -- nuevo 711228
190007310100326 -- 621824  -- nuevo 711210

select * from entidad where id in (621823,621824,711228,711210);

select * from audit.entidad_aud where id = 621824;



select * from entidad where numero = '1800146803'

select * from afiliacion where afiliado_id = 29083

select * from preventaweb where numerocontrato = 605353

select sede_id,* from contrato where numero = 605812

SELECT
    *
FROM sede s
left join divisionterritorial dt on dt.id = s.divisionterritorial_id


select * from tablacomision where definicioncomision_id= 218

select * from rangocomision where tablacomision_id = 154

select * from asesorcomercial where id = 3546

select * from autorizacioncomision order by 1 desc

select * from audit.autorizacioncomision_aud where id = 776


select * from documentacionasesor where id = 1298796

select * from contrato where numero = 605587

select * from afiliacion where contrato_id = 2006347;

select * from audit.contrato_aud where id = 2006347;

select * from coberturacontratada where contrato_id = 2006347;

select * from audit.afiliacion_aud where afiliacion_aud.contrato_id = 2006347;

select * from audit.coberturacontratada_aud where contrato_id = 2006347;

select * from OrdenRecaudacionDebitoTerceroPlaceToPay where id = 108 order by 1 desc --  108 GENERADO

select * from DetalleOrdenRecaudacionDebitoTerceroPlaceToPay where ordenrecaudaciondebitoterceroplacetopay_id = 108 order by 1 desc;

select * from OrdenRecaudacionDebitoTercero where id = 139;

select * from DetalleOrdenRecaudacionDebitoTercero  WHERE ordenrecaudaciondebitotercero_id= 139 order by 1 desc


select * from receivablesReferencia

select * from registro_login order by 1 desc

SELECT
    tc.table_name,
    kcu.column_name
FROM
    information_schema.table_constraints AS tc
        JOIN information_schema.key_column_usage AS kcu
             ON tc.constraint_name = kcu.constraint_name
WHERE
    tc.constraint_name = 'uk_sjik2h9p6l9rkkhphowil69rk';

update DetalleOrdenRecaudacionDebitoTerceroPlaceToPay set payeremail = 'geomateolol@gmail.com'

select * from entrada where clave = 'DIRECCION_IP_WEBSERVICES_MAILER';




SELECT
    pm.codigo,
    e.nombre
FROM anexopromocionplanmedico apm
left join planmedico pm on pm.id = apm.planmedico_id
left join entrada e on e.id = apm.anexo_id
WHERE e.nombre ilike '%BIENESTAR%';



select * from entrada order by 1 desc

select * from catalogo order by 1 desc



select * from OrdenRecaudacionDebitoTercero where id = 9;

select * from DetalleOrdenRecaudacionDebitoTercero where ordenrecaudaciondebitotercero_id = 9 and id = 27630 order by 1 desc -- GENERADO  --ACTIVO

UPDATE DetalleOrdenRecaudacionDebitoTercero SET correoelectronico = 'geomateolol@gmail.com'


select * from contrato where numero = 565447

select * from documentacionfisica where tipodocumento_id = 103825 and numerocontrato = 605539 order by 1 desc

select * from entrada where catalogo_id = 204;

SELECT
    df.usuario_id,
    u.nombre,
    count(*) as total
FROM documentacionfisica df
left join usuario u on u.id = df.usuario_id
WHERE df.tipodocumento_id = 103825
AND df.activo = TRUE
GROUP BY df.usuario_id, u.nombre
order by 3 desc

SELECT
    *
FROM documentacionfisica df
WHERE df.tipodocumento_id = 103825
  AND df.activo = TRUE
    AND df.usuario_id = 4742
order by 1 desc

select * from registro_login

select * from detalle_registro_login

select * from plantilla_detalle_registro_login

select * from entrada where catalogo_id = 211;

VALIDAR_CONDICIONES_USO

PORTAL_WEB

select
             entrada0_.id as id1_430_,
                 entrada0_.activo as activo2_430_,
                 entrada0_.catalogo_id as catalogo8_430_,
                 entrada0_.clase as clase3_430_,
                 entrada0_.clave as clave4_430_,
                 entrada0_.nombre as nombre5_430_,
                entrada0_.padre_id as padre_id9_430_,
                 entrada0_.prioridad as priorida6_430_,
                 entrada0_.valor as valor7_430_
     from
             Entrada entrada0_ cross
         join
             Catalogo catalogo1_
         where
             entrada0_.catalogo_id=catalogo1_.id
             and catalogo1_.clave='PORTAL_WEB'
             and entrada0_.clave='VALIDAR_CONDICIONES_USO'
            and entrada0_.activo=true limit 1

select * from entrada where clave = 'VALIDAR_CONDICIONES_USO'

select * from catalogo where clave = 'PORTAL_WEB'

select * from catalogo where id = 211


INSERT INTO public.promocionweb (id, desde, hasta, nombre, tipo, valor, cantidad, tiposervicio, ticket, estado_ticket, montominimo) VALUES (38, '2025-01-13 00:00:00.000000', '2025-01-17 23:59:59.000000', 'PROMOCION 50% DSCTO.', 'PORCENTAJE', 50, 0, 'CN', 0, 0, 0.00);

select * from promocionweb order by 1 desc

select esextranjero,* from afiliacion limit 50

select * from entidad limit 5

select * from preventaweb where id > 151084 ORDER BY 1 desc

select * from accion where url ilike '%GeneradorCodigos.xhtml%'

select * from promocionweb order by 1 desc

select * from entidad where numero = '1103506562'

select * from afiliacion where afiliado_id=579474

select * from coberturacontratada where contrato_id=2007138


SELECT rol, entidad_id, contrato_id, email, c.correo FROM (
                                                              SELECT DISTINCT 'CONTRATANTE' AS rol, t.entidad_id AS entidad_id, t.contrato_id AS contrato_id, e.email AS email
                                                              FROM Titular t
                                                                       JOIN Entidad e ON e.id = t.entidad_id
                                                              WHERE e.numero = '1715068183' AND t.FAMILIA_ID IS NULL
                                                              UNION
                                                              SELECT DISTINCT 'TITULAR_FAMILIA', t.entidad_id, t.contrato_id, e.email AS email
                                                              FROM Titular t JOIN Entidad e ON e.id = t.entidad_id
                                                              WHERE e.numero = '1715068183' AND t.familia_id IS NOT NULL
                                                              UNION
                                                              SELECT DISTINCT 'AFILIADO', a.afiliado_id, a.contrato_id, e.email AS email
                                                              FROM Afiliacion a JOIN Entidad e ON e.id = a.afiliado_id
                                                              WHERE e.numero = '1715068183'
                                                          ) roles JOIN Contrato c ON c.id = contrato_id
WHERE c.numero = 585916;

select DISTINCT rol,entidad_id from(
SELECT DISTINCT 'CONTRATANTE' AS rol, t.entidad_id AS entidad_id, t.contrato_id AS contrato_id, e.email AS email
FROM Titular t
         JOIN Entidad e ON e.id = t.entidad_id
WHERE e.numero = '1715068183' AND t.FAMILIA_ID IS NULL
UNION
SELECT DISTINCT 'TITULAR_FAMILIA' AS rol, t.entidad_id, t.contrato_id, e.email AS email
FROM Titular t JOIN Entidad e ON e.id = t.entidad_id
WHERE e.numero = '1715068183' AND t.familia_id IS NOT NULL
UNION
SELECT DISTINCT 'AFILIADO' AS rol, a.afiliado_id, a.contrato_id, e.email AS email
FROM Afiliacion a JOIN Entidad e ON e.id = a.afiliado_id
WHERE e.numero = '1715068183') roles;

select coalesce(email, '') as email from entidad where numero = '1715068183'

select * from entidad where numero = '1715068183'

select * from plantilla_detalle_registro_login

select * from entrada order by 1 desc

select * from entidad where numero = '1309935284'

select * from afiliacion where afiliado_id = 709117

select * from contrato where id = 2005806



select * from documentacionasesor where id in (1292190,1298888)

select * from entidad where numero = '1103506562'

select * from afiliacion where afiliado_id = 579474

select * from registro_login order by 1 desc

select * from detalle_registro_login order by 1 desc

select * from plantilla_detalle_registro_login

select * from cuotapendiente order by 1 desc

select contratorepresentacion from preventaweb where id = 151098

select * from preventaweb order by 1 desc

select * from preventaweb where id = 151096


select * from entrada order by 1 desc limit 10

select * from promocionweb order by 1 desc

select * from cuotapendiente order by 1 desc

select * from contrato where numero = 606377

select * from afiliacion where contrato_id = 2007140

select * from coberturacontratada where contrato_id = 2007140

select * from registro_login order by 1 desc

select * from detalle_registro_login WHERE registro_login_id = 406

select * from cuotapendiente order by 1 desc

SELECT *
FROM detalleordenrecaudaciondebitoterceroplacetopay
WHERE ordenrecaudaciondebitoterceroplacetopay_id = 111
  AND estado = 'REJECTED'

select * from ordenrecaudaciondebitoterceroplacetopay order by 1 desc

select * from detalleordenrecaudaciondebitoterceroplacetopay

--update detalleordenrecaudaciondebitoterceroplacetopay set correoelectronico = 'geomateolol@gmail.com', payeremail = 'geomateolol@gmail.com'

select * from detalleordenrecaudacion

--update detalleordenrecaudacion set email = 'geomateolol@gmail.com'

select * from ordenrecaudaciondebitoterceroplacetopay order by 1 desc

SELECT c.numero AS contrato,
       e.nombre AS titular,
       e.email  AS correoelectronico
FROM detalleordenrecaudaciondebitoterceroplacetopay dp
         LEFT JOIN contrato c ON c.numero = dp.contrato
         LEFT JOIN titular tc ON tc.contrato_id = c.id AND tc.familia_id IS NULL
         LEFT JOIN entidad e ON e.id = tc.entidad_id
WHERE dp.ordenrecaudaciondebitoterceroplacetopay_id = 111
  AND dp.estado = 'REJECTED'
  AND tc.familia_id IS NULL
  AND rechazo_anterior IS NULL

--940
 select * from entidad limit 5

select * from DetalleOrdenRecaudacionDebitoTercero order by 1 desc

SELECT c.numero AS contrato,
       e.nombre AS titular,
       e.email  AS correoelectronico
FROM DetalleOrdenRecaudacionDebitoTercero dp
         LEFT JOIN contrato c ON c.numero = dp.contrato
         LEFT JOIN titular tc ON tc.contrato_id = c.id AND tc.familia_id IS NULL
         LEFT JOIN entidad e ON e.id = tc.entidad_id
WHERE dp.ordenrecaudaciondebitotercero_id = 142
  AND dp.estado = 'DECLINADO'
  AND tc.familia_id IS NULL



select * from detalleordenrecaudaciondebitotercero order by 1 desc

select * from ordenrecaudaciondebitotercero order by 1 desc

select * from plan where nombre ilike '%ELEGIR PLUS Cobertura anual $100.000 NIVEL 5%' and limitecomercializacion > now()

select * from contrato where numero = 604410

SELECT f.*
FROM titular t
left join familia f on f.id = t.familia_id and t.familia_id is not null
WHERE t.contrato_id = 2005157
and f.numero = 32

select * from afiliacion where familia_id = 190007471742

select * from entidad

update entidad set email = 'geomateolol@gmail.com' where email is not null


select * from entidad where numero = '0953380045'

select * from comision order by 1 desc












