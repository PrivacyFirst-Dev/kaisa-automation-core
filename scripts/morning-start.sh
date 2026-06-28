#!/usr/bin/env bash
set -euo pipefail

PROJ_ROOT="/home/kaisa/projects/kaisa-automation-core"
LOG_DIR="$PROJ_ROOT/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/morning-start-$(date +%Y%m%d).log"

log() { printf "[%s] %s\n" "$(date +%H:%M:%S)" "$1" | tee -a "$LOG_FILE"; }

log "[INFO] Morning start sequence initiated."

if ! docker info >/dev/null 2>&1; then
  log "[ERROR] Docker daemon tidak aktif. Abort."
  exit 1
fi
log "[OK] Docker daemon aktif."

log "[INFO] Starting kaisa-core (Layer 1)..."
cd "$PROJ_ROOT"
docker compose -p kaisa-core up -d --remove-orphans >> "$LOG_FILE" 2>&1
log "[OK] kaisa-core containers up."

log "[INFO] Waiting for PostgreSQL to be healthy..."
COUNT=0
PG_STATUS="starting"
while [ "$COUNT" -lt 30 ]; do
  PG_STATUS=$(docker inspect --format="{{.State.Health.Status}}" kaisa-core-postgres-1 2>/dev/null || printf "missing")
  [ "$PG_STATUS" = "healthy" ] && break
  COUNT=$((COUNT + 1))
  sleep 2
done
if [ "$PG_STATUS" != "healthy" ]; then
  log "[ERROR] PostgreSQL tidak healthy setelah 60 detik. Abort."
  exit 1
fi
log "[OK] PostgreSQL healthy."

log "[INFO] Starting Layer 2 services..."
for entry in \
  "kaisa-ghost:$PROJ_ROOT/services/ghost/docker-compose.yml" \
  "kaisa-dolibarr:$PROJ_ROOT/services/dolibarr/docker-compose.yml" \
  "kaisa-corteza:$PROJ_ROOT/services/corteza/docker-compose.yml" \
  "kaisa-open-webui:$PROJ_ROOT/services/open-webui/docker-compose.yml" \
  "kaisa-uptime-kuma:$PROJ_ROOT/services/uptime-kuma/docker-compose.yml"; do
  stack_name="${entry%%:*}"
  stack_file="${entry#*:}"
  if [ -f "$stack_file" ]; then
    log "[INFO] Starting $stack_name..."
    docker compose -p "$stack_name" -f "$stack_file" up -d --remove-orphans >> "$LOG_FILE" 2>&1
    log "[OK] $stack_name up."
  else
    log "[WARNING] $stack_file tidak ditemukan. Skip."
  fi
done

for svc in cloudflared ollama; do
  if systemctl is-active --quiet "$svc" 2>/dev/null; then
    log "[OK] $svc aktif."
  else
    log "[INFO] Starting $svc via systemd..."
    sudo systemctl start "$svc" >> "$LOG_FILE" 2>&1 && \
      log "[OK] $svc started." || \
      log "[WARNING] $svc gagal start."
  fi
done

log "[INFO] Waiting 60s for all services to stabilize..."
sleep 20

log "[INFO] Running health checks..."
HEALTHY=true

for svc in \
  "kaisa-core-postgres-1" "kaisa-core-redis-1" "kaisa-core-chromadb-1" "kaisa-core-n8n-1" \
  "kaisa-corteza-corteza-db-1" "kaisa-corteza-corteza-app-1" \
  "ghost-mysql" "ghost-blog" "dolibarr-mysql" "dolibarr-erp" \
  "kaisa-open-webui-open-webui-1" "kaisa-uptime-kuma-uptime-kuma-1"; do
  STATUS=$(docker inspect --format="{{.State.Health.Status}}" "$svc" 2>/dev/null || printf "missing")
  if [ "$STATUS" = "healthy" ] || [ "$STATUS" = "none" ] || [ "$STATUS" = "running" ]; then
    log "[OK] $svc ($STATUS)"
  else
    log "[WARNING] $svc status: $STATUS"
    HEALTHY=false
  fi
done

if [ "$HEALTHY" = "true" ]; then
  log "[OK] All services healthy. Morning start COMPLETE."
else
  log "[WARNING] One or more services not healthy. Check: docker ps -a"
fi

log "[INFO] Log tersimpan di: $LOG_FILE"
