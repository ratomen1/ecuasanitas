# Copilot Instructions — Ecuasanitas DBA Scripts

## Contexto del Proyecto

Este repositorio contiene scripts SQL (PostgreSQL) para administración de bases de datos del sistema de medicina prepagada **Ecuasanitas**. NO es una aplicación ejecutable — es una librería de scripts operativos de DBA.

## Motor de Base de Datos

- **PostgreSQL** (versiones 13+)
- Bases principales: `genesys` (core del negocio), `luca` (facturación electrónica)
- Conexión cruzada entre bases vía `dblink`

## Convenciones SQL Obligatorias

1. **Keywords en MAYÚSCULAS**: `SELECT`, `FROM`, `LEFT JOIN`, `WHERE`, `GROUP BY`, `ORDER BY`, `HAVING`, `INSERT INTO`, `UPDATE`, `DELETE`, `WITH`, `LATERAL`, etc.
2. **Nombres de tablas/columnas en minúsculas sin tildes**: `fechainicio`, `coberturacontratada`, `estadoafiliacion`
3. **Comentarios en español**
4. **Sin punto y coma obligatorio** al final de cada query
5. **Uso de `ILIKE`** para comparaciones case-insensitive
6. **Patrones frecuentes**:
   - `LEFT JOIN LATERAL` para subconsultas correlacionadas
   - CTEs con `WITH` y `WITH RECURSIVE`
   - Funciones ventana: `ROW_NUMBER() OVER (PARTITION BY ... ORDER BY ...)`
   - Bloques anónimos: `DO $$ ... $$ LANGUAGE plpgsql`

## Modelo de Datos — Entidades Clave

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

## Estados Comunes

- `'ACT'` = Activo
- `'EXC'` = Excluido
- `'ANU'` = Anulado
- `'SUS'` = Suspendido
- `'REG'` = Registrado
- Estados de detalleemision: `'EMITIDA'`, `'PAGADO'`, `'CREDITO'`, `'EN_RECUPERACION'`, `'ADVERTENCIA'`, `'ERROR'`, `'ANULADO'`, `'PAGO_ANULADO'`, `'RECHAZADO'`

## Esquemas

- `public` — Tablas principales de negocio
- `audit` — Tablas de auditoría con sufijo `_aud` (ej: `audit.contrato_aud`)
- `dwh` — Data warehouse
- `irs` — Facturación en Luca

## Generación de IDs

Los IDs se generan vía tabla `generador` (NO secuencias PostgreSQL):
```sql
SELECT valor FROM generador WHERE nombre = 'NombreEntidad'
-- Después de insertar, actualizar manualmente:
UPDATE generador SET valor = valor + 1 WHERE nombre = 'NombreEntidad'
```

## Estructura de Directorios

- `PRODUCCION_GENESYS/` — Scripts para BD de producción
- `PRUEBAS_GENESYS/` — Scripts para entorno de pruebas
- `PRODUCCION_EVOUCHER/` — Comprobantes electrónicos (XML)
- Raíz — Utilidades generales y scripts Python

## Nombrado de Archivos

- Formato: `<Tema><PersonaSolicitante>.sql` o `<descripcion>.sql`
- El nombre de persona indica quién solicitó el reporte (ej: `comisionesMiguel.sql`)

## Advertencias

- Los scripts NO tienen protección contra ejecución accidental
- Muchos contienen `UPDATE`/`DELETE` sin transacciones — siempre envolver en `BEGIN`/`ROLLBACK` al probar
- Nunca ejecutar scripts de `PRODUCCION_GENESYS/` contra pruebas sin verificar conexión

## Para Scripts Python

- Usar `psycopg2` para conexión a PostgreSQL
- Codificación UTF-8
- Manejo de errores con `try/except` y rollback apropiado

