# Tier 01: Managed Hosting

Stack minimal untuk klien yang membutuhkan automation dan CMS.

## Komponen
- n8n (Automation)
- PostgreSQL 16 (Database)
- Ghost (CMS)

## Deployment
1. Copy `.env.example` ke `.env`
2. Ubah semua `CHANGE_ME` dengan credential kuat
3. Jalankan `docker compose config --quiet` untuk validasi
4. Jalankan `docker compose up -d`
