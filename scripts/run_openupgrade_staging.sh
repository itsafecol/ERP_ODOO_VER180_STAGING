#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

LOG_DIR="migration_backups/staging_upgrade_logs/openupgrade_by_db"
mkdir -p "$LOG_DIR"
RESULTS_FILE="$LOG_DIR/results.tsv"
: > "$RESULTS_FILE"

DBS=$(docker exec postgresqlitsafe_staging psql -U itsafedb -d postgres -Atc "SELECT datname FROM pg_database WHERE datistemplate = false AND datname <> 'postgres' ORDER BY datname;")

for db in $DBS; do
  log_file="$LOG_DIR/${db}.log"
  echo "[RUN] $db"
  if timeout 1800s docker compose -f docker-compose.staging.yml -f docker-compose.openupgrade.yml run --rm odoo_openupgrade_staging \
    odoo -c /etc/odoo/odoo.conf -d "$db" --update all --stop-after-init --upgrade-path=/opt/openupgrade/openupgrade_scripts/scripts >"$log_file" 2>&1; then
    rc=0
  else
    rc=$?
  fi
  echo "${db}|${rc}" | tee -a "$RESULTS_FILE"
  echo "[DONE] $db rc=$rc"
done
