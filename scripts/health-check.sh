#!/usr/bin/env bash
set -euo pipefail

printf "[INFO] Health Check - \n" "$(date)"
printf "===========================================\n"

printf "[CONTAINERS]\n"
docker ps --format "  {{.Names}}: {{.Status}}" | sort

printf "\n[RESOURCE USAGE]\n"
docker stats --no-stream \
  --format "  {{.Name}}: CPU={{.CPUPerc}} MEM={{.MemUsage}}"

printf "\n[SYSTEMD SERVICES]\n"
for svc in cloudflared ollama; do
  STATUS=$(systemctl is-active "$svc" 2>/dev/null || printf "not-found")
  printf "  %s: %s\n" "$svc" "$STATUS"
done

printf "\n[MEMORY]\n"
free -h | grep -E "Mem|Swap"

printf "\n[TUNNEL]\n"
curl -s -o /dev/null \
  -w "  blog.privacyfirstautomation.com: %{http_code}\n" \
  "https://blog.privacyfirstautomation.com" \
  --max-time 5 2>/dev/null || \
  printf "  tunnel: unreachable\n"

printf "===========================================\n"
