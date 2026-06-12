#!/bin/bash
# File: ~/scripts/morning-start.sh
# Purpose: Start ALL services one-command
# Usage: bash ~/scripts/morning-start.sh

set -e
cd "$HOME/projects/kaisa-automation-core" || exit 1

echo "Starting all services..."

# 1. Docker stacks utama (compose-based services)
echo "[1/5] Starting Docker Compose stacks..."
docker compose up -d 2>/dev/null || true
docker compose -f docker-compose.corteza.yml up -d 2>/dev/null || true
docker compose -f docker-compose.monitoring.yml up -d 2>/dev/null || true
docker compose -f services/ghost/ghost-content/docker-compose.yml up -d 2>/dev/null || true
docker compose -f docker-compose.dolibarr.yml up -d 2>/dev/null || true

# Open WebUI jika compose file ada
if [ -f "services/open-webui/docker-compose.yml" ]; then
    docker compose -f services/open-webui/docker-compose.yml up -d 2>/dev/null || true
    echo "  -> Open WebUI (compose) started"
fi

# 2. Start standalone containers (created via docker run)
echo "[2/5] Starting standalone containers..."
docker start uptime-kuma 2>/dev/null || true
docker start chromadb 2>/dev/null || true
docker start open-webui 2>/dev/null || true
docker start ghost-blog 2>/dev/null || true
docker start ghost-db 2>/dev/null || true
echo "  -> Standalone containers started"

# 3. Wait for containers to be ready
echo "[3/5] Waiting for services to initialize..."
sleep 30

# 4. Ollama native WSL service
echo "[4/5] Starting Ollama..."
if command -v ollama &> /dev/null; then
    pkill -f "ollama serve" 2>/dev/null || true
    sleep 2
    nohup ollama serve > /tmp/ollama.log 2>&1 &
    sleep 5
    echo "  -> Ollama started"
fi

# 5. Cloudflare tunnel
echo "[5/5] Starting Cloudflare tunnel..."
"$HOME/scripts/tunnel-restart.sh"

echo ""
echo "=== All services started ==="
echo "Verify: docker ps | grep -E 'n8n|corteza|uptime|chroma|ghost|webui'"
echo "Access: http://localhost:5678 (n8n), http://localhost:3001 (Uptime Kuma)"
