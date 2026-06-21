#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="/home/kaisa/projects/kaisa-automation-core/.env"
if [ -f "$ENV_FILE" ]; then
  set -a
  . "$ENV_FILE"
  set +a
fi

BACKUP_DIR="/mnt/d/BACKUPS/DB"
LOG_DIR="/home/kaisa/projects/kaisa-automation-core/logs"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
LOG_FILE="$LOG_DIR/backup-db-$(date +%Y%m%d).log"

mkdir -p "$BACKUP_DIR" "$LOG_DIR"

log() { printf "[%s] %s\n" "$(date +%H:%M:%S)" "$1" | tee -a "$LOG_FILE"; }

log "[INFO] Database backup sequence initiated."

log "[INFO] Backup PostgreSQL n8n..."
PG_USER="${POSTGRES_USER:-postgres}"
PG_DB="${POSTGRES_DB:-n8n}"
if docker exec kaisa-core-postgres-1 pg_dump -U "$PG_USER" "$PG_DB" | \
  gzip > "$BACKUP_DIR/n8n_postgres_${TIMESTAMP}.sql.gz"; then
  log "[OK] n8n PostgreSQL backup selesai."
else
  log "[ERROR] n8n PostgreSQL backup GAGAL."
fi

log "[INFO] Backup PostgreSQL Corteza..."
if docker exec kaisa-corteza-corteza-db-1 \
  pg_dump -U "${CORTEZA_DB_USER:-corteza}" "${CORTEZA_DB_NAME:-corteza}" | \
  gzip > "$BACKUP_DIR/corteza_postgres_${TIMESTAMP}.sql.gz"; then
  log "[OK] Corteza PostgreSQL backup selesai."
else
  log "[ERROR] Corteza PostgreSQL backup GAGAL."
fi

log "[INFO] Backup MySQL Ghost..."
if docker exec ghost-mysql \
  mysqldump -u ghost -p"${GHOST_DB_PASSWORD:-$MYSQL_PASSWORD}" ghost_db | \
  gzip > "$BACKUP_DIR/ghost_mysql_${TIMESTAMP}.sql.gz"; then
  log "[OK] Ghost MySQL backup selesai."
else
  log "[ERROR] Ghost MySQL backup GAGAL."
fi

log "[INFO] Backup MariaDB Dolibarr..."
if docker exec dolibarr-mysql \
  mysqldump -u dolibarr -p"${MARIADB_PASSWORD:-$MYSQL_PASSWORD}" dolibarr | \
  gzip > "$BACKUP_DIR/dolibarr_mariadb_${TIMESTAMP}.sql.gz"; then
  log "[OK] Dolibarr MariaDB backup selesai."
else
  log "[ERROR] Dolibarr MariaDB backup GAGAL."
fi

log "[INFO] Hapus backup lama (>7 hari)..."
find "$BACKUP_DIR" -name "*.sql.gz" -mtime +7 -delete && \
  log "[OK] Old backups cleaned." || \
  log "[WARNING] Cleanup gagal, cek manual."

log "[INFO] Backup complete. Files:"
ls -lh "$BACKUP_DIR"/*.sql.gz 2>/dev/null | tee -a "$LOG_FILE" || \
  log "[WARNING] Tidak ada file backup ditemukan."
