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
- [ ] services/dolibarr: verify port 8888 binding
- [ ] chromadb: add healthcheck block
- [ ] .gitea/workflows/: create validate.yml + deploy.yml
- [ ] ansible/: create inventory + roles structure
