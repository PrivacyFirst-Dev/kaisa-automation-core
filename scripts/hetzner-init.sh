#!/usr/bin/env bash
set -euo pipefail
# Hetzner CX43 Post-Provision Init
printf "[INFO] Updating system packages...\n"
apt-get update && apt-get upgrade -y
printf "[INFO] Installing base dependencies...\n"
apt-get install -y docker.io docker-compose-plugin curl wget jq ufw fail2ban
printf "[INFO] Enabling Docker & firewall...\n"
systemctl enable --now docker
ufw allow 22/tcp
ufw --force enable
printf "[INFO] Creating project structure...\n"
mkdir -p /opt/kaisa-labs/{backups,logs,scripts}
printf "[INFO] Init complete. Proceed with GitOps pull.\n"
