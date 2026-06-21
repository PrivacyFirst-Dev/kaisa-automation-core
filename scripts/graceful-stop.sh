#!/usr/bin/env bash
set -euo pipefail

PROJ_ROOT="/home/kaisa/projects/kaisa-automation-core"
LOG_DIR="$PROJ_ROOT/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/graceful-stop-$(date +%Y%m%d).log"

log() { printf "[%s] %s
" "$(date +%H:%M:%S)" "$1" | tee -a "$LOG_FILE"; }

log "[INFO] Graceful stop sequence initiated."

# 1. Snapshot state sebelum stop
log "[INFO] Snapshot container state..."
docker ps --format "table {{.Names}}	{{.Status}}" | tee -a "$LOG_FILE"

# 2. Stop Layer 2 dulu (urutan terbalik dari start)
log "[INFO] Stopping Layer 2 services..."

for entry in \
  "kaisa-uptime-kuma:$PROJ_ROOT/services/uptime-kuma/docker-compose.yml" \
  "kaisa-open-webui:$PROJ_ROOT/services/open-webui/docker-compose.yml" \
  "kaisa-corteza:$PROJ_ROOT/services/corteza/docker-compose.yml" \
  "kaisa-dolibarr:$PROJ_ROOT/services/dolibarr/docker-compose.yml" \
  "kaisa-ghost:$PROJ_ROOT/services/ghost/docker-compose.yml"; do
  stack_name="${entry%:*}"
  stack_file="${entry#*:}"
  if [ -f "$stack_file" ]; then
    log "[INFO] Stopping $stack_name..."
    docker compose -p "$stack_name" -f "$stack_file" stop >> "$LOG_FILE" 2>&1 && \
      log "[OK] $stack_name stopped." || \
      log "[WARNING] $stack_name stop gagal, lanjut."
  fi
done

# 3. Stop Layer 1 terakhir
log "[INFO] Stopping kaisa-core (Layer 1)..."
cd "$PROJ_ROOT"
docker compose -p kaisa-core stop >> "$LOG_FILE" 2>&1 && \
  log "[OK] kaisa-core stopped." || \
  log "[WARNING] kaisa-core stop gagal."

# 4. Verifikasi semua container down
sleep 5
RUNNING=$(docker ps -q 2>/dev/null | wc -l)
if [ "$RUNNING" -eq 0 ]; then
  log "[OK] All containers stopped. Safe to shutdown WSL."
else
  log "[WARNING] $RUNNING container masih running:"
  docker ps --format "  {{.Names}}: {{.Status}}" | tee -a "$LOG_FILE"
  log "[INFO] Force stop remaining containers..."
  docker stop $(docker ps -q) >> "$LOG_FILE" 2>&1
  log "[OK] Force stop done."
fi

log "[INFO] Log tersimpan di: $LOG_FILE"
log "[INFO] Sekarang aman menjalankan: wsl --shutdown dari PowerShell"
