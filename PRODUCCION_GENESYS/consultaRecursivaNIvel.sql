
-- Consulta recursiva para buscar un ID específico en la tabla 'nivel' y verificar si existe un padre con un ID específico.
WITH RECURSIVE nivelrecursivo AS (
    SELECT id, nombre, padre_id,
           CASE WHEN padre_id = 4299 THEN true ELSE false END AS found
    FROM nivel
    WHERE id = 332
    UNION
    SELECT n.id, n.nombre, n.padre_id,
           CASE WHEN n.padre_id = 4299 THEN true ELSE nr.found END
    FROM nivel n
             JOIN nivelrecursivo nr ON n.id = nr.padre_id
)
SELECT CASE WHEN COUNT(*) > 0 THEN true ELSE false END AS found
FROM nivelrecursivo
WHERE found = true;