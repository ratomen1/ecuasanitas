
select * from diagnostico where validar_carencia = true

select * from preexistencia where diagnosticoid in (
select id from diagnostico where validar_carencia = true)


select * from preexistencia where afiliacion_id in (
select distinct(afiliacion_id) from detalle where obligacion_id in (
select id from obligacion where fechapagocomercial = '2026-03-01')
and afiliacion_id is not null and diagnosticoid in (select id from diagnostico where validar_carencia = true))

select ID,nombre,numero,discapacitado,condicioncedulado from entidad where id in (737835,
737904,
737916,
737923,
645511,
737872,
737996,
620258,
694871,
738332)

select * from entidad where id in (727128,736019,736035,736134)

select * from diagnostico where codigo ilike '%z91%'


