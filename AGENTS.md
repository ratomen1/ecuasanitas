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
detalleemision → contrato (órdenes de cobro)
erroremision → detalleemision (errores en emisión)
```

- **IDs**: Generados via tabla `generador` (no secuencias). Cada entidad tiene una fila: `SELECT valor FROM generador WHERE nombre = 'Costo'`. Después de insertar, actualizar el generador manualmente. Ver `clonarcostotarifario.sql` como referencia.
- **Estados comunes**: `'ACT'` (activo), `'EXC'` (excluido), `'ANU'` (anulado), `'SUS'` (suspendido), `'REG'` (registrado).
- **Estados de detalleemision**: `'EMITIDA'`, `'PAGADO'`, `'CREDITO'`, `'EN_RECUPERACION'`, `'ADVERTENCIA'`, `'ERROR'`, `'ANULADO'`, `'PAGO_ANULADO'`, `'RECHAZADO'`.
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

---

## Agentes y Herramientas MCP Recomendados para PostgreSQL

### 🔧 MCP Servers Configurados (`.jb/mcp.json`)

| Servidor | Repositorio | Descripción |
|----------|-------------|-------------|
| **@modelcontextprotocol/server-postgres** | [modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers/tree/main/src/postgres) | **Oficial MCP**. Acceso read-only a PostgreSQL. Exploración de esquemas, queries, metadatos. El más estable. |
| **@bytebase/dbhub** | [bytebase/dbhub](https://github.com/bytebase/dbhub) | **Zero dependencias**, eficiente en tokens. Postgres, MySQL, SQLite. Exploración rápida de esquemas. 5.7k+ ★ |
| **MCP-PostgreSQL-Ops** | [call518/MCP-PostgreSQL-Ops](https://github.com/call518/MCP-PostgreSQL-Ops) | **30+ herramientas DBA**: rendimiento, table bloat, autovacuum, índices. PostgreSQL 12+. |
| **@modelcontextprotocol/server-filesystem** | [modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers/tree/main/src/filesystem) | Sistema de archivos. Lee/escribe scripts SQL. |
| **@modelcontextprotocol/server-memory** | [modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers/tree/main/src/memory) | Grafo de conocimiento persistente. Almacena modelo de datos y patrones. |
| **@modelcontextprotocol/server-github** | [modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers/tree/main/src/github) | Integración GitHub: issues, PRs. Necesario para Coding Agents. |

### 🌐 Herramientas Adicionales Recomendadas

| Herramienta | Descripción | Instalación |
|-------------|-------------|-------------|
| **mcp-alchemy** | SQLAlchemy MCP para PostgreSQL, MySQL, Oracle, MS-SQL. Multi-schema. | `pip install mcp-alchemy` |
| **pgmcp** | Consulta Postgres en lenguaje natural. Genera SQL automáticamente. | `npx -y pgmcp` |
| **SmartDB MCP** | Optimización SQL, detección de salud de índices. | [wenb1n-dev/SmartDB_MCP](https://github.com/wenb1n-dev/SmartDB_MCP) |
| **Google MCP Toolbox** | MCP server de Google para bases de datos. Soporte enterprise. | [googleapis/mcp-toolbox](https://github.com/googleapis/mcp-toolbox) |
| **DBchat** | Conversaciones en lenguaje natural con BD. Dashboards. Compatible JDBC. | [skanga/DBchat](https://github.com/skanga/DBchat) |

### 🤖 GitHub Copilot Coding Agent (via @copilot en Issues)

El **Coding Agent** de GitHub Copilot Pro+ puede:
- Crear scripts SQL nuevos basados en el modelo de datos
- Optimizar queries existentes
- Generar reportes de verificación de emisión/cobranza
- Crear scripts Python con `psycopg2`
- Revisar y documentar scripts existentes

**Cómo asignar tareas**: Crear un Issue → escribir `@copilot` seguido de la instrucción.

### 📋 Agentes Personalizados por Tarea (DataGrip Custom Agents)

#### Agente: DBA Monitor
- **Prompt**: "Eres un DBA PostgreSQL. Genera scripts de monitoreo con pg_stat_activity, pg_stat_user_tables, pg_locks. Comentarios en español. SQL keywords en MAYÚSCULAS."
- **Herramientas**: postgres-genesys, filesystem

#### Agente: Generador de Reportes
- **Prompt**: "Generas scripts SQL para Ecuasanitas. Usas LEFT JOIN LATERAL, CTEs, funciones ventana. Modelo: contrato → nivel, contrato → afiliacion → coberturacontratada."
- **Herramientas**: postgres-genesys, postgres-luca, filesystem

#### Agente: Verificador de Emisión
- **Prompt**: "Verificas emisión mensual de órdenes de cobro (11 pasos). Tabla principal: detalleemision con servicio_id=80."
- **Herramientas**: postgres-genesys, filesystem

---

## Advertencias

- Los scripts **no tienen protección contra ejecución accidental** — muchos contienen `UPDATE`/`DELETE` sin transacciones.
- Los warnings del IDE sobre "Unable to resolve table" son esperados.
- Nunca ejecutar scripts de `PRODUCCION_GENESYS/` contra pruebas sin verificar conexión.
- Los MCP servers deben usar el usuario `consultas` (solo lectura) por seguridad.
