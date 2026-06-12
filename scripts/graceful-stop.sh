#!/bin/bash
# File: ~/scripts/graceful-stop.sh
# Purpose: Graceful shutdown for all services
# Usage: bash ~/scripts/graceful-stop.sh

set -e

echo "=== Graceful Shutdown Started: $(date) ==="

# 1. Check for running backups
echo "[1/6] Checking for active backups..."
if pgrep -f "backup\.sh|pg_dump|mysqldump" > /dev/null; then
    echo "WARNING: Backup in progress. Waiting 60 seconds..."
    sleep 60
    if pgrep -f "backup\.sh|pg_dump|mysqldump" > /dev/null; then
        echo "ERROR: Backup still running. Abort shutdown or wait."
        exit 1
    fi
fi
echo "OK: No active backups"

# 2. Stop cron service
echo "[2/6] Stopping cron service..."
sudo service cron stop 2>/dev/null || true
echo "OK: Cron stopped"

# 3. Stop Cloudflare tunnel
echo "[3/6] Stopping Cloudflare tunnel..."
pkill -SIGINT -f "cloudflared" 2>/dev/null || true
sleep 3
echo "OK: Tunnel disconnected"

# 4. Stop Ollama
echo "[4/6] Stopping Ollama..."
if pgrep -f "ollama serve" > /dev/null; then
    pkill -f "ollama serve" 2>/dev/null || true
    sleep 3
fi
echo "OK: Ollama stopped"

# 5. Stop Docker containers (Fast & Safe)
echo "[5/6] Stopping Docker containers..."

# List semua container yang dikenal
CONTAINERS="n8n n8n-redis corteza corteza-db uptime-kuma chromadb open-webui ghost-blog ghost-db dolibarr-erp dolibarr-mysql"

# Stop satu per satu dengan timeout 10 detik (anti hang)
# Note: --timeout menggantikan flag --time yang deprecated
for container in $CONTAINERS; do
  echo "  -> $container"
  docker stop --timeout 10 "$container" 2>/dev/null || true
done
echo "OK: Docker containers stopped"

# 6. Log shutdown
echo "[6/6] Logging shutdown..."
echo "Shutdown: $(date '+%Y-%m-%d %H:%M:%S')" >> ~/scripts/shutdown.log

echo ""
echo "=== All services stopped gracefully ==="
echo "Safe to shutdown laptop now."
echo "Next startup: bash ~/scripts/morning-start.sh"
