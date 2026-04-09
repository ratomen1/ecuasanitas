-- Ver todas las columnas de la tabla detalle
SELECT
    column_name,
    data_type,
    character_maximum_length,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'detalle'
ORDER BY ordinal_position;

-- Ver solo columnas de tipo fecha
SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'detalle'
  AND data_type IN ('date', 'timestamp', 'timestamp without time zone', 'timestamp with time zone')
ORDER BY ordinal_position;

