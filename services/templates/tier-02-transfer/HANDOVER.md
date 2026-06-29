# Handover Checklist — Tier 02 (Build & Transfer)

## Pre-Flight VPS
- [ ] VPS Provisioned (Min 4 vCPU, 8GB RAM, 160GB SSD)
- [ ] Docker & Docker Compose v2 installed
- [ ] Cloudflare Tunnel configured & routed

## Deployment Steps
- [ ] Copy `.env.example` to `.env`
- [ ] Rotate ALL credentials (DB passwords, JWT secrets)
- [ ] Run `docker compose config --quiet`
- [ ] Run `docker compose up -d`
- [ ] Verify health via `docker compose ps`

## Client Handover
- [ ] Admin accounts created for n8n, Ghost, Corteza, Dolibarr
- [ ] DNS routed via Cloudflare Zero Trust
- [ ] BookStack client manual link shared
- [ ] Final invoice & source code access granted
