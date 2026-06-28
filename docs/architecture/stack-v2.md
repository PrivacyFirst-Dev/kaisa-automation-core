## Stack Architecture — Kaisa Labs v2 (WSL2 Production)

```mermaid
graph TD
  subgraph Edge [Cloudflare Zero Trust]
    CF[Cloudflare Tunnel] --> CFA[Cloudflare Access Policy]
  end
  subgraph WSL2_Production [WSL2 Ubuntu Environment]
    n8n[n8n :5678]
    crm[Corteza :8080]
    erp[Dolibarr :8888]
    cms[Ghost :2368]
    ai[Open-WebUI :3000]
    mon[Uptime-Kuma :3001]
    db_pg_n8n[(n8n-Postgres :5432)]
    db_pg_crm[(Corteza-DB :5432)]
    db_ma[(Dolibarr-DB :3306)]
    db_my[(Ghost-DB :3306)]
    redis[(Redis :6379)]
    chroma[(ChromaDB :8000)]
  end

  CFA --> n8n
  CFA --> crm
  CFA --> erp
  CFA --> cms
  CFA --> ai
  CFA --> mon

  n8n --> redis
  n8n --> db_pg_n8n
  n8n --> chroma
  crm --> db_pg_crm
  erp --> db_ma
  cms --> db_my
```

## Healthcheck & Constraint Mapping
- Ghost: `nc -z 127.0.0.1 2368` (TCP bypass redirect/SSL)
- ChromaDB: `/proc/net/tcp :1F40` (Hex 8000)
- Port binding: `127.0.0.1:PORT` (Rule 05)
- Restart: `unless-stopped` (Rule 06)
- Logging: `json-file max-size=10m max-file=3` (Rule 07)
- Project name: `kaisa-[service]` mandatory (Rule 12)
