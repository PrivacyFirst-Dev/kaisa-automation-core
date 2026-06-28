## Ghost Healthcheck Fix - 2026-05-29
- Service: ghost, Container: ghost-blog
- Issue: wget BusyBox follow redirect 301 ke HTTPS → SSL handshake fail
- Fix: replace test dengan nc -z 127.0.0.1 2368 (TCP layer check)
- Result: Exit 0, status healthy

## Post-Audit Fixes — 2026-05-30
### Applied
- [x] backup.sh: stderr suppression → error log redirect
- [x] backup .env files: permission 644 → 600
- [x] docker-compose.corteza.yml: added name: kaisa-corteza
- [x] docker-compose.monitoring.yml: added name: kaisa-monitoring
- [x] docs/structure-gap.md: missing folders list (echo fix)
- [x] docs/env-isolation.md: duplicate keys (echo fix)
- [x] docs/stack-map.md: Mermaid diagram generated

### Pending (Pre-Migration)
- [x] services/dolibarr: port 8888 verified
- [x] chromadb: healthcheck added (/proc/net/tcp)
- [ ] .gitea/workflows/: create validate.yml + deploy.yml
- [ ] ansible/: create inventory + roles structure

## Infrastructure Changes — June 2026
- [x] n8n SQLite → PostgreSQL migration (Jun 14 2026)
- [x] Cloudflare Tunnel rebuilt prod-wsl2-sg-core (Jun 17 2026)
- [x] Ghost compose moved to services/ghost/ (Jun 20 2026)
- [x] Dolibarr formalized to services/dolibarr/ (Jun 20 2026)
- [x] .wslconfig hardened (Jun 20 2026)
- [x] kaisa-net orphan removed (Jun 21 2026)
- [x] Defender Exclusions applied (Jun 21 2026)
- [x] Cloudflare Access Policy 6 apps (Jun 26 2026)
- [x] Cal.com cloud setup kaisalabs (Jun 27 2026)
- [x] Ghost SMTP Zoho configured (Jun 28 2026)
- [x] Scripts suite production-ready (Jun 20-28 2026)
