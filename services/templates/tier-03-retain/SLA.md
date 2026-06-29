# Service Level Agreement (SLA) — Tier 03 Retainer

## 1. Uptime & Monitoring
- Target Uptime: 99.5% (excluding planned maintenance)
- Monitoring: 24/7 via Uptime Kuma + Telegram Alerts
- Status Page: Provided via Cloudflare Tunnel (Public/Private)

## 2. Response Times
- Critical (System Down): < 2 Hours
- High (Core Feature Broken): < 8 Hours
- Normal (Bug/Request): < 48 Hours

## 3. Backup & Disaster Recovery
- Database Backup: Nightly (Retained 7 days locally, 30 days offsite)
- RTO (Recovery Time Objective): < 4 Hours
- RPO (Recovery Point Objective): < 24 Hours

## 4. Scope of Retainer
- Includes: OS patching, Docker image updates, log rotation, CI/CD pipeline maintenance.
- Excludes: New feature development, major version migrations (billed separately).
