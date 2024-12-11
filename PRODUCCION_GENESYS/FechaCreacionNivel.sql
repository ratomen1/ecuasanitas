SELECT
    n.id,  -- Selecciona el ID del nivel
    (CASE
        WHEN n.activo IS NULL THEN 'NO'  -- Si el campo 'activo' es NULL, devuelve 'NO'
        ELSE CASE
            WHEN n.activo IS TRUE THEN 'SI'  -- Si el campo 'activo' es TRUE, devuelve 'SI'
            ELSE 'NO'  -- Si el campo 'activo' es FALSE, devuelve 'NO'
        END
    END) AS activo,  -- Alias para el resultado del CASE
    aud.timestamp AS fechacreacion,  -- Selecciona la fecha de creación del nivel desde la tabla de auditoría
    n.nombreplan,  -- Selecciona el nombre del plan
    n.nombre,  -- Selecciona el nombre del nivel
    t.codigo AS codigotarifario,  -- Selecciona el código tarifario
    (CASE
        WHEN pm.codigoplanmedicoconcarencia IS NULL THEN pm.codigoplanmedicosincarencia  -- Si el código del plan médico con carencia es NULL, selecciona el código del plan médico sin carencia
        ELSE pm.codigoplanmedicoconcarencia  -- Si no, selecciona el código del plan médico con carencia
    END) AS pmd  -- Alias para el resultado del CASE
FROM
    nivel n  -- Tabla principal 'nivel'
    LEFT JOIN tarifario t ON t.id = n.tarifario_id  -- Unión izquierda con la tabla 'tarifario' basada en el ID del tarifario
    LEFT JOIN condicion c ON c.id = n.condicion_id  -- Unión izquierda con la tabla 'condicion' basada en el ID de la condición
    LEFT JOIN (
        SELECT
            na.*,  -- Selecciona todos los campos de la tabla 'nivel_aud'
            r."timestamp",  -- Selecciona el timestamp de la tabla 'revision'
            ROW_NUMBER() OVER (PARTITION BY na.id ORDER BY r."timestamp" ASC) AS row_id  -- Asigna un número de fila basado en el ID del nivel y ordenado por timestamp
        FROM
            audit.nivel_aud na  -- Tabla de auditoría 'nivel_aud'
            LEFT JOIN audit.revision r ON r.id = na.rev  -- Unión izquierda con la tabla 'revision' basada en el ID de la revisión
    ) AS aud ON aud.id = n.id AND aud.row_id = 1  -- Unión izquierda con la subconsulta de auditoría basada en el ID del nivel y el número de fila
    LEFT JOIN (
        SELECT
            c.id,  -- Selecciona el ID de la condición
            item.codigoplanmedicoconcarencia,  -- Selecciona el código del plan médico con carencia
            item.codigoplanmedicosincarencia  -- Selecciona el código del plan médico sin carencia
        FROM
            condicion c  -- Tabla 'condicion'
            LEFT JOIN (
                SELECT
                    i.*,  -- Selecciona todos los campos de la tabla 'itemcondicionplanmedico'
                    ROW_NUMBER() OVER (PARTITION BY i.condicionplanmedico_id ORDER BY i.fechainicio DESC) AS row_id  -- Asigna un número de fila basado en el ID de la condición del plan médico y ordenado por fecha de inicio
                FROM itemcondicionplanmedico i  -- Tabla 'itemcondicionplanmedico'
            ) item ON item.condicionplanmedico_id = c.condicionplanmedico_id AND item.row_id = 1  -- Unión izquierda con la subconsulta de items basada en el ID de la condición del plan médico y el número de fila
    ) pm ON pm.id = c.id  -- Unión izquierda con la subconsulta de condiciones basada en el ID de la condición
WHERE
    n.comercializable = TRUE  -- Filtra los niveles que son comercializables
