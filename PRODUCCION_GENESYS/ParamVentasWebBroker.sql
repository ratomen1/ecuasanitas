-- Lista los niveles que están vigentes para las ventas web
-- Esta consulta selecciona todos los registros de la tabla 'plan' donde el campo 'limitecomercializacion' es mayor que la fecha y hora actual.
SELECT * FROM plan WHERE limitecomercializacion > NOW();

-- En la tabla 'nivelesnoaplica' se registran los niveles que no aplican promociones
-- Esta consulta selecciona todos los registros de la tabla 'nivelesnoaplica' y los ordena en orden descendente por la primera columna.
SELECT * FROM nivelesnoaplica ORDER BY 1 DESC;

-- En la tabla 'planbroker' se registran los planes que se pueden vender por web siempre y cuando se ingrese el código del broker
-- Esta consulta selecciona todos los registros de la tabla 'planbroker' y los ordena en orden descendente por la primera columna.
SELECT * FROM planbroker ORDER BY 1 DESC;