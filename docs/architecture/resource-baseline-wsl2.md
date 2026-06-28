# Resource Baseline WSL2 — Updated 2026-06-29
## Global Metrics
- WSL2 RAM: 16GB (Allocated via .wslconfig)
- Container RAM: ~2.18GB (Actual, 12 containers)
- Headroom: ~13.8GB
- CPU: 3 vCPU (Allocated)
- Swap: 8GB (D:\wsl-swap.vhdx)
- Docker: 29.1.4 (WSL2 Native)
- Status: OPTIMAL - Siap Phase 2 & Client Sprint

## Container RAM Breakdown (docker stats)
| Container | RAM Usage |
|---|---|
| kaisa-open-webui-open-webui-1 | 763.1 MiB |
| ghost-mysql | 388.5 MiB |
| kaisa-core-n8n-1 | 370.0 MiB |
| kaisa-uptime-kuma-uptime-kuma-1 | 131.4 MiB |
| dolibarr-erp | 118.4 MiB |
| dolibarr-mysql | 109.5 MiB |
| ghost-blog | 108.9 MiB |
| kaisa-corteza-corteza-app-1 | 73.29 MiB |
| kaisa-core-postgres-1 | 48.14 MiB |
| kaisa-corteza-corteza-db-1 | 44.06 MiB |
| kaisa-core-chromadb-1 | 12.89 MiB |
| kaisa-core-redis-1 | 7.027 MiB |
| **TOTAL** | **~2175.2 MiB (~2.12 GB)** |
