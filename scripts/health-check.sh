#!/usr/bin/env bash
set -euo pipefail

printf "[INFO] Health Check - $(date)
"
printf "===========================================
"

# Container status
printf "[CONTAINERS]
"
docker ps --format "  {{.Names}}: {{.Status}}" | sort

# Resource usage
printf "
[RESOURCE USAGE]
"
docker stats --no-stream --format "  {{.Name}}: CPU={{.CPUPerc}} MEM={{.MemUsage}}"

# Systemd services
printf "
[SYSTEMD SERVICES]
"
for svc in cloudflared ollama; do
  STATUS=$(systemctl is-active "$svc" 2>/dev/null || printf "not-found")
  printf "  : 
" "$svc" "$STATUS"
done

# RAM/Swap
printf "
[MEMORY]
"
free -h | grep -E "Mem|Swap"

# Tunnel status
printf "
[TUNNEL]
"
curl -s -o /dev/null -w "  blog.privacyfirstautomation.com: %{http_code}
" \
  "https://blog.privacyfirstautomation.com" --max-time 5 2>/dev/null || \
  printf "  tunnel: unreachable
"

printf "===========================================
"
