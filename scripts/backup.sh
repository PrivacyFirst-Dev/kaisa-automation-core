#!/bin/bash
set -e
# Pre-backup disk check
DISK_AVAIL=$(df "$BACKUP_DIR" | tail -1 | awk "{print $4}")
if [ "$DISK_AVAIL" -lt 1048576 ]; then
  printf "[ERROR] Insufficient disk space for backup\n" >> /var/log/kaisa-backup-error.log
  exit 1
fi
PROJECT_DIR="$HOME/projects/n8n-umkm"
BACKUP_DIR="$PROJECT_DIR/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=14

echo "Starting backup: $TIMESTAMP"

cd "$PROJECT_DIR" || exit 1

if [ -f "docker-compose.yml" ]; then
    cp docker-compose.yml "$BACKUP_DIR/docker-compose.yml.backup.$TIMESTAMP"
    echo "Backed up: docker-compose.yml"
fi

echo "Backing up n8n data volume..."
docker run --rm -v n8n_data:/source/n8n -v "$BACKUP_DIR":/backup alpine tar czf "/backup/n8n_data_$TIMESTAMP.tar.gz" -C /source/n8n . >> /var/log/kaisa-backup-error.log 2>&1
echo "n8n volume backup created"

if [ -f ".env" ]; then
    cp .env "$BACKUP_DIR/.env.backup.$TIMESTAMP"
chmod 600 "$BACKUP_DIR"/*.env* 2>/dev/null || true
fi

if [ -f "$HOME/.cloudflared/config.yml" ]; then
    cp "$HOME/.cloudflared/config.yml" "$BACKUP_DIR/cloudflared-config.$TIMESTAMP.yml"
fi

echo "Backing up n8n workflows via API..."
if [ -n "$N8N_API_KEY" ]; then
    curl -s -X GET "http://localhost:5678/api/v1/workflows" -H "X-N8N-API-KEY: $N8N_API_KEY" -o "$BACKUP_DIR/n8n-workflows-$TIMESTAMP.json" >> /var/log/kaisa-backup-error.log 2>&1 && echo "Workflows backup created" || echo "WARNING: Workflow backup failed"
fi

if [ -d "/mnt/d/Backup/n8n" ]; then
    cp "$BACKUP_DIR"/*.tar.gz /mnt/d/Backup/n8n/ 2>/dev/null || true
    cp "$BACKUP_DIR"/*.json /mnt/d/Backup/n8n/ 2>/dev/null || true
fi

echo "Cleaning backups older than $RETENTION_DAYS days..."
find "$BACKUP_DIR" -type f \( -name "*.tar.gz" -o -name "*.backup.*" -o -name "*.sql" -o -name "*workflow*.json" \) -mtime +$RETENTION_DAYS -delete 2>/dev/null || true

echo "Backup completed: $(date '+%Y-%m-%d %H:%M:%S')" >> "$BACKUP_DIR/backup.log"
echo "Backup completed: $BACKUP_DIR"
