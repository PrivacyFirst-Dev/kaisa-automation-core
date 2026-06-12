#!/bin/bash
set -e
PROJECT_DIR="$HOME/projects/n8n-umkm"
BACKUP_DIR="$PROJECT_DIR/backups/db"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=14

mkdir -p "$BACKUP_DIR"

echo "Starting database backup: $TIMESTAMP"

echo "Backing up Dolibarr MariaDB..."
if docker ps --format "{{.Names}}" | grep -q dolibarr-mysql; then
    docker exec dolibarr-mysql mysqldump -u root -pdolibarrroot2026 dolibarr_db > "$BACKUP_DIR/dolibarr-$TIMESTAMP.sql" 2>/dev/null
    echo "Dolibarr backup created"
else
    echo "WARNING: dolibarr-mysql not running"
fi

echo "Backing up Corteza PostgreSQL..."
if docker ps --format "{{.Names}}" | grep -q corteza-db; then
    docker exec corteza-db pg_dump -U corteza corteza > "$BACKUP_DIR/corteza-$TIMESTAMP.sql" 2>/dev/null
    echo "Corteza backup created"
else
    echo "WARNING: corteza-db not running"
fi

if [ -d "/mnt/d/Backup/db" ]; then
    cp "$BACKUP_DIR"/*.sql /mnt/d/Backup/db/ 2>/dev/null || true
fi

find "$BACKUP_DIR" -name "*.sql" -mtime +$RETENTION_DAYS -delete 2>/dev/null || true

echo "Database backup completed"
ls -lh "$BACKUP_DIR"/*.sql 2>/dev/null || echo "No SQL files yet"
