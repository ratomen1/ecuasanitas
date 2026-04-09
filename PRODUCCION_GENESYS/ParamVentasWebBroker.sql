-- Lista los niveles que están vigentes para las ventas web
-- Esta consulta selecciona todos los registros de la tabla 'plan' donde el campo 'limitecomercializacion' es mayor que la fecha y hora actual.
SELECT * FROM plan WHERE limitecomercializacion > NOW();

-- En la tabla 'nivelesnoaplica' se registran los niveles que no aplican promociones
-- Esta consulta selecciona todos los registros de la tabla 'nivelesnoaplica' y los ordena en orden descendente por la primera columna.
SELECT * FROM nivelesnoaplica ORDER BY 1 DESC;

-- En la tabla 'planbroker' se registran los planes que se pueden vender por web siempre y cuando se ingrese el código del broker
-- Esta consulta selecciona todos los registros de la tabla 'planbroker' y los ordena en orden descendente por la primera columna.
SELECT * FROM planbroker ORDER BY 1 DESC;

SELECT * FROM plan where id in (4527,4528,4529)-- POOL UNIDADES EDUCATIVAS PRIVADAS, MUNICIPALES Y FISCO MISIONALES 15.000 N5

SELECT * FROM nivelesnoaplica ORDER BY 1 DESC;  --3043

SELECT * FROM planbroker where plan_id in (4527,4690) ORDER BY 1 DESC;

SELECT * FROM planbroker order by 1 desc  --109

SELECT * FROM plan where nombre ilike '%educaci%' and limitecomercializacion > now() order by 1 desc;

select * from asesorcomercial order by 1 desc

SELECT * FROM nivelesnoaplica where nivel = '4690'


<ul><li>Deducible Anual por Persona $140</li><li>Monto máximo consulta médica: USD $60</li><li>Coberturas: Ambulatoria 80% Nivel del plan / Coberturas: Hospitalaria 90% Nivel del plan</li></ul>
