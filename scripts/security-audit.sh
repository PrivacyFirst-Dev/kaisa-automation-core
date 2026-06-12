#!/bin/bash
# File: ~/scripts/security-audit.sh
# Purpose: Monthly security check
# Usage: bash ~/scripts/security-audit.sh

set -e

echo "=== Security Audit - $(date) ==="
echo ""

# 1. Check exposed ports
echo "1. Exposed Ports:"
docker ps --format "table {{.Names}}\t{{.Ports}}" | grep -v "127.0.0.1" | grep -v "PORTS" || echo "OK: All ports localhost-only"
echo ""

# 2. Docker disk usage
echo "2. Docker Disk Usage:"
docker system df --format "table {{.Type}}\t{{.Size}}"
echo ""

# 3. Cloudflare tunnel routes
echo "3. Cloudflare Tunnel Routes:"
grep "hostname:" ~/.cloudflared/config.yml 2>/dev/null || echo "Config not found"
echo ""

# 4. Recent auth failures
echo "4. Recent Auth Failures:"
if [ -f /var/log/auth.log ]; then
    grep "Failed" /var/log/auth.log 2>/dev/null | tail -3 || echo "OK: No recent failures"
else
    echo "WSL: auth.log not available"
fi
echo ""

# 5. Check for outdated images
echo "5. Outdated Images (run docker compose pull to update):"
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.CreatedAt}}" | head -10
echo ""

echo "=== Audit Complete ==="
