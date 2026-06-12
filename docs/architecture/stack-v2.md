## Stack Architecture — Kaisa Labs v2

```mermaid
graph TD
  subgraph Edge [Cloudflare Zero Trust]
    CF[Cloudflare Tunnel]
  end
  subgraph Hetzner_CX43 [VPS Production]
    n8n[n8n :5678]
    crm[Corteza :8080]
    erp[Dolibarr :8888]
    cms[Ghost :2368]
    ai[Open-WebUI :3000]
    mon[Uptime-Kuma :3001]
    db_pg[(Corteza-DB :5433)]
    db_ma[(Dolibarr-DB :3306)]
    db_my[(Gho…-> cms
  CF --> ai
  CF --> mon
  n8n --> db_ma
  crm --> db_pg
  cms --> db_my
```

## Healthcheck & Constraint Mapping
- Ghost: `nc -z 127.0.0.1 2368` (TCP bypass redirect/SSL)
- Port binding: `127.0.0.1:PORT` (Rule 05)
- Restart: `unless-stopped` (Rule 06)
- Logging: `json-file max-size=10m max-file=3` (Rule 07)
- Project name: `kaisa-[service]` mandatory (Rule 12)
