

select * from preexistencia where diagnosticoid in (
select id from diagnostico where validar_carencia = true)


select * from preexistencia where afiliacion_id in (
select distinct(afiliacion_id) from detalle where obligacion_id in (
select id from obligacion where fechapagocomercial = '2025-12-01')
and afiliacion_id is not null and diagnosticoid in (select id from diagnostico where validar_carencia = true))

select ID,nombre,numero,discapacitado,condicioncedulado from entidad where id in (701209,735106,735186)


