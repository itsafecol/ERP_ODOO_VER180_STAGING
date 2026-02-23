#!/usr/bin/env bash
set -euo pipefail

SERVICE_NAME="postgresql_itsafe_ver18"
POSTGRES_USER="${POSTGRES_USER:-postgres}"

for db in ITSAFE_PRODUCCION ITSAFE_UAT ITSAFE_STAGING; do
  echo "[INFO] Creando base $db si no existe"
  docker compose -f docker-compose.secure.yml exec -T "$SERVICE_NAME" \
    psql -U "$POSTGRES_USER" -d postgres \
    -c "SELECT 'CREATE DATABASE \"$db\"' WHERE NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = '$db')\\gexec"
done
