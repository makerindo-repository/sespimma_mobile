import json
import re
import os

# Use pre-generated bcrypt hash for 'password123'
hashed_pass = "$2a$10$BrCob0yyKmTfHLOlKzZqrurimrsyz3ZgLU6/fM7dzUeuMzSZaL9JG"

sql_lines = []
sql_lines.append("BEGIN;")
sql_lines.append("-- NOTE: Using default password 'password123' for all users.")
sql_lines.append("")

# Make sure users table has reset_token column
sql_lines.append("ALTER TABLE users ADD COLUMN IF NOT EXISTS reset_token VARCHAR(255);")
sql_lines.append("")

user_id = 1
emails_used = set()

def get_unique_email(base_email, fallback):
    email = base_email if base_email else fallback
    original = email
    counter = 1
    while email in emails_used:
        parts = original.split('@')
        if len(parts) == 2:
            email = f"{parts[0]}{counter}@{parts[1]}"
        else:
            email = f"{original}{counter}"
        counter += 1
    emails_used.add(email)
    return email

# 1. SERDIK
with open('assets/serdik_clean.json', 'r') as f:
    serdik_data = json.load(f)['data']

for s in serdik_data:
    nrp = s.get('nrp', '')
    email = get_unique_email(s.get('email'), f"{nrp}@sespimma.ac.id")
    name = s.get('nama_lengkap', '').replace("'", "''")
    pokjar = s.get('kelompok_kelas', '')
    no_serdik = s.get('no_serdik', '')
    pangkat = s.get('pangkat', '')

    sql_lines.append(f"INSERT INTO users (id, email, nrp, nip, password, role, is_active, created_at, updated_at) VALUES ({user_id}, '{email}', '{nrp}', NULL, '{hashed_pass}', 'serdik', true, NOW(), NOW()) ON CONFLICT DO NOTHING;")
    sql_lines.append(f"INSERT INTO serdik (user_id, no_serdik, nama_lengkap, nrp, pangkat, kelompok_kelas, created_at, updated_at) VALUES ({user_id}, '{no_serdik}', '{name}', '{nrp}', '{pangkat}', '{pokjar}', NOW(), NOW()) ON CONFLICT DO NOTHING;")
    user_id += 1

# Helper to read Dart files
def process_dart_file(filename, role_name, table_name=None):
    global user_id
    path = f"lib/features/auth/data/datasources/{filename}"
    if not os.path.exists(path):
        return
    with open(path, 'r') as f:
        content = f.read()

    # extract records list
    match = re.search(r'records\s*=\s*\[(.*?)\];', content, re.DOTALL)
    if not match:
        return
    records_str = match.group(1)
    
    # Simple parsing of dictionaries
    # find all { ... }
    dicts = re.findall(r'\{(.*?)\}', records_str, re.DOTALL)
    for d in dicts:
        record = {}
        # find all "key": "value"
        pairs = re.findall(r'"([^"]+)"\s*:\s*"([^"]+)"', d)
        for k, v in pairs:
            record[k] = v
        
        if not record:
            continue
            
        nrp_nip = record.get('nrp_nip', '')
        name = record.get('nama', '').replace("'", "''")
        pangkat = record.get('pangkat', '').replace("'", "''")
        jabatan = record.get('jabatan_struktural', '').replace("'", "''")
        peran = record.get('peran_pengasuhan', '').replace("'", "''")
        pokjar = record.get('pokjar', '')
        
        is_nip = len(nrp_nip) > 8
        nrp_val = 'NULL' if is_nip else f"'{nrp_nip}'"
        nip_val = f"'{nrp_nip}'" if is_nip else 'NULL'
        
        email = get_unique_email(None, f"{nrp_nip}@sespimma.ac.id")
        
        sql_lines.append(f"INSERT INTO users (id, email, nrp, nip, password, role, is_active, created_at, updated_at) VALUES ({user_id}, '{email}', {nrp_val}, {nip_val}, '{hashed_pass}', '{role_name}', true, NOW(), NOW()) ON CONFLICT DO NOTHING;")
        
        if table_name == 'patun':
            sql_lines.append(f"INSERT INTO patun (user_id, nama, pangkat, nrp_nip, jabatan_struktural, peran_pengasuhan, pokjar, created_at, updated_at) VALUES ({user_id}, '{name}', '{pangkat}', '{nrp_nip}', '{jabatan}', '{peran}', '{pokjar}', NOW(), NOW()) ON CONFLICT DO NOTHING;")
        elif table_name == 'korsis':
            sql_lines.append(f"INSERT INTO korsis (user_id, nama, pangkat, nrp_nip, jabatan_struktural, peran_pengasuhan, created_at, updated_at) VALUES ({user_id}, '{name}', '{pangkat}', '{nrp_nip}', '{jabatan}', '{peran}', NOW(), NOW()) ON CONFLICT DO NOTHING;")
        elif table_name == 'gadik':
            sql_lines.append(f"INSERT INTO gadik (user_id, nama, pangkat, nrp_nip, jabatan_struktural, created_at, updated_at) VALUES ({user_id}, '{name}', '{pangkat}', '{nrp_nip}', '{jabatan}', NOW(), NOW()) ON CONFLICT DO NOTHING;")
        elif table_name == 'pimpinan':
            sql_lines.append(f"INSERT INTO pimpinan (user_id, nama, pangkat, nrp_nip, jabatan_struktural, created_at, updated_at) VALUES ({user_id}, '{name}', '{pangkat}', '{nrp_nip}', '{jabatan}', NOW(), NOW()) ON CONFLICT DO NOTHING;")
        
        user_id += 1

process_dart_file('patun_real_data.dart', 'patun', 'patun')
process_dart_file('korsis_real_data.dart', 'korsis', 'korsis')
process_dart_file('gadik_real_data.dart', 'gadik', 'gadik')
process_dart_file('pimpinan_real_data.dart', 'pimpinan', 'pimpinan')
process_dart_file('operator_real_data.dart', 'operator', None)
process_dart_file('medis_real_data.dart', 'medis', None)

sql_lines.append(f"SELECT setval('users_id_seq', {user_id}, true);")
sql_lines.append("COMMIT;")

with open('seed.sql', 'w') as f:
    f.write("\n".join(sql_lines))

print("seed.sql generated successfully!")
