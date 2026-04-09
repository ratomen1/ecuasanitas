select * from response_payment where id >= 44 order by 1 desc

select * from external_notification order by 1 desc

select * from documentacionasesor where id = 1300173

select * from solicitud

select * from solicitud where numero = 6588

select nivel_id,* from contrato where id = 2008719

select numero from entidad where numero in (
                                       '1713826426'
    )

SELECT de.afiliacion_id
FROM declaracionembarazo de
WHERE '2025-01-01' BETWEEN de.fechainiciocobertura AND de.fechafincobertura


select * from afiliacion where familia_id =190007331167

select * from entidad where id in (699897,699900)

select * from tipoidentificacion

SELECT
    CONCAT(a.id, '-', c.numero, '-', f.numero, '-', a.numero) AS afiliacion_contrato_familia_afiliacion
FROM afiliacion a
LEFT JOIN entidad e ON e.id = a.afiliado_id AND e.tipoidentificacion_id = 4
LEFT JOIN contrato c ON c.id = a.contrato_id
LEFT JOIN familia f ON f.id = a.familia_id
WHERE a.familia_id IN (SELECT DISTINCT familia_id
                       FROM afiliacion
                       WHERE id = 190007310214927)
AND a.id != 190007310214927
AND a.fechapagocomision = '2025-01-01'
AND e.tipoidentificacion_id = 4;

select * from afiliacion where familia_id = 190007463945

-- 190007310214927,  190007310230363, 190007310230364


WITH original_query AS (
    SELECT
        190007310214927 as id,
        concat(a.id,'-',c.numero,'-',f.numero,'-',a.numero) as afiliacion_contrato_familia_afiliacion
    FROM afiliacion a
             LEFT JOIN entidad e ON e.id = a.afiliado_id AND e.tipoidentificacion_id = 4
             LEFT JOIN contrato c ON c.id = a.contrato_id
             LEFT JOIN familia f ON f.id = a.familia_id
    WHERE a.familia_id IN (
        SELECT DISTINCT familia_id
        FROM afiliacion
        WHERE id = 190007310214927
    )
      AND a.id != 190007310214927
      AND a.fechapagocomision = '2025-01-01'
      AND e.tipoidentificacion_id = 4
)
SELECT afiliacion_contrato_familia_afiliacion,cast(id as text) FROM original_query
UNION ALL
SELECT '-','-' as afiliacion_contrato_familia_afiliacion
WHERE NOT EXISTS (SELECT 1 FROM original_query);


-- 24

--consulta 1
SELECT de.afiliacion_id
FROM declaracionembarazo de
WHERE '2025-01-01' BETWEEN de.fechainiciocobertura AND de.fechafincobertura

--consulta 2
select DISTINCT(familia_id) from afiliacion where id in (190007310217401,190007310231130,190007310214927)

--consulta 3
SELECT
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM afiliacion a
                     LEFT JOIN entidad e ON e.id = a.afiliado_id AND e.tipoidentificacion_id = 4
            WHERE a.familia_id IN (190007465688, 190007475455, 190007463945)
              AND a.id NOT IN (190007310217401, 190007310231130, 190007310214927)
              AND a.fechapagocomision = '2025-01-01'
              AND e.tipoidentificacion_id = 4
        ) THEN 'si'
        ELSE 'no'
        END AS resultado;



WITH
-- Primera consulta: Obtener afiliacion_ids con declaraciones de embarazo activas
afiliaciones_embarazo AS (
    SELECT de.afiliacion_id
    FROM declaracionembarazo de
    WHERE '2025-01-01' BETWEEN de.fechainiciocobertura AND de.fechafincobertura
),

-- Segunda consulta: Obtener familia_ids basados en los resultados de la primera consulta
familias AS (
    SELECT DISTINCT familia_id
    FROM afiliacion
    WHERE id IN (SELECT afiliacion_id FROM afiliaciones_embarazo)
),

-- Tercera consulta: Verifica si hay otras afiliaciones para estas familias
resultado_consulta AS (
    SELECT
        CASE
            WHEN EXISTS (
                SELECT 1
                FROM afiliacion a
                         LEFT JOIN entidad e ON e.id = a.afiliado_id AND e.tipoidentificacion_id = 4
                WHERE a.familia_id IN (SELECT familia_id FROM familias)
                  AND a.id NOT IN (SELECT afiliacion_id FROM afiliaciones_embarazo)
                  AND a.fechapagocomision = '2025-01-01'
                  AND e.tipoidentificacion_id = 4
            ) THEN 'si'
            ELSE 'no'
            END AS resultado
)

-- Combina los resultados de las tres consultas
SELECT
    array_agg(ae.afiliacion_id) AS afiliaciones_con_embarazo,
    array_agg(DISTINCT f.familia_id) AS familias_relacionadas,
    r.resultado
FROM afiliaciones_embarazo ae
         CROSS JOIN familias f
         CROSS JOIN resultado_consulta r
GROUP BY r.resultado;

select * from contrato where numero = 607281

select * from afiliacion where contrato_id =2008022

select * from preexistencia where afiliacion_id = 190007310233801

SELECT * FROM preexistencia

select * from diagnostico where validar_carencia = true

INSERT INTO public.preexistencia (id, diagnosticoid, fecharegistro, afiliado_id, codigodiagnostico, estado, activa, fechacreacion, fechadeclarada, fechadetectada, presentadeclaracion, afiliacion_id, padre_id, usuariodeclara_id, usuariodetecta_id, carencia) VALUES (-625825, 32069, '2025-03-06', 714751, 'F84.1', 'DECLARADA', true, '2025-03-06 11:32:58.669000', '2025-03-06 00:00:00.000000', null, true, 190007310233801, null, 4811, null, 'CON_CARENCIA');

SELECT * from promocionweb order by 1 desc

select * from entidad where numero= '1103506562'

select * from afiliacion where afiliado_id = 579474

SELECT * from promocionweb where id = 38

select * from afiliacion where contrato_id = 2008722

select * from familia where id in (
    190007481267,
        190007481266,
190007481265,
190007481264
    )

select * from coberturacontratada where contrato_id = 2008722

select * from titular where contrato_id = 2008722

select * from entrada where id = 550

select * from entrada where catalogo_id = 28

select * from afiliacion where parentesco_id = 550

select * from entidad where numero = '0601926025'

select * from entidad where numero = '1706955034'

select * from solicitud where numero = 124568


select * from afiliacion where afiliado_id = 579474

select * from preventaweb where id >= 157444

SELECT * from promocionweb where id in (38,39)

select * from promocionweb where hasta > now()

select * from preventaweb order by 1 desc

select * from ventawebincompleta ORDER BY 1 desc --  157451

select * from entidad where numero = '1103506562'

select * from afiliacion where afiliado_id = 579474

select * from preventaweb order by 1 desc

select * from documentacionasesor where id = 1300714

select * from audit.documentacionasesor_aud where id = 1300714

select * from entidad where numero = '1103506562'

select * from entidad where numero = '1722404041'

select * from afiliacion where afiliado_id = 579474

select * from entrada where nombre ilike '%mailer%'

select * from preventaweb order by 1 desc

select * from accion where nombre ilike '%(datos%'

select * from contrato  where estado = 'ACT' order by 1 desc

select * from contrato where numero = 608534

select * from titular where contrato_id = 2009299

select * from entidad where id = 32194

SELECT * from renovacioncorporativa order by 1 desc

select * from coordenadascontrato


select * from ventawebincompleta order by 1 desc




select * from declaracion_salud_ventas_web

select * from contrato where numero =  609211

select * from entidad where numero in ('1103506562','1722404041')

select * from afiliacion where afiliado_id in (579474,643737) and estadoafiliacion = 'ACT'

select * from declaracion_salud_ventas_web

select * from preventaweb where contratorepresentacion ilike '%0921976734%' order by 1 desc

select * from definicioncomision

select * from contrato where numero = 608683

select * from afiliacion where contrato_id = 2009437



UPDATE public.coordenadascontrato SET descripcion = 'ANEXO PROTECCION DATOS CONTRATO CORPORATIVO', estado = true, fechax = '160', fechay = '230', llave = 'PROTECCION_DATOS_CONTRATO_CORPORATIVO', numerohoja = '3', titularcontratox = '85', titularcontratoy = '160' WHERE id = -18;
UPDATE public.coordenadascontrato SET descripcion = 'CONTRATO ELEGIR GRUPAL NUEVO', estado = true, fechax = '160', fechay = '457', llave = 'CONTRATO_GEC', numerohoja = '4', titularcontratox = '85', titularcontratoy = '433' WHERE id = -8;

select * from coordenadascontrato where  id in (-8,-18)

SELECT *
FROM coberturacontratada
WHERE estadocoberturacontratada = 'ACT'
  and contrato_id <> 2008369
  AND codigoservicio ILIKE '%VS%'
  AND coberturaimplicita = FALSE
ORDER BY 1 DESC

select * from entidad where numero in ('1103506562','1722404041')

select * from afiliacion where afiliado_id in (579474,643737) and estadoafiliacion = 'ACT'

select * from codigos_generados where key = '808-1103506562' order by fecha_creacion desc

select * from codigos_generados order by fecha_creacion desc

select * from entidad where numero in ('1103506562','1722404041')

select * from afiliacion where afiliado_id in (579474,643737) and estadoafiliacion = 'ACT'

select * from preventaweb order by 1 desc

select * from codigos_generados order by 1 desc

select * from costo order by 1 desc

select * from rangocosto

select * from preventaweb order by 1 desc

select * from registro_declaracion_salud

select * from documentacionfisica order by 1 desc

select * from tarifario where id = 1924

select * from costo where tarifario_id = 1924

select * from rangocosto where costo_id in (select id from costo where tarifario_id = 1924)


select DISTINCT tarifario_id from costo where costo.desde = '2025-07-01' order by 1 desc

select * from costo where costo.desde = '2025-07-01' order by 1 desc


select * from costogenero where rangocosto_id in (select id from rangocosto where costo_id = 5668)


select * from tarifario WHERE codigo = '8711'

select * from costo WHERE tarifario_id = 3078 order by 1 desc

select * from rangocosto where costo_id = 5687

select * from costogenero where rangocosto_id in (select id from rangocosto where costo_id = 5687)


SELECT * from declaracion_salud_ventas_web

select * from promocionweb where hasta > now() order by 1 desc

select * from entidad where numero = '1711152791'

select * from afiliacion where afiliado_id = 10255




