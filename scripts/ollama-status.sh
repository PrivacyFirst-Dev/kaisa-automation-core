#!/usr/bin/env bash
set -euo pipefail

printf "[INFO] Ollama Status - $(date +%Y-%m-%d\ %H:%M:%S)\n"
printf "=========================================\n"

if systemctl is-active --quiet ollama 2>/dev/null; then
  printf "[OK] Service: running (systemd)\n"
  printf "\n[INFO] Models:\n"
  ollama list 2>/dev/null || printf "[WARNING] Gagal list models\n"
  printf "\n[INFO] API Version:\n"
  curl -s http://localhost:11434/api/version 2>/dev/null && \
    printf "\n" || \
    printf "[WARNING] API unreachable\n"
else
  printf "[ERROR] Service: NOT running\n"
  printf "[INFO] Start: sudo systemctl start ollama\n"
fi

printf "=========================================\n"
