#!/usr/bin/env bash
set -euo pipefail

LOG_DIR="/home/kaisa/projects/kaisa-automation-core/logs"

printf "[INFO] Log cleanup - $(date)
"

# Hapus log lebih dari 30 hari
find "$LOG_DIR" -name "*.log" -mtime +30 -delete && \
  printf "[OK] Log lama (>30 hari) dihapus.
" || \
  printf "[WARNING] Cleanup gagal.
"

# Hapus Docker log yang terlalu besar
printf "[INFO] Docker log sizes:
"
find /var/lib/docker/containers -name "*.log" -size +50M \
  -exec printf "[WARNING] Large log: {}
" \; 2>/dev/null || true

printf "[OK] Log cleanup done.
"
