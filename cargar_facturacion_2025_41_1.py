#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script para cargar el archivo Excel FACTURACION 2025 41 Ingreso Operativos-1.xlsx
a la tabla FACTURACION_2025_41_1 en PostgreSQL 9.5.

Uso:
    python3 cargar_facturacion_2025_41_1.py

Requisitos:
    pip install openpyxl psycopg2-binary
"""

import openpyxl
import psycopg2
import sys
import re
from datetime import datetime, date

# ============================================================
# CONFIGURACIÓN — Ajustar según el entorno
# ============================================================
EXCEL_PATH = '/home/jose/Descargas/FACTURACION 2025 41 Ingreso Operativos-1.xlsx'
TABLE_NAME = 'facturacion_2025_41_1'
SQL_OUTPUT = '/home/jose/Documentos/sandbox/ecuasanitas/PRODUCCION_GENESYS/cargar_facturacion_2025_41_1.sql'

DB_CONFIG = {
    'dbname': 'genesys',
    'user': 'genesys',
    'password': 'genesys',
    'host': 'localhost',
    'port': '5432'
}

# ============================================================
# FUNCIONES
# ============================================================

def sanitize_column_name(name):
    """Convierte el nombre de columna del Excel a un nombre válido para PostgreSQL."""
    if name is None:
        return 'columna_sin_nombre'
    col = str(name).strip().lower()
    col = col.replace(' ', '_').replace('.', '_').replace('-', '_')
    col = col.replace('á', 'a').replace('é', 'e').replace('í', 'i')
    col = col.replace('ó', 'o').replace('ú', 'u').replace('ñ', 'n')
    col = re.sub(r'[^a-z0-9_]', '', col)
    col = re.sub(r'_+', '_', col).strip('_')
    if not col:
        col = 'col'
    # Si empieza con número, prefijar con _
    if col[0].isdigit():
        col = '_' + col
    return col


def infer_pg_type(values):
    """Infiere el tipo PostgreSQL a partir de una muestra de valores."""
    non_null = [v for v in values if v is not None]
    if not non_null:
        return 'TEXT'

    all_int = True
    all_float = True
    all_date = True
    all_bool = True
    max_len = 0

    for v in non_null:
        if isinstance(v, bool):
            all_int = False
            all_float = False
            all_date = False
        elif isinstance(v, int):
            all_bool = False
            all_date = False
        elif isinstance(v, float):
            all_bool = False
            all_int = False
            all_date = False
        elif isinstance(v, (datetime, date)):
            all_bool = False
            all_int = False
            all_float = False
        else:
            all_bool = False
            all_int = False
            all_float = False
            all_date = False
            max_len = max(max_len, len(str(v)))

    if all_bool and non_null:
        return 'BOOLEAN'
    if all_int and non_null:
        # Verificar si cabe en INTEGER o necesita BIGINT
        max_val = max(abs(v) for v in non_null if isinstance(v, int))
        if max_val > 2147483647:
            return 'BIGINT'
        return 'INTEGER'
    if all_float and non_null:
        return 'NUMERIC'
    if all_date and non_null:
        has_time = any(isinstance(v, datetime) and (v.hour or v.minute or v.second) for v in non_null)
        return 'TIMESTAMP' if has_time else 'DATE'

    # Texto
    if max_len <= 50:
        return 'VARCHAR(100)'
    elif max_len <= 255:
        return 'VARCHAR(500)'
    else:
        return 'TEXT'


def read_excel(path):
    """Lee el Excel y retorna headers, tipos y filas de datos."""
    print(f"Leyendo archivo: {path}")
    wb = openpyxl.load_workbook(path, read_only=True, data_only=True)
    ws = wb.active
    print(f"  Hoja: {ws.title}")
    print(f"  Filas: {ws.max_row}, Columnas: {ws.max_column}")

    rows_iter = ws.iter_rows()
    header_row = next(rows_iter)
    headers = [sanitize_column_name(cell.value) for cell in header_row]

    # Detectar duplicados en headers
    seen = {}
    for i, h in enumerate(headers):
        if h in seen:
            seen[h] += 1
            headers[i] = f"{h}_{seen[h]}"
        else:
            seen[h] = 0

    # Leer todos los datos
    data = []
    for row in rows_iter:
        vals = [cell.value for cell in row]
        # Saltar filas completamente vacías
        if any(v is not None for v in vals):
            data.append(vals)

    print(f"  Filas de datos: {len(data)}")

    # Inferir tipos con muestra de hasta 100 filas
    sample_size = min(100, len(data))
    col_types = []
    for col_idx in range(len(headers)):
        sample = [data[r][col_idx] for r in range(sample_size) if col_idx < len(data[r])]
        col_types.append(infer_pg_type(sample))

    wb.close()
    return headers, col_types, data


def generate_create_table(table_name, headers, col_types):
    """Genera el DDL CREATE TABLE."""
    lines = [f'DROP TABLE IF EXISTS {table_name};\n']
    lines.append(f'CREATE TABLE {table_name} (')
    col_defs = []
    for h, t in zip(headers, col_types):
        col_defs.append(f'    {h} {t}')
    lines.append(',\n'.join(col_defs))
    lines.append(');\n')
    return '\n'.join(lines)


def format_value(v):
    """Formatea un valor Python para un INSERT SQL."""
    if v is None:
        return 'NULL'
    if isinstance(v, bool):
        return 'TRUE' if v else 'FALSE'
    if isinstance(v, (int, float)):
        return str(v)
    if isinstance(v, datetime):
        return f"'{v.strftime('%Y-%m-%d %H:%M:%S')}'"
    if isinstance(v, date):
        return f"'{v.strftime('%Y-%m-%d')}'"
    # Texto: escapar comillas simples
    s = str(v).replace("'", "''")
    return f"'{s}'"


def generate_inserts(table_name, headers, data, batch_size=100):
    """Genera sentencias INSERT con VALUES en lotes."""
    statements = []
    cols = ', '.join(headers)

    for i in range(0, len(data), batch_size):
        batch = data[i:i + batch_size]
        values_list = []
        for row in batch:
            vals = ', '.join(format_value(v) for v in row)
            values_list.append(f'    ({vals})')
        stmt = f"INSERT INTO {table_name} ({cols})\nVALUES\n"
        stmt += ',\n'.join(values_list) + ';\n'
        statements.append(stmt)

    return '\n'.join(statements)


def write_sql_file(path, create_ddl, inserts, table_name):
    """Escribe el archivo SQL completo."""
    with open(path, 'w', encoding='utf-8') as f:
        f.write(f"-- ============================================================\n")
        f.write(f"-- Carga de datos: {table_name}\n")
        f.write(f"-- Generado: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        f.write(f"-- Fuente: FACTURACION 2025 41 Ingreso Operativos-1.xlsx\n")
        f.write(f"-- ============================================================\n\n")
        f.write("BEGIN;\n\n")
        f.write(create_ddl)
        f.write('\n')
        f.write(inserts)
        f.write(f"\n-- Verificar conteo\nSELECT COUNT(*) AS total_registros FROM {table_name};\n\n")
        f.write("COMMIT;\n")
    print(f"  Archivo SQL generado: {path}")


def load_to_database(db_config, create_ddl, table_name, headers, data):
    """Carga los datos directamente a PostgreSQL."""
    print("\nConectando a la base de datos...")
    try:
        conn = psycopg2.connect(**db_config)
        conn.autocommit = False
        cur = conn.cursor()

        # Crear tabla
        print(f"  Creando tabla {table_name}...")
        cur.execute(f"DROP TABLE IF EXISTS {table_name}")
        cur.execute(create_ddl.replace(f"DROP TABLE IF EXISTS {table_name};\n", ""))

        # Insertar datos con parametrización
        placeholders = ', '.join(['%s'] * len(headers))
        insert_sql = f"INSERT INTO {table_name} ({', '.join(headers)}) VALUES ({placeholders})"

        print(f"  Insertando {len(data)} filas...")
        batch_size = 500
        for i in range(0, len(data), batch_size):
            batch = data[i:i + batch_size]
            cur.executemany(insert_sql, batch)
            print(f"    {min(i + batch_size, len(data))}/{len(data)} filas insertadas...")

        # Verificar
        cur.execute(f"SELECT COUNT(*) FROM {table_name}")
        count = cur.fetchone()[0]
        print(f"  Total registros en tabla: {count}")

        conn.commit()
        print("  COMMIT exitoso.")

        cur.close()
        conn.close()
        print("  Conexión cerrada.")
        return True

    except Exception as e:
        print(f"\n  ERROR al cargar en BD: {e}")
        print("  Se hizo ROLLBACK. Los datos NO se insertaron.")
        if 'conn' in dir() and conn:
            conn.rollback()
            conn.close()
        return False


# ============================================================
# MAIN
# ============================================================
if __name__ == '__main__':
    # 1. Leer Excel
    headers, col_types, data = read_excel(EXCEL_PATH)

    print("\nColumnas detectadas:")
    for h, t in zip(headers, col_types):
        print(f"  {h:40s} {t}")

    # 2. Generar SQL
    create_ddl = generate_create_table(TABLE_NAME, headers, col_types)
    inserts = generate_inserts(TABLE_NAME, headers, data)

    # 3. Guardar archivo SQL de respaldo
    write_sql_file(SQL_OUTPUT, create_ddl, inserts, TABLE_NAME)

    # 4. Preguntar si cargar directo a BD
    print("\n" + "=" * 60)
    print("¿Desea cargar los datos directamente a la base de datos?")
    print(f"  Host: {DB_CONFIG['host']}:{DB_CONFIG['port']}")
    print(f"  BD:   {DB_CONFIG['dbname']}")
    print(f"  Tabla: {TABLE_NAME}")
    print("=" * 60)
    resp = input("\nEscriba 'si' para cargar, cualquier otra cosa para solo generar SQL: ").strip().lower()

    if resp in ('si', 'sí', 's', 'yes', 'y'):
        load_to_database(DB_CONFIG, create_ddl, TABLE_NAME, headers, data)
    else:
        print("\nSolo se generó el archivo SQL. Puede ejecutarlo manualmente en DataGrip.")
        print(f"  Archivo: {SQL_OUTPUT}")

    print("\n¡Listo!")

