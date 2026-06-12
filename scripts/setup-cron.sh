#!/bin/bash
set -e

echo "Setting up cron jobs..."

# Backup existing crontab
crontab -l > "$HOME/cron-backup-$(date +%Y%m%d).txt" 2>/dev/null || true

# Create temp file for new crontab
CRON_TEMP=$(mktemp)

# Environment variables
{
    echo "SHELL=/bin/bash"
    echo "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
    echo "N8N_API_KEY=${N8N_API_KEY:-}"
    echo ""
} > "$CRON_TEMP"

# Existing: Daily backup at 3 AM (keep)
echo "0 3 * * * $HOME/projects/n8n-umkm/backup.sh >> $HOME/projects/n8n-umkm/backups/backup.log 2>&1" >> "$CRON_TEMP"

# NEW: Database backup at 2 AM (before main backup)
echo "0 2 * * * $HOME/projects/n8n-umkm/backup-postgres.sh >> $HOME/projects/n8n-umkm/backups/db-backup.log 2>&1" >> "$CRON_TEMP"

# NEW: Health check every 10 minutes
echo "*/10 * * * * $HOME/scripts/health-check.sh >> $HOME/scripts/health-check.log 2>&1" >> "$CRON_TEMP"

# NEW: Tunnel restart daily at 5 AM (recovery)
echo "0 5 * * * $HOME/scripts/tunnel-restart.sh >> $HOME/scripts/tunnel-restart.log 2>&1" >> "$CRON_TEMP"

# Install new crontab
crontab "$CRON_TEMP"
rm "$CRON_TEMP"

echo "Cron jobs installed:"
crontab -l
