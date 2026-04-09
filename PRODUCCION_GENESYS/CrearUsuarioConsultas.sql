-- Crear usuario de solo lectura
CREATE USER consultas WITH PASSWORD '1234';

-- Otorgar conexión a la base de datos
GRANT CONNECT ON DATABASE "genesys" TO consultas;

-- Otorgar uso en todos los esquemas existentes
GRANT USAGE ON SCHEMA public TO consultas;

-- Otorgar permisos de SELECT en todas las tablas existentes
GRANT SELECT ON ALL TABLES IN SCHEMA public TO consultas;

-- Establecer permisos por defecto para tablas futuras
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT SELECT ON TABLES TO consultas;

-- Confirmar permisos
COMMENT ON ROLE consultas IS 'Usuario de solo lectura para GENESYS';