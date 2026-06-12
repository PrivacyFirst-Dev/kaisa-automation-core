# Kaisa Labs

Privacy-First AI Automation Infrastructure

![Self-Hosted](https://img.shields.io/badge/Self--Hosted-100%25-00c9a7?style=flat-square)
![Zero Trust](https://img.shields.io/badge/Zero--Trust-Cloudflare-f38020?style=flat-square)
![Data Sovereignty](https://img.shields.io/badge/Data-Your%20Server-2255ff?style=flat-square)
![Ollama](https://img.shields.io/badge/Ollama-Local%20LLM-4CB4FF?style=flat-square)

> Automation without surveillance.

## What This Repo Contains

A sanitized blueprint of the Kaisa Labs self-hosted AI automation stack.
All services run on your infrastructure. No cloud vendor. No telemetry. No lock-in.

**No credentials, no production config, no stateful data are included.**
This repository is a reference architecture only.

## Live Services (via Cloudflare Tunnel)

All services bind exclusively to `127.0.0.1`.
Public access is secured via Cloudflare Zero-Trust Tunnel. No open ports.

| Service | URL | Stack |
|---|---|---|
| Workflow Engine | https://n8n.privacyfirstautomation.com | n8n + Redis |
| CRM | https://crm.privacyfirstautomation.com | Corteza + PostgreSQL |
| ERP | https://erp.privacyfirstautomation.com | Dolibarr + MariaDB |
| Blog | https://blog.privacyfirstautomation.com | Ghost + MySQL |
| Monitoring | https://monitor.privacyfirstautomation.com | Uptime Kuma |

## Core Stack

| Component | Technology | Role |
|---|---|---|
| Automation Engine | n8n + Redis | Workflow orchestration |
| Local AI Inference | Ollama | llama3.2, nomic-embed-text |
| Vector Database | ChromaDB | Offline RAG pipeline |
| CRM | Corteza | Customer relationship |
| ERP | Dolibarr | Business operations |
| CMS | Ghost | Blog and work showcase |
| Monitoring | Uptime Kuma | Health check + Telegram alert |
| Edge Access | Cloudflare Tunnel | Zero-trust ingress |

## Architecture Principles

Every service binding goes to `127.0.0.1`. Not `0.0.0.0`.
Every container runs with `restart: unless-stopped` and log rotation.
Credentials are isolated per service via separate env files.
CI pipeline runs Trivy security scan before every deployment.
Deployments use a server-pull GitOps model. No manual SSH.

## Ecosystem Impact

This repository addresses a critical gap in the open-source AI ecosystem: the lack of secure, privacy-preserving deployment patterns. By enforcing strict Zero-Trust networking and offline-capable AI inference, this blueprint enables downstream developers, SMBs, and researchers to deploy autonomous agents without surrendering operational data to third-party telemetry or cloud vendors. It serves as a foundational reference for building self-hosted AI infrastructure that respects data sovereignty.

## Philosophy

Most automation tutorials assume you are fine sending client data to third-party APIs.
We are not fine with that assumption.

Three non-negotiables in every system we build:

1. **Data ownership** - your data stays on your infrastructure.
2. **Transparent configuration** - you receive the full compose file. No black box.
3. **Security by design** - port isolation, network segmentation, proactive monitoring.

## Contact

Portfolio and services: [privacyfirstautomation.com](https://privacyfirstautomation.com)
Work showcase: [privacyfirstautomation.com/work](https://blog.privacyfirstautomation.com/work)
Email: [hello@privacyfirstautomation.com](mailto:hello@privacyfirstautomation.com)

_Last updated: 2026-06-12_
