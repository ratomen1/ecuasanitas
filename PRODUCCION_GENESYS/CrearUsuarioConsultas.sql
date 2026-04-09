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


--
-- ajustar para que pueda hacer selectes

-- Otorgar conexión a la base de datos
GRANT CONNECT ON DATABASE "PRUEBAS_GENESYS" TO consultas;

-- Otorgar uso en todos los esquemas existentes
GRANT USAGE ON SCHEMA public TO consultas;

-- Otorgar permisos de SELECT en todas las tablas existentes
GRANT SELECT ON ALL TABLES IN SCHEMA public TO consultas;

-- Establecer permisos por defecto para tablas futuras
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT SELECT ON TABLES TO consultas;

-- Revocar permisos de modificación y eliminación
REVOKE INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public FROM consultas;

-- Establecer permisos por defecto para evitar modificaciones en tablas futuras
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    REVOKE INSERT, UPDATE, DELETE ON TABLES FROM consultas;

-- Confirmar permisos
COMMENT ON ROLE consultas IS 'Usuario de solo lectura para PRUEBAS_GENESYS';