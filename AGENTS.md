# AGENTS.md

## Descripción del Proyecto

Colección de scripts SQL (PostgreSQL) para la administración de bases de datos del sistema de medicina prepagada **Ecuasanitas**. Incluye consultas de producción, mantenimiento, reportes y operaciones en entornos de prueba. No es una aplicación ejecutable — es una librería de scripts operativos de DBA.

## Estructura del Repositorio

- `PRODUCCION_GENESYS/` — Scripts ejecutados contra la BD de producción `genesys`. Incluyen reportes, actualizaciones masivas, monitoreo, funciones PL/pgSQL y particionamiento.
- `PRUEBAS_GENESYS/` — Scripts para el entorno de pruebas. Incluyen rotación de bases de datos, sanitización de datos y consultas de desarrollo.
- `PRODUCCION_EVOUCHER/` — Operaciones con comprobantes electrónicos (XML via `lo_import`/`lo_export`).
- Raíz — Utilidades generales: test de conexión Python (`test_connection.py`), cambio de contraseñas, loops de comisiones.
- `temp/` — Archivos temporales del navegador, ignorar completamente.

## Base de Datos y Conexión

- **Motor**: PostgreSQL (conectar con `psycopg2` en Python).
- **Bases principales**: `genesys` (core del negocio), `luca` (facturación).
- **Usuarios**: `postgres` (admin), `genesys` (aplicación), `consultas` (solo lectura). Ver `CrearUsuarioConsultas.sql` para el patrón de creación de usuarios read-only.
- **Esquemas**: `public` (tablas de negocio), `audit` (tablas de auditoría con sufijo `_aud`), `dwh` (data warehouse), `irs` (facturación en Luca).

## Modelo de Datos — Entidades Clave

Las tablas siguen un modelo de negocio de medicina prepagada. Relaciones principales:

```
contrato → nivel → plan (plan médico)
contrato → titular → entidad (persona)
contrato → familia → afiliacion → entidad (afiliado)
afiliacion → coberturacontratada (coberturas activas)
obligacion → detalle (desglose de cobros)
comision → detallecomision → afiliacion (comisiones de ventas)
```

- **IDs**: Generados via tabla `generador` (no secuencias). Cada entidad tiene una fila: `SELECT valor FROM generador WHERE nombre = 'Costo'`. Después de insertar, actualizar el generador manualmente. Ver `clonarcostotarifario.sql` como referencia.
- **Estados comunes**: `'ACT'` (activo), `'EXC'` (excluido), `'ANU'` (anulado), `'SUS'` (suspendido), `'REG'` (registrado).
- **Auditoría**: Las tablas auditadas tienen espejo en esquema `audit` con sufijo `_aud` (ej: `audit.contrato_aud`).

## Convenciones de Scripts

- **Nombrado**: `<Tema><Persona>.sql` o `<descripcion>.sql`. El nombre de persona indica quién solicitó el reporte (ej: `comisionesMiguel.sql`, `FacturasPendientesLuca.sql`).
- **Idioma**: SQL y comentarios en español. Nombres de columnas/tablas en español sin tildes (ej: `fechainicio`, `coberturacontratada`, `estadoafiliacion`).
- **Estilo SQL**: Keywords en MAYÚSCULAS (`SELECT`, `LEFT JOIN`, `WHERE`). Sin punto y coma obligatorio al final. Uso extensivo de `ILIKE` para comparaciones case-insensitive.
- **Consultas complejas**: Uso frecuente de `LEFT JOIN LATERAL`, CTEs recursivos (`WITH RECURSIVE`), funciones ventana (`ROW_NUMBER() OVER`), y funciones PL/pgSQL con `DO $$ ... $$ LANGUAGE plpgsql`.

## Entorno de Pruebas

El flujo para rotar la BD de pruebas está documentado en `PRUEBAS_GENESYS/BaseDatosCambiar.sql`:

1. Terminar sesiones activas con `pg_terminate_backend`
2. Renombrar BD actual (ej: `genesys` → `genesys_old1612`)
3. Renombrar BD restaurada al nombre esperado
4. **Sanitizar emails**: `UPDATE entidad SET email = 'pruebasgenesys9@gmail.com'`
5. Ejecutar `VACUUM (VERBOSE, ANALYZE)`
6. En Luca: cambiar `environmenttype_id = 1` para modo pruebas

## Monitoreo y DBA

- **Bloqueos**: `monitorBloqueos.sql` — consultas a `pg_stat_activity` filtrando `wait_event_type = 'Lock'` y sesiones `idle in transaction`.
- **Tamaño de tablas**: `tamaño_tablas.sql` — reportes por esquema con `pg_total_relation_size`.
- **Particionamiento**: `particionamiento_detalle.sql` — guía paso a paso (10 pasos) para particionar la tabla `detalle` por rangos de ID de 10M.

## Advertencias

- Los scripts **no tienen protección contra ejecución accidental** — muchos contienen `UPDATE`/`DELETE` sin transacciones. Revisar siempre antes de ejecutar.
- Los warnings del IDE sobre "Unable to resolve table" son esperados — el IDE no tiene conexión a la BD real.
- Nunca ejecutar scripts de `PRODUCCION_GENESYS/` contra el entorno de pruebas sin verificar la conexión activa.

