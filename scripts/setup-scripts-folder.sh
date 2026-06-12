#!/bin/bash
set -e
SCRIPTS_DIR="$HOME/scripts"
mkdir -p "$SCRIPTS_DIR"
echo "Creating utility scripts..."
cat > "$SCRIPTS_DIR/health-check.sh" << 'EOF'
#!/bin/bash
set -e
echo "Services Health Check - $(date)"
docker ps --format "table {{.Names}}\t{{.Status}}"
cloudflared tunnel list 2>/dev/null | grep ai-agency-kaisa || echo "Tunnel: Not running"
curl -s -o /dev/null -w "n8n: %{http_code}\n" https://n8n.privacyfirstautomation.com
curl -s -o /dev/null -w "blog: %{http_code}\n" https://blog.privacyfirstautomation.com
curl -s -o /dev/null -w "crm: %{http_code}\n" https://crm.privacyfirstautomation.com
echo "Health check complete"
EOF
chmod +x "$SCRIPTS_DIR/health-check.sh"
cat > "$SCRIPTS_DIR/tunnel-restart.sh" << 'EOF'
#!/bin/bash
set -e
TUNNEL_ID="1c060bed-c2d2-479c-8b59-c9e4e9dba15e"
pkill -SIGINT -f "cloudflared tunnel run" 2>/dev/null || true
sleep 3
nohup cloudflared --no-autoupdate tunnel run "$TUNNEL_ID" > /tmp/cloudflared.log 2>&1 &
sleep 5
cloudflared tunnel list | grep "$TUNNEL_ID" && echo "Tunnel restarted" || echo "Tunnel restart failed"
EOF
chmod +x "$SCRIPTS_DIR/tunnel-restart.sh"
cat > "$SCRIPTS_DIR/morning-start.sh" << 'EOF'
#!/bin/bash
set -e
cd "$HOME/projects/n8n-umkm" || exit 1
docker compose up -d 2>/dev/null || true
docker compose -f docker-compose.corteza.yml up -d 2>/dev/null || true
docker compose -f docker-compose.monitoring.yml up -d 2>/dev/null || true
docker compose -f ghost-content/docker-compose.yml up -d 2>/dev/null || true
docker compose -f dolibarr/docker-compose.yml up -d 2>/dev/null || true
sleep 30
"$HOME/scripts/tunnel-restart.sh"
echo "All services started"
EOF
chmod +x "$SCRIPTS_DIR/morning-start.sh"
echo "Scripts folder setup complete"
ls -lh "$SCRIPTS_DIR/"
