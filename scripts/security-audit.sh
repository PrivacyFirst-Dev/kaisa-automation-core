#!/usr/bin/env bash
set -euo pipefail

printf "=== Security Audit - $(date) ===
"
printf "
"

# 1. Port exposure check
printf "[CHECK] 1. Port Exposure (tidak boleh ada 0.0.0.0):
"
EXPOSED=$(docker ps --format "{{.Names}}: {{.Ports}}" | grep "0.0.0.0" | grep -v "3000")
if [ -z "$EXPOSED" ]; then
  printf "[OK] Semua port localhost-only atau Zero Trust exception.
"
else
  printf "[WARNING] Port expose ke 0.0.0.0:
"
  printf "
" "$EXPOSED"
fi
printf "
"

# 2. Docker disk usage
printf "[CHECK] 2. Docker Disk Usage:
"
docker system df
printf "
"

# 3. Cloudflare tunnel status
printf "[CHECK] 3. Cloudflare Tunnel Status:
"
if systemctl is-active --quiet cloudflared 2>/dev/null; then
  printf "[OK] cloudflared aktif via systemd.
"
else
  printf "[WARNING] cloudflared tidak aktif.
"
fi
printf "
"

# 4. Container restart count (indikator crash loop)
printf "[CHECK] 4. Container Restart Count (>3 = potential crash loop):
"
docker inspect $(docker ps -q) \
  --format "{{.Name}}: restarts={{.RestartCount}}" 2>/dev/null | \
  sed "s|/||" | sort
printf "
"

# 5. Images dengan tag latest (tidak pinned)
printf "[CHECK] 5. Images dengan tag latest (tidak pinned version):
"
docker images --format "{{.Repository}}:{{.Tag}}" | grep ":latest" | sort
printf "
"

# 6. Cek .env tidak ter-expose di git
printf "[CHECK] 6. .env tidak masuk git:
"
cd "/home/kaisa/projects/kaisa-automation-core"
if git ls-files | grep -q "^\.env$"; then
  printf "[CRITICAL] .env ADA DI GIT TRACKING.
"
else
  printf "[OK] .env tidak di git.
"
fi
printf "
"

printf "=== Audit Complete ===
"
