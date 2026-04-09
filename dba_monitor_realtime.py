#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Monitor DBA en Tiempo Real — Ecuasanitas (PostgreSQL 9.5)
=========================================================
Script que ejecuta consultas de monitoreo cada N segundos
y muestra un dashboard en consola.

Compatibilidad: PostgreSQL 9.5+

Uso:
    python3 dba_monitor_realtime.py                  # intervalo de 10 seg
    python3 dba_monitor_realtime.py --intervalo 5    # intervalo de 5 seg
    python3 dba_monitor_realtime.py --modo bloqueos  # solo bloqueos
    python3 dba_monitor_realtime.py --modo completo  # dashboard completo

Modos disponibles:
    completo  - Dashboard general + conexiones + queries lentas
    bloqueos  - Solo bloqueos y locks
    queries   - Solo queries activas y lentas
    tablas    - Tamaño de tablas y vacuum
"""

import argparse
import os
import sys
import time
from datetime import datetime

try:
    import psycopg2
    import psycopg2.extras
except ImportError:
    print("Error: psycopg2 no esta instalado.")
    print("   Ejecutar: pip install psycopg2-binary")
    sys.exit(1)

# ============================================================================
# Configuración de conexión (usar variables de entorno o valores por defecto)
# ============================================================================
DB_CONFIG = {
    "host": os.getenv("PG_HOST", "192.168.40.68"),
    "port": int(os.getenv("PG_PORT", "5432")),
    "user": os.getenv("PG_USER", "genesys"),
    "password": os.getenv("PG_PASSWORD", "genesys"),
    "dbname": os.getenv("PG_DATABASE", "genesys"),
    "connect_timeout": 5,
    "application_name": "DBA_Monitor_Ecuasanitas"
}

# Colores ANSI para la terminal
class Color:
    RESET = "\033[0m"
    BOLD = "\033[1m"
    RED = "\033[91m"
    GREEN = "\033[92m"
    YELLOW = "\033[93m"
    BLUE = "\033[94m"
    MAGENTA = "\033[95m"
    CYAN = "\033[96m"
    WHITE = "\033[97m"
    BG_RED = "\033[41m"
    BG_GREEN = "\033[42m"
    BG_YELLOW = "\033[43m"


def limpiar_pantalla():
    """Limpia la pantalla de la terminal"""
    os.system('clear' if os.name != 'nt' else 'cls')


def conectar():
    """Establece conexion a la base de datos"""
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        conn.autocommit = True
        return conn
    except psycopg2.Error as e:
        print(f"{Color.RED}Error de conexion: {e}{Color.RESET}")
        return None


def ejecutar_query(conn, sql):
    """Ejecuta una query y retorna los resultados como lista de diccionarios"""
    try:
        with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
            cur.execute(sql)
            if cur.description:
                return cur.fetchall()
            return []
    except psycopg2.Error as e:
        print(f"{Color.YELLOW}  Error en query: {e}{Color.RESET}")
        return []


def cabecera(titulo, ancho=80):
    """Imprime una cabecera formateada"""
    print(f"\n{Color.BOLD}{Color.CYAN}{'=' * ancho}")
    print(f"  {titulo}")
    print(f"{'=' * ancho}{Color.RESET}")


def tabla_simple(filas, columnas, anchos=None):
    """Imprime una tabla simple formateada"""
    if not filas:
        print(f"  {Color.GREEN}[OK] Sin resultados (todo limpio){Color.RESET}")
        return

    if not anchos:
        anchos = [max(len(str(col)), max(len(str(fila.get(col, ''))) for fila in filas)) for col in columnas]
        anchos = [min(a, 40) for a in anchos]

    # Cabecera
    header = " | ".join(str(col).ljust(anchos[i])[:anchos[i]] for i, col in enumerate(columnas))
    print(f"  {Color.BOLD}{header}{Color.RESET}")
    print(f"  {'-' * len(header)}")

    # Filas
    for fila in filas:
        linea = " | ".join(str(fila.get(col, '')).ljust(anchos[i])[:anchos[i]] for i, col in enumerate(columnas))
        print(f"  {linea}")


# ============================================================================
# QUERIES DE MONITOREO — Compatible con PostgreSQL 9.5
# En PG 9.5: "waiting" (boolean) reemplaza a "wait_event_type"
# En PG 9.5: no existe "backend_type"
# ============================================================================

SQL_DASHBOARD = """
SELECT
    current_database() AS base_datos,
    (SELECT COUNT(*) FROM pg_stat_activity) AS total_conexiones,
    (SELECT COUNT(*) FROM pg_stat_activity WHERE state = 'active') AS activas,
    (SELECT COUNT(*) FROM pg_stat_activity WHERE state = 'idle') AS idle,
    (SELECT COUNT(*) FROM pg_stat_activity WHERE state = 'idle in transaction') AS idle_in_tx,
    (SELECT COUNT(*) FROM pg_stat_activity WHERE waiting = TRUE) AS esperando_lock,
    (SELECT COUNT(*) FROM pg_stat_activity WHERE state = 'active' AND NOW() - query_start > INTERVAL '1 minute') AS queries_mas_1min,
    (SELECT COUNT(*) FROM pg_stat_activity WHERE state = 'active' AND NOW() - query_start > INTERVAL '5 minutes') AS queries_mas_5min,
    (SELECT setting::int FROM pg_settings WHERE name = 'max_connections') AS max_conexiones,
    pg_size_pretty(pg_database_size(current_database())) AS tamaño_bd,
    (SELECT deadlocks FROM pg_stat_database WHERE datname = current_database()) AS deadlocks
"""

SQL_CACHE_HIT = """
SELECT
    ROUND(100.0 * SUM(blks_hit) / GREATEST(SUM(blks_hit + blks_read), 1), 2) AS cache_hit_ratio,
    SUM(xact_commit) AS commits,
    SUM(xact_rollback) AS rollbacks,
    SUM(tup_inserted) AS inserts,
    SUM(tup_updated) AS updates,
    SUM(tup_deleted) AS deletes
FROM pg_stat_database
WHERE datname = current_database()
"""

SQL_QUERIES_ACTIVAS = """
SELECT
    pid,
    usename AS usuario,
    LEFT(application_name, 15) AS app,
    client_addr::text AS ip,
    state AS estado,
    CASE WHEN waiting THEN 'WAITING' ELSE '-' END AS espera,
    EXTRACT(EPOCH FROM (NOW() - query_start))::int AS seg,
    LEFT(query, 80) AS query_resumida
FROM pg_stat_activity
WHERE state = 'active'
    AND pid <> pg_backend_pid()
    AND query NOT ILIKE '%pg_stat_activity%'
ORDER BY query_start ASC
LIMIT 15
"""

SQL_QUERIES_LENTAS = """
SELECT
    pid,
    usename AS usuario,
    client_addr::text AS ip,
    EXTRACT(EPOCH FROM (NOW() - query_start))::int AS segundos,
    CASE
        WHEN NOW() - query_start > INTERVAL '30 minutes' THEN 'CRITICO'
        WHEN NOW() - query_start > INTERVAL '10 minutes' THEN 'ALTO'
        WHEN NOW() - query_start > INTERVAL '5 minutes'  THEN 'MEDIO'
        WHEN NOW() - query_start > INTERVAL '1 minute'   THEN 'BAJO'
    END AS severidad,
    state AS estado,
    LEFT(query, 120) AS query
FROM pg_stat_activity
WHERE (state = 'active' OR state = 'idle in transaction')
    AND NOW() - query_start > INTERVAL '1 minute'
    AND pid <> pg_backend_pid()
ORDER BY query_start ASC
"""

SQL_BLOQUEOS = """
SELECT
    bloqueador.pid AS bloqueador_pid,
    bloqueador.usename AS bloqueador_user,
    LEFT(bloqueador.query, 60) AS bloqueador_query,
    EXTRACT(EPOCH FROM (NOW() - bloqueador.query_start))::int AS bloqueador_seg,
    bloqueado.pid AS bloqueado_pid,
    bloqueado.usename AS bloqueado_user,
    LEFT(bloqueado.query, 60) AS bloqueado_query,
    EXTRACT(EPOCH FROM (NOW() - bloqueado.query_start))::int AS esperando_seg
FROM pg_locks l_bloqueado
JOIN pg_stat_activity bloqueado ON bloqueado.pid = l_bloqueado.pid
JOIN pg_locks l_bloqueador ON l_bloqueador.locktype = l_bloqueado.locktype
    AND l_bloqueador.database IS NOT DISTINCT FROM l_bloqueado.database
    AND l_bloqueador.relation IS NOT DISTINCT FROM l_bloqueado.relation
    AND l_bloqueador.page IS NOT DISTINCT FROM l_bloqueado.page
    AND l_bloqueador.tuple IS NOT DISTINCT FROM l_bloqueado.tuple
    AND l_bloqueador.virtualxid IS NOT DISTINCT FROM l_bloqueado.virtualxid
    AND l_bloqueador.transactionid IS NOT DISTINCT FROM l_bloqueado.transactionid
    AND l_bloqueador.pid <> l_bloqueado.pid
JOIN pg_stat_activity bloqueador ON bloqueador.pid = l_bloqueador.pid
WHERE NOT l_bloqueado.granted AND l_bloqueador.granted
ORDER BY esperando_seg DESC
"""

SQL_IDLE_IN_TX = """
SELECT
    pid,
    usename AS usuario,
    LEFT(application_name, 15) AS app,
    client_addr::text AS ip,
    EXTRACT(EPOCH FROM (NOW() - state_change))::int AS seg_idle,
    EXTRACT(EPOCH FROM (NOW() - xact_start))::int AS seg_transaccion,
    LEFT(query, 80) AS ultima_query
FROM pg_stat_activity
WHERE state = 'idle in transaction'
ORDER BY xact_start ASC
"""

SQL_CONEXIONES_POR_IP = """
SELECT
    COALESCE(client_addr::text, 'local') AS ip,
    COUNT(*) AS total,
    SUM(CASE WHEN state = 'active' THEN 1 ELSE 0 END) AS activas,
    SUM(CASE WHEN state = 'idle' THEN 1 ELSE 0 END) AS idle,
    SUM(CASE WHEN state = 'idle in transaction' THEN 1 ELSE 0 END) AS idle_tx,
    STRING_AGG(DISTINCT usename, ',') AS usuarios
FROM pg_stat_activity
WHERE pid <> pg_backend_pid()
GROUP BY client_addr
ORDER BY total DESC
LIMIT 10
"""

SQL_VACUUM_PENDIENTE = """
SELECT
    schemaname AS esquema,
    relname AS tabla,
    n_dead_tup AS filas_muertas,
    n_live_tup AS filas_vivas,
    CASE WHEN n_live_tup > 0 THEN ROUND(100.0 * n_dead_tup / n_live_tup, 1) ELSE 0 END AS pct_muertas,
    last_autovacuum::date AS ultimo_vacuum,
    pg_size_pretty(pg_total_relation_size(quote_ident(schemaname)||'.'||quote_ident(relname))) AS tamaño
FROM pg_stat_user_tables
WHERE n_dead_tup > 5000
ORDER BY n_dead_tup DESC
LIMIT 10
"""

SQL_TABLAS_GRANDES = """
SELECT
    schemaname AS esquema,
    relname AS tabla,
    pg_size_pretty(pg_total_relation_size(quote_ident(schemaname)||'.'||quote_ident(relname))) AS tamaño_total,
    pg_size_pretty(pg_relation_size(quote_ident(schemaname)||'.'||quote_ident(relname))) AS datos,
    n_live_tup AS filas,
    seq_scan AS seq_scans,
    COALESCE(idx_scan, 0) AS idx_scans
FROM pg_stat_user_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(quote_ident(schemaname)||'.'||quote_ident(relname)) DESC
LIMIT 15
"""


# ============================================================================
# FUNCIONES DE CADA MODO
# ============================================================================

def modo_completo(conn):
    """Dashboard completo del servidor"""
    limpiar_pantalla()
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"{Color.BOLD}{Color.WHITE}{'=' * 80}")
    print(f"  MONITOR DBA PostgreSQL 9.5 -- Ecuasanitas")
    print(f"  {timestamp}   Presiona Ctrl+C para detener")
    print(f"{'=' * 80}{Color.RESET}")

    # Dashboard general
    dashboard = ejecutar_query(conn, SQL_DASHBOARD)
    if dashboard:
        d = dashboard[0]
        max_conn = d['max_conexiones']
        total = d['total_conexiones']
        pct = round(100 * total / max_conn, 1) if max_conn else 0
        color_pct = Color.GREEN if pct < 70 else Color.YELLOW if pct < 90 else Color.RED

        print(f"\n  {Color.BOLD}RESUMEN GENERAL{Color.RESET}")
        print(f"  BD: {Color.CYAN}{d['base_datos']}{Color.RESET}  |  Tamano: {Color.CYAN}{d['tamaño_bd']}{Color.RESET}  |  Deadlocks: {d['deadlocks']}")
        print(f"  Conexiones: {color_pct}{total}/{max_conn} ({pct}%){Color.RESET}  |  Activas: {Color.GREEN}{d['activas']}{Color.RESET}  |  Idle: {d['idle']}  |  Idle-in-TX: {Color.YELLOW if d['idle_in_tx'] > 0 else Color.GREEN}{d['idle_in_tx']}{Color.RESET}")
        locks = d['esperando_lock']
        slow1 = d['queries_mas_1min']
        slow5 = d['queries_mas_5min']
        print(f"  Locks: {Color.RED if locks > 0 else Color.GREEN}{locks}{Color.RESET}  |  Queries >1min: {Color.YELLOW if slow1 > 0 else Color.GREEN}{slow1}{Color.RESET}  |  Queries >5min: {Color.RED if slow5 > 0 else Color.GREEN}{slow5}{Color.RESET}")

    # Cache hit ratio
    cache = ejecutar_query(conn, SQL_CACHE_HIT)
    if cache:
        c = cache[0]
        ratio = c['cache_hit_ratio']
        color_ratio = Color.GREEN if ratio >= 99 else Color.YELLOW if ratio >= 95 else Color.RED
        print(f"  Cache Hit: {color_ratio}{ratio}%{Color.RESET}  |  Commits: {c['commits']}  |  Rollbacks: {c['rollbacks']}  |  INS/UPD/DEL: {c['inserts']}/{c['updates']}/{c['deletes']}")

    # Queries activas
    cabecera("QUERIES ACTIVAS")
    activas = ejecutar_query(conn, SQL_QUERIES_ACTIVAS)
    tabla_simple(activas, ['pid', 'usuario', 'app', 'ip', 'espera', 'seg', 'query_resumida'])

    # Queries lentas
    cabecera("QUERIES LENTAS (>1 minuto)")
    lentas = ejecutar_query(conn, SQL_QUERIES_LENTAS)
    if lentas:
        for fila in lentas:
            sev = fila.get('severidad', 'BAJO')
            icono = '[!!!]' if sev == 'CRITICO' else '[!!]' if sev == 'ALTO' else '[!]' if sev == 'MEDIO' else '[.]'
            print(f"  {icono} PID={fila['pid']}  {fila['usuario']}  {fila['ip']}  {fila['segundos']}s  [{sev}]")
            print(f"     {Color.YELLOW}{fila['query']}{Color.RESET}")
    else:
        print(f"  {Color.GREEN}[OK] Sin queries lentas{Color.RESET}")

    # Bloqueos
    cabecera("BLOQUEOS ACTIVOS")
    bloqueos = ejecutar_query(conn, SQL_BLOQUEOS)
    if bloqueos:
        for b in bloqueos:
            print(f"  {Color.RED}[LOCK] PID {b['bloqueador_pid']} ({b['bloqueador_user']}) -> BLOQUEA -> PID {b['bloqueado_pid']} ({b['bloqueado_user']}) [{b['esperando_seg']}s]{Color.RESET}")
            print(f"     Bloqueador: {b['bloqueador_query']}")
            print(f"     Bloqueado:  {b['bloqueado_query']}")
    else:
        print(f"  {Color.GREEN}[OK] Sin bloqueos{Color.RESET}")

    # Idle in transaction
    idle_tx = ejecutar_query(conn, SQL_IDLE_IN_TX)
    if idle_tx:
        cabecera("IDLE IN TRANSACTION")
        tabla_simple(idle_tx, ['pid', 'usuario', 'app', 'ip', 'seg_idle', 'seg_transaccion', 'ultima_query'])

    # Conexiones por IP
    cabecera("CONEXIONES POR IP")
    por_ip = ejecutar_query(conn, SQL_CONEXIONES_POR_IP)
    tabla_simple(por_ip, ['ip', 'total', 'activas', 'idle', 'idle_tx', 'usuarios'])


def modo_bloqueos(conn):
    """Solo monitoreo de bloqueos"""
    limpiar_pantalla()
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"{Color.BOLD}{Color.WHITE}{'=' * 80}")
    print(f"  MONITOR DE BLOQUEOS -- Ecuasanitas (PG 9.5)")
    print(f"  {timestamp}   Presiona Ctrl+C para detener")
    print(f"{'=' * 80}{Color.RESET}")

    cabecera("BLOQUEOS: Quien bloquea a quien")
    bloqueos = ejecutar_query(conn, SQL_BLOQUEOS)
    if bloqueos:
        for b in bloqueos:
            print(f"  {Color.RED}[LOCK] PID {b['bloqueador_pid']} ({b['bloqueador_user']}) -> BLOQUEA -> PID {b['bloqueado_pid']} ({b['bloqueado_user']})")
            print(f"     Esperando: {b['esperando_seg']}s  |  Bloqueador activo: {b['bloqueador_seg']}s")
            print(f"     Q-Bloqueador: {b['bloqueador_query']}")
            print(f"     Q-Bloqueado:  {b['bloqueado_query']}{Color.RESET}")
            print()
    else:
        print(f"  {Color.GREEN}[OK] Sin bloqueos activos{Color.RESET}")

    cabecera("SESIONES ESPERANDO LOCK")
    sql_wait = """
    SELECT pid, usename AS usuario, LEFT(application_name,15) AS app,
           client_addr::text AS ip,
           CASE WHEN waiting THEN 'SI' ELSE 'NO' END AS esperando,
           EXTRACT(EPOCH FROM (NOW() - query_start))::int AS seg,
           LEFT(query, 100) AS query
    FROM pg_stat_activity WHERE waiting = TRUE
    ORDER BY query_start ASC
    """
    esperando = ejecutar_query(conn, sql_wait)
    tabla_simple(esperando, ['pid', 'usuario', 'app', 'ip', 'esperando', 'seg', 'query'])

    cabecera("IDLE IN TRANSACTION (mantienen locks abiertos)")
    idle_tx = ejecutar_query(conn, SQL_IDLE_IN_TX)
    tabla_simple(idle_tx, ['pid', 'usuario', 'app', 'ip', 'seg_idle', 'seg_transaccion', 'ultima_query'])


def modo_queries(conn):
    """Solo monitoreo de queries"""
    limpiar_pantalla()
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"{Color.BOLD}{Color.WHITE}{'=' * 80}")
    print(f"  MONITOR DE QUERIES -- Ecuasanitas (PG 9.5)")
    print(f"  {timestamp}   Presiona Ctrl+C para detener")
    print(f"{'=' * 80}{Color.RESET}")

    cabecera("QUERIES ACTIVAS")
    activas = ejecutar_query(conn, SQL_QUERIES_ACTIVAS)
    tabla_simple(activas, ['pid', 'usuario', 'app', 'ip', 'espera', 'seg', 'query_resumida'])

    cabecera("QUERIES LENTAS (>1 minuto)")
    lentas = ejecutar_query(conn, SQL_QUERIES_LENTAS)
    if lentas:
        for fila in lentas:
            sev = fila.get('severidad', 'BAJO')
            icono = '[!!!]' if sev == 'CRITICO' else '[!!]' if sev == 'ALTO' else '[!]' if sev == 'MEDIO' else '[.]'
            color = Color.RED if sev == 'CRITICO' else Color.YELLOW if sev in ('ALTO', 'MEDIO') else Color.WHITE
            print(f"  {icono} {color}PID={fila['pid']}  {fila['usuario']}@{fila['ip']}  {fila['segundos']}s  [{sev}]{Color.RESET}")
            print(f"     {fila['query']}")
    else:
        print(f"  {Color.GREEN}[OK] Sin queries lentas{Color.RESET}")

    cabecera("CONEXIONES POR IP")
    por_ip = ejecutar_query(conn, SQL_CONEXIONES_POR_IP)
    tabla_simple(por_ip, ['ip', 'total', 'activas', 'idle', 'idle_tx', 'usuarios'])


def modo_tablas(conn):
    """Monitoreo de tablas y vacuum"""
    limpiar_pantalla()
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"{Color.BOLD}{Color.WHITE}{'=' * 80}")
    print(f"  MONITOR DE TABLAS Y VACUUM -- Ecuasanitas (PG 9.5)")
    print(f"  {timestamp}   Presiona Ctrl+C para detener")
    print(f"{'=' * 80}{Color.RESET}")

    cabecera("TOP TABLAS MAS GRANDES (public)")
    grandes = ejecutar_query(conn, SQL_TABLAS_GRANDES)
    tabla_simple(grandes, ['tabla', 'tamaño_total', 'datos', 'filas', 'seq_scans', 'idx_scans'])

    cabecera("TABLAS QUE NECESITAN VACUUM (filas muertas)")
    vacuum = ejecutar_query(conn, SQL_VACUUM_PENDIENTE)
    tabla_simple(vacuum, ['tabla', 'filas_muertas', 'filas_vivas', 'pct_muertas', 'ultimo_vacuum', 'tamaño'])

    cabecera("TAMANO POR ESQUEMA")
    sql_esquemas = """
    SELECT nspname AS esquema,
           pg_size_pretty(SUM(pg_total_relation_size(c.oid))::bigint) AS tamaño,
           COUNT(*) AS tablas
    FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE nspname NOT IN ('pg_catalog','information_schema','pg_toast') AND c.relkind = 'r'
    GROUP BY nspname ORDER BY SUM(pg_total_relation_size(c.oid)) DESC
    """
    esquemas = ejecutar_query(conn, sql_esquemas)
    tabla_simple(esquemas, ['esquema', 'tamaño', 'tablas'])

    # En PG 9.5 no existe pg_stat_progress_vacuum, verificamos via pg_stat_activity
    cabecera("VACUUM EN EJECUCION")
    sql_vac_prog = """
    SELECT pid, usename AS usuario, LEFT(query, 100) AS query,
           EXTRACT(EPOCH FROM (NOW() - query_start))::int AS seg
    FROM pg_stat_activity
    WHERE query ILIKE '%vacuum%' AND state = 'active' AND pid <> pg_backend_pid()
    """
    vac_prog = ejecutar_query(conn, sql_vac_prog)
    tabla_simple(vac_prog, ['pid', 'usuario', 'query', 'seg'])


# ============================================================================
# MAIN
# ============================================================================

MODOS = {
    'completo': modo_completo,
    'bloqueos': modo_bloqueos,
    'queries': modo_queries,
    'tablas': modo_tablas,
}

def main():
    parser = argparse.ArgumentParser(description='Monitor DBA PostgreSQL 9.5 -- Ecuasanitas')
    parser.add_argument('--intervalo', type=int, default=10, help='Intervalo de refresco en segundos (default: 10)')
    parser.add_argument('--modo', choices=MODOS.keys(), default='completo', help='Modo de monitoreo (default: completo)')
    parser.add_argument('--host', default=None, help='Host PostgreSQL (override)')
    parser.add_argument('--port', type=int, default=None, help='Puerto PostgreSQL (override)')
    parser.add_argument('--user', default=None, help='Usuario PostgreSQL (override)')
    parser.add_argument('--password', default=None, help='Contrasena PostgreSQL (override)')
    parser.add_argument('--dbname', default=None, help='Base de datos (override)')
    args = parser.parse_args()

    # Override de configuracion si se pasan parametros
    if args.host: DB_CONFIG['host'] = args.host
    if args.port: DB_CONFIG['port'] = args.port
    if args.user: DB_CONFIG['user'] = args.user
    if args.password: DB_CONFIG['password'] = args.password
    if args.dbname: DB_CONFIG['dbname'] = args.dbname

    funcion_modo = MODOS[args.modo]

    print(f"{Color.CYAN}Conectando a {DB_CONFIG['host']}:{DB_CONFIG['port']}/{DB_CONFIG['dbname']}...{Color.RESET}")
    conn = conectar()
    if not conn:
        sys.exit(1)
    print(f"{Color.GREEN}Conectado. Modo: {args.modo} | Intervalo: {args.intervalo}s{Color.RESET}")
    time.sleep(1)

    try:
        while True:
            # Verificar conexion
            if conn.closed:
                print(f"{Color.YELLOW}Reconectando...{Color.RESET}")
                conn = conectar()
                if not conn:
                    time.sleep(5)
                    continue

            funcion_modo(conn)
            print(f"\n  {Color.BOLD}Siguiente refresco en {args.intervalo}s... (Ctrl+C para salir){Color.RESET}")
            time.sleep(args.intervalo)

    except KeyboardInterrupt:
        print(f"\n{Color.CYAN}Monitor detenido.{Color.RESET}")
    finally:
        if conn and not conn.closed:
            conn.close()


if __name__ == '__main__':
    main()
