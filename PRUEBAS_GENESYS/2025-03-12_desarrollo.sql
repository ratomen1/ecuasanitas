select * from solicitud order by 1 desc

select * from solicitud where numero = 124568

select * from comision where fechainicioproduccion = '2025-01-01'

select * from comision where id in (
                                    20221,
                                    20222,
                                    20223,
                                    20224,
                                    20225,
                                    20226,
                                    20227,
                                    20228,
                                    20229,
                                    20230,
                                    20231,
                                    20232)


select * from entidad where numero = '1725258915'

INSERT INTO public.entidad (tipoentidad, id, email, fecharegistro, activa, numero, nombre, fechaconstitucion, tipoorganizacion, discapacitado, estadocivil, fechanacimiento, genero, lugartrabajo, numerocarnetdiscapacidad, primerapellido, primernombre, segundoapellido, segundonombre, domicilio_id, tipoidentificacion_id, tipodiscapacidad_id, activo, esempleado, fechaultimamodificacion, esasociado, verificado, condicioncedulado, esextranjero) VALUES ('N', -716196, 'dauz@praxmed.com.ec', null, null, '1725258915', 'AUZ ALVAREZ DAYANARA GISSELA', null, null, false, 'DI', '1993-11-24', 'F', null, null, 'AUZ', 'DAYANARA', 'ALVAREZ', 'GISSELA', null, 1, null, true, true, '2025-03-12 11:51:36.406000', false, true, 'CIUDADANO', false);



