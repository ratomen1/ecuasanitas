# 🐘 Ecuasanitas DBA Scripts — Guía MCP + GitHub Copilot Pro+

## Descripción

Repositorio de scripts SQL (PostgreSQL) para administración de bases de datos del sistema de medicina prepagada **Ecuasanitas**. Este documento explica cómo configurar y usar los servidores **MCP (Model Context Protocol)** con **GitHub Copilot Pro+** en DataGrip, VS Code y la CLI.

---

## 📋 Requisitos Previos

| Componente | Versión mínima | Verificar con |
|---|---|---|
| **Node.js** | 18+ | `node --version` |
| **npx** | 9+ | `npx --version` |
| **Git** | 2.30+ | `git --version` |
| **GitHub Copilot Pro+** | Suscripción activa | [github.com/settings/copilot](https://github.com/settings/copilot) |
| **DataGrip** | 2024.3+ | `Help → About` |
| **PostgreSQL** | 13+ (servidor destino) | `psql --version` |

### Instalar Node.js (si no lo tienes)

```bash
# Con nvm (recomendado)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
nvm install 22
nvm use 22
```

---

## 🔐 Configuración de Credenciales

### 1. Archivo `.env` (credenciales locales)

El archivo `.env` en la raíz del proyecto contiene las credenciales. **No se sube a Git** (está en `.gitignore`):

```env
PG_HOST=192.168.40.68
PG_PORT=5432
PG_USER=genesys
PG_PASSWORD=genesys
PG_DATABASE=genesys
DATABASE_URL_GENESYS=postgresql://genesys:genesys@192.168.40.68:5432/genesys
DATABASE_URL_LUCA=postgresql://genesys:genesys@192.168.40.68:5432/luca
GITHUB_TOKEN=tu_token_aqui
```

### 2. GitHub Token

Para usar los MCPs de GitHub y Coding Agents:

1. Ir a [github.com/settings/tokens](https://github.com/settings/tokens?type=beta)
2. **Generate new token** → **Fine-grained token**
3. Permisos mínimos:
   - `Contents`: Read and write
   - `Issues`: Read and write
   - `Pull requests`: Read and write
   - `Metadata`: Read-only
4. Copiar el token y pegarlo en `.env` → `GITHUB_TOKEN=ghp_xxxxxxxxxxxx`
5. También exportarlo en tu shell:

```bash
# Agregar a ~/.zshrc o ~/.bashrc
export GITHUB_TOKEN="ghp_xxxxxxxxxxxx"
```

---

## 🛠️ Servidores MCP Configurados

### Mapa de Servidores

```
┌─────────────────────────────────────────────────────────────┐
│                    GitHub Copilot Pro+                       │
│                   (Chat / Agent Mode)                        │
├─────────┬──────────┬──────────┬──────────┬─────────┬────────┤
│postgres │postgres  │ dbhub    │ postgres │  pgmcp  │ github │
│genesys  │luca      │ genesys  │ ops      │         │        │
│         │          │ /luca    │          │         │        │
├─────────┴──────────┴──────────┴──────────┴─────────┴────────┤
│              192.168.40.68:5432 (PostgreSQL)                │
│              genesys / luca databases                        │
└─────────────────────────────────────────────────────────────┘
```

### Detalle de cada servidor

| # | Servidor | Paquete NPM | Propósito | BD |
|---|----------|-------------|-----------|-----|
| 1 | **postgres-genesys** | `@modelcontextprotocol/server-postgres` | Consultas SQL, exploración de esquemas, metadatos | genesys |
| 2 | **postgres-luca** | `@modelcontextprotocol/server-postgres` | Consultas SQL a facturación electrónica | luca |
| 3 | **dbhub-genesys** | `@bytebase/dbhub` | Exploración rápida de esquemas, eficiente en tokens | genesys |
| 4 | **dbhub-luca** | `@bytebase/dbhub` | Exploración rápida de esquemas de facturación | luca |
| 5 | **postgres-ops** | `mcp-postgres-ops` | 30+ herramientas DBA: bloat, autovacuum, índices, locks | genesys |
| 6 | **pgmcp** | `pgmcp` | Consultas en lenguaje natural, generación SQL automática | genesys |
| 7 | **filesystem** | `@modelcontextprotocol/server-filesystem` | Leer/escribir archivos del proyecto | — |
| 8 | **memory** | `@modelcontextprotocol/server-memory` | Grafo de conocimiento persistente entre sesiones | — |
| 9 | **github** | `@modelcontextprotocol/server-github` | Issues, PRs, branches, Coding Agents | — |
| 10 | **sequential-thinking** | `@modelcontextprotocol/server-sequential-thinking` | Descomponer problemas complejos en pasos | — |

---

## 🖥️ Configuración por IDE

### DataGrip (JetBrains)

Los servidores MCP se configuran en **`.jb/mcp.json`** en la raíz del proyecto:

```
ecuasanitas/
  .jb/
    mcp.json    ← Configuración MCP para DataGrip
```

**Cómo activar:**
1. Abrir DataGrip → `Settings` → `Tools` → `AI Assistant` → `Model Context Protocol`
2. Verificar que detecta el archivo `.jb/mcp.json`
3. Los servidores aparecen automáticamente en el chat de AI Assistant
4. En el chat, seleccionar **Agent Mode** (no Chat mode)
5. Escribir tu consulta y Copilot usará los MCP automáticamente

**Ejemplo de uso en DataGrip:**
```
@ai Muéstrame los contratos activos que no tienen orden de emisión este mes
```

### VS Code

Los servidores MCP se configuran en **`~/.config/Code/User/mcp.json`** (global) o **`.vscode/mcp.json`** (por proyecto):

**Cómo activar:**
1. Instalar extensión **GitHub Copilot** y **GitHub Copilot Chat**
2. Abrir el chat de Copilot (`Ctrl+Shift+I`)
3. Seleccionar **Agent Mode** (icono de herramientas)
4. Los servidores MCP aparecen como herramientas disponibles
5. Copilot los invoca automáticamente según el contexto

**Ejemplo de uso en VS Code:**
```
@workspace Analiza el rendimiento de la tabla detalle y sugiere índices
```

---

## 🤖 GitHub Copilot Coding Agents (Pro+ Feature)

### ¿Qué es?

Los **Coding Agents** permiten asignar tareas a Copilot desde un Issue de GitHub. Copilot crea un branch, implementa cambios y abre un PR automáticamente.

### Configuración

1. **Requisito**: Tener GitHub Copilot Pro+ activo
2. **Repositorio**: El proyecto debe estar en GitHub (ya configurado en `origin → https://github.com/ratomen1/ecuasanitas.git`)
3. **Permisos**: El token de GitHub debe tener permisos de escritura

### Uso paso a paso

1. **Crear un Issue** en GitHub:
   ```
   Título: Crear script de verificación de duplicados en detalleemision

   @copilot Genera un script SQL que:
   - Busque duplicados en la tabla detalleemision para el mes actual
   - Agrupe por contrato_id y mes de cobro
   - Muestre el detalle de cada duplicado
   - Siga las convenciones del proyecto (keywords MAYÚSCULAS, comentarios en español)
   ```

2. **Copilot trabaja automáticamente**:
   - Lee el código existente y las instrucciones en `.github/copilot-instructions.md`
   - Usa los MCPs para consultar la estructura de la BD
   - Crea un branch `copilot/fix-xxx`
   - Implementa el script
   - Abre un Pull Request

3. **Revisar y mergear** el PR

### Ejemplos de tareas para Coding Agents

| Tarea | Prompt para el Issue |
|-------|---------------------|
| Script de monitoreo | `@copilot Crea un script que monitoree bloqueos activos con pg_stat_activity` |
| Reporte de coberturas | `@copilot Genera un reporte de afiliados con coberturas vencidas este mes` |
| Optimización | `@copilot Analiza el script comisionesMiguel.sql y optimiza las subconsultas` |
| Script Python | `@copilot Crea un script Python que exporte a CSV los contratos sin emisión` |
| Documentación | `@copilot Documenta el proceso de emisión mensual basándote en los scripts existentes` |

---

## 📖 Uso Práctico de cada MCP

### 1. `postgres-genesys` / `postgres-luca` — Consultas directas

El MCP oficial de PostgreSQL. Ideal para consultas ad-hoc:

```
Prompt: "Ejecuta SELECT COUNT(*) FROM contrato WHERE estado = 'ACT'"
Prompt: "Muéstrame la estructura de la tabla detalleemision"
Prompt: "¿Cuántas órdenes están en estado EMITIDA este mes?"
```

### 2. `dbhub-genesys` / `dbhub-luca` — Exploración de esquemas

Bytebase DBHub es más eficiente para explorar esquemas (usa menos tokens):

```
Prompt: "Lista todas las tablas del esquema public"
Prompt: "Muéstrame las columnas de la tabla afiliacion"
Prompt: "¿Qué índices tiene la tabla detalle?"
```

### 3. `postgres-ops` — Herramientas DBA

30+ herramientas profesionales de administración:

```
Prompt: "Analiza el bloat de las tablas más grandes"
Prompt: "Muéstrame el estado del autovacuum"
Prompt: "¿Qué tablas necesitan VACUUM urgente?"
Prompt: "Analiza los índices no utilizados"
Prompt: "Muéstrame las queries más lentas"
```

### 4. `pgmcp` — Lenguaje natural a SQL

Convierte preguntas en español a SQL:

```
Prompt: "¿Cuántos afiliados activos hay por plan médico?"
Prompt: "Dame los contratos que pagaron este mes pero tienen estado suspendido"
Prompt: "Muéstrame el top 10 de asesores por comisiones del último trimestre"
```

### 5. `memory` — Contexto persistente

Almacena conocimiento entre sesiones:

```
Prompt: "Recuerda que la tabla detalle tiene 400M de filas y está particionada por ID"
Prompt: "¿Qué sabes sobre el modelo de datos de Ecuasanitas?"
```

### 6. `sequential-thinking` — Problemas complejos

Para descomponer tareas DBA complejas:

```
Prompt: "Necesito migrar la tabla detalle a particionamiento por rangos. 
         Dame un plan paso a paso considerando que tiene 400M filas y 
         no podemos tener downtime."
```

### 7. `github` — Gestión de repositorio

```
Prompt: "Crea un issue para documentar el proceso de emisión mensual"
Prompt: "¿Cuáles son los PRs abiertos?"
Prompt: "Muéstrame los últimos commits"
```

---

## 🔧 Resolución de Problemas

### Error: "Cannot obtain GitHub information"

```
Cannot obtain GitHub information for workspace folder...
Template variables ${owner} and ${repository} require a valid Git repository
```

**Solución:**
```bash
cd /home/jose/Documentos/sandbox/ecuasanitas
git remote -v  # Verificar que existe 'origin' apuntando a GitHub
# Si no existe:
git remote add origin https://github.com/ratomen1/ecuasanitas.git
```

### Error: "GITHUB_TOKEN not set"

**Solución:**
```bash
export GITHUB_TOKEN="ghp_tu_token_aqui"
# O agregarlo permanentemente a ~/.zshrc:
echo 'export GITHUB_TOKEN="ghp_tu_token_aqui"' >> ~/.zshrc
source ~/.zshrc
```

### Error: "Connection refused" en MCP PostgreSQL

**Solución:**
1. Verificar que el servidor PostgreSQL acepta conexiones remotas:
   ```bash
   psql -h 192.168.40.68 -U genesys -d genesys -c "SELECT 1"
   ```
2. Verificar `pg_hba.conf` en el servidor permite la IP del cliente
3. Verificar que el firewall permite el puerto 5432

### Los MCP no aparecen en DataGrip

1. Verificar que el archivo `.jb/mcp.json` existe en la raíz del proyecto
2. `Settings` → `Tools` → `AI Assistant` → verificar que MCP está habilitado
3. Reiniciar DataGrip después de cambiar la configuración
4. Verificar que `npx` está en el PATH del sistema

### Los MCP no aparecen en VS Code

1. Verificar `~/.config/Code/User/mcp.json`
2. Recargar VS Code: `Ctrl+Shift+P` → `Developer: Reload Window`
3. Abrir el chat de Copilot en **Agent Mode** (no Chat mode)
4. Verificar en `Output` → `GitHub Copilot Chat` si hay errores de conexión

---

## 📁 Estructura de Archivos de Configuración

```
ecuasanitas/
├── .env                              ← Credenciales (NO se sube a Git)
├── .gitignore                        ← Ignora .env, .idea/, temp/
├── .jb/
│   └── mcp.json                      ← MCP servers para DataGrip
├── .github/
│   └── copilot-instructions.md       ← Instrucciones para Copilot
├── AGENTS.md                         ← Descripción de agentes disponibles
├── README.md                         ← Este archivo
├── test_connection.py                ← Test de conexión Python
├── PRODUCCION_GENESYS/               ← Scripts de producción
├── PRUEBAS_GENESYS/                  ← Scripts de pruebas
└── PRODUCCION_EVOUCHER/              ← Comprobantes electrónicos
```

---

## 🌐 Servidores MCP Adicionales Recomendados

Estos son servidores MCP adicionales que puedes agregar según tus necesidades:

| Servidor | Instalación | Descripción | GitHub Stars |
|----------|------------|-------------|--------------|
| **mcp-alchemy** | `pip install mcp-alchemy` | SQLAlchemy MCP multi-BD (PostgreSQL, MySQL, Oracle, MS-SQL). Multi-schema. | 400+ |
| **SmartDB MCP** | `npx -y smartdb-mcp` | Optimización SQL automática, detección de salud de índices | 200+ |
| **supabase-mcp** | `npx -y @supabase/mcp-server-supabase` | Si usas Supabase (PostgreSQL cloud) | 1k+ |
| **neon-mcp** | `npx -y @neondatabase/mcp-server` | Si usas Neon (PostgreSQL serverless) | 500+ |
| **prisma-mcp** | `npx -y @nicepkg/mcp-prisma` | Introspección avanzada con Prisma ORM | 300+ |
| **cloudflare-mcp** | `npx -y @cloudflare/mcp-server-cloudflare` | Workers, D1, R2 (si usas Cloudflare) | 2k+ |

### Cómo agregar un nuevo servidor MCP

**En DataGrip (`.jb/mcp.json`):**
```json
{
  "servers": {
    "nombre-servidor": {
      "command": "npx",
      "args": ["-y", "paquete-npm", "argumento1"],
      "env": {
        "VARIABLE": "valor"
      },
      "description": "Descripción del servidor"
    }
  }
}
```

**En VS Code (`~/.config/Code/User/mcp.json`):**
```json
{
  "servers": {
    "nombre-servidor": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "paquete-npm", "argumento1"],
      "env": {
        "VARIABLE": "valor"
      }
    }
  }
}
```

---

## 🚀 Quick Start

```bash
# 1. Clonar el repositorio
git clone https://github.com/ratomen1/ecuasanitas.git
cd ecuasanitas

# 2. Crear archivo .env con tus credenciales
cp .env.example .env  # (o crear manualmente)

# 3. Exportar GitHub Token
export GITHUB_TOKEN="ghp_tu_token"

# 4. Probar conexión a la BD
python3 test_connection.py

# 5. Probar un servidor MCP manualmente
npx -y @modelcontextprotocol/server-postgres "postgresql://genesys:genesys@192.168.40.68:5432/genesys"

# 6. Abrir DataGrip → AI Assistant → Agent Mode → ¡Listo!
```

---

## 📄 Licencia

Uso interno — Ecuasanitas S.A.

