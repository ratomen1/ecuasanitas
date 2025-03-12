select * from contrato where id = 2008742;

select * from afiliacion where contrato_id = 2008742;

select * from familia where id in (
select familia_id from afiliacion where contrato_id = 2008742)

select * from coberturacontratada where contrato_id = 2008742;

select * from obligacion where contrato_id = 2007234

select numerofamilias,* from contrato where numero = 607634

select * from familia where id in (
select familia_id from titular where contrato_id = 2008372
    ) order by numero

select * from documentacionasesor where id = 108393

select * from audit.documentacionasesor_aud where id = 108394


select * from documentacionasesor where id = 108394

-- rechazar
select * from contrato where numero = 607962

select * from afiliacion where contrato_id = 2008710

select * from coberturacontratada where contrato_id = 2008710

select * from preventaweb where id = 157656

-- rechazar
select * from afiliacion where contrato_id = 2008753

select * from coberturacontratada where contrato_id = 2008753

select * from documentacionasesor where id = 167565

INSERT INTO public.documentacionasesor (id, activo, esmasiva, estadodocumentacionasesor, fechacreacion, fechafacturacion, fechaproceso,
                                        numerocontrato, numerosolicitud, observacion, recibo, sede, servicio, tipoprocesodocumentacionasesor, asesorcomercial_id,
                                        familia_id, usuario_id, usuariofacturacion_id, usuarioiniciavinculacion_id, usuariorechaza_id) VALUES (
                                                                                                                                                  167565, true, false, 'FIN', '2024-12-03 16:25:20.875000',
'2025-03-06 00:00:00.000000', '2025-03-07 14:43:40.106000', null, 161333,
'error en N de recibo Editado desde anular orden', '', 'SANTO DOMINGO', 'VN',
'TRF', 1934, null, 1934, 5779, null, 1891);


select * from solicitud where numero = 167565

select * from registropagocaja where numerosolicitud = 167565

select * from preventaweb where id in (157694,157697)

select * from solicitudvinculacion where contratoid = 2008372 order by 1 desc

select * from solicitudvinculacion where numerosolicitud = 167565




