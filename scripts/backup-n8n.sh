#!/bin/sh
set -eu

# Kaisa Labs — n8n Workflow Backup
# Created: 2026-05-15 | Standard: Production

# Load Environment Variable
ENV_FILE="/home/kaisa/projects/kaisa-automation-core/.env"
if [ -f "${ENV_FILE}" ]; then
    set -a; . "${ENV_FILE}"; set +a
fi

# Validation
if [ -z "${N8N_API_KEY:-}" ]; then
    printf "[ERROR] N8N_API_KEY not set. Aborting.\n" >&2
    exit 1
fi

# Configuration
BACKUP_DIR="/home/kaisa/projects/kaisa-automation-core/backups"
LOG_FILE="${BACKUP_DIR}/backup-n8n.log"
RETENTION_DAYS=7
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
OUTPUT_FILE="${BACKUP_DIR}/workflows-${TIMESTAMP}.json"

# Helper: Logging
log() { printf "[%s] %s\n" "$(date +'%Y-%m-%d %H:%M:%S')" "$1" | tee -a "${LOG_FILE}"; }

# Execution
mkdir -p "${BACKUP_DIR}"
log "Starting n8n workflow backup..."

# API Request (Constraint: 127.0.0.1)
HTTP_CODE="$(curl -s -o "${OUTPUT_FILE}" -w "%{http_code}" \
    -H "X-N8N-API-KEY: ${N8N_API_KEY}" \
    "http://127.0.0.1:5678/api/v1/workflows?active=true" \
    --max-time 30)"

# Response Check
if [ "${HTTP_CODE}" = "200" ]; then
    log "SUCCESS: Backup saved to workflows-${TIMESTAMP}.json"
else
    log "ERROR: API returned HTTP ${HTTP_CODE}"
    rm -f "${OUTPUT_FILE}"
    exit 1
fi

# Retention Policy
find "${BACKUP_DIR}" -name "workflows-*.json" -type f -mtime +${RETENTION_DAYS} -delete 2>/dev/null
log "Cleanup complete."
