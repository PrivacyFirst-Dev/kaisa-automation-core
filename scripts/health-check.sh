#!/bin/bash
set -e
echo "Services Health Check - $(date)"
docker ps --format "table {{.Names}}\t{{.Status}}"
cloudflared tunnel list 2>/dev/null | grep ai-agency-kaisa || echo "Tunnel: Not running"
curl -s -o /dev/null -w "n8n: %{http_code}\n" https://n8n.privacyfirstautomation.com
curl -s -o /dev/null -w "blog: %{http_code}\n" https://blog.privacyfirstautomation.com
curl -s -o /dev/null -w "crm: %{http_code}\n" https://crm.privacyfirstautomation.com
echo "Health check complete"
