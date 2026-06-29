# Cloudflare Edge Hardening & Zero-Trust Ingress
**Status:** PRODUCTION
**Last Updated:** 2026-06-30
**Scope:** Global Edge Security for Kaisa Labs Infrastructure & Client Deployments

## 1. Filosofi Keamanan Kaisa Labs
Di Kaisa Labs, kami percaya bahwa keamanan bukan sekadar fitur tambahan, melainkan fondasi arsitektur. Kami menerapkan prinsip *Privacy-First* dan *Zero-Trust* di setiap lapisan infrastruktur.

Dokumen ini merinci bagaimana kami mengamankan aset digital di level Edge (Cloudflare) dari eksploitasi publik, bot malicious, dan akses tidak sah—tanpa mengorbankan performa. Bagi klien kami, ini berarti data tidak pernah terekspos langsung ke internet publik (tanpa IP publik, tanpa port terbuka), dan setiap request diverifikasi identitasnya sebelum mencapai server asal (origin).

## 2. Arsitektur Ingress: Zero-Trust Tunnel
Berbeda dengan arsitektur konvensional yang mengandalkan port forwarding dan firewall berbasis IP, Kaisa Labs menggunakan **Cloudflare Tunnel (cloudflared)**.
- **No Open Ports:** Server asal (WSL2 / Hetzner VPS) menolak semua koneksi inbound (UFW default deny).
- **Outbound-Only Connection:** Tunnel membuat koneksi outbound terenkripsi ke jaringan global Cloudflare.
- **DDoS Mitigation:** Semua traffic diserap dan difilter oleh Edge Cloudflare sebelum mencapai tunnel.

## 3. Kontrol Keamanan Edge (Konfigurasi Aktif)
Konfigurasi berikut diterapkan secara global pada domain inti dan subdomain produksi untuk memastikan postur keamanan yang solid.

### 3.1. SSL/TLS & Kriptografi
| Parameter | Konfigurasi | Alasan Teknis |
|---|---|---|
| Always Use HTTPS | `ON` | Memaksa enkripsi transit, mencegah downgrade attack. |
| Minimum TLS Version | `TLS 1.2` | Menolak protokol usang (TLS 1.0/1.1) yang rentan eksploitasi. |
| TLS 1.3 | `ON` | Mengaktifkan standar enkripsi terbaru dengan performa lebih baik. |
| HSTS (Max-Age) | `15780000` (6 bln) | Memaksa browser selalu menggunakan HTTPS, termasuk subdomain. |

### 3.2. Web Application Firewall (WAF) & Bot Management
| Parameter | Konfigurasi | Alasan Teknis |
|---|---|---|
| Bot Fight Mode | `ON` | Menantang dan memblokir bot scraper/spammer otomatis di Edge. |
| Managed Transforms | `ON` | Menyembunyikan header server (`X-Powered-By`) untuk menyulitkan fingerprinting teknologi origin. |

### 3.3. Injeksi Security Headers
Disuntikkan secara otomatis di Edge melalui Managed Transforms untuk mencegah eksploitasi sisi klien:
- `X-Frame-Options: SAMEORIGIN` (Mencegah Clickjacking)
- `X-Content-Type-Options: nosniff` (Mencegah MIME-type sniffing)
- `Referrer-Policy: same-origin` (Membatasi kebocoran URL referer)

## 4. Identity & Access Management (Cloudflare Access)
Untuk aplikasi internal (n8n, Corteza CRM, Dolibarr ERP), keamanan tidak berhenti di WAF. Kami menerapkan **Cloudflare Access**:
- **Zero-Trust Verification:** Setiap request ke dashboard internal wajib melalui halaman autentikasi Cloudflare.
- **OTP / SSO Integration:** Akses hanya diberikan jika email user terdaftar dalam policy (misal: via OTP Email).
- **Bypass Public IP:** Aplikasi internal tidak memiliki route publik; hanya bisa diakses jika lolos verifikasi Access dan melewati Tunnel.

## 5. Strategi Deployment Klien (Tiered Edge Security)
Kaisa Labs menyesuaikan tingkat keamanan Edge berdasarkan profil risiko dan kebutuhan kepatuhan klien:

| Tier | Target Use Case | Cloudflare Plan | Justifikasi |
|---|---|---|---|
| **Standard** | Internal CRM/ERP, Blog Perusahaan | Free | Tunnel + Access + Basic Bot Protection sudah memadai untuk aplikasi non-publik. |
| **Pro** | E-Commerce Publik, SaaS, API Publik | Pro ($20/mo) | Membutuhkan OWASP Managed WAF Rules untuk memblokir SQLi/XSS, serta Super Bot Fight Mode. |
| **Enterprise** | Fintech, Healthcare, ISO 27001 Compliance | Business ($200/mo) | Membutuhkan SLA 100% Uptime, Total TLS, Custom Certificates, dan Priority Support. |

## 6. Infrastructure as Code (Terraform)
*Catatan: Konfigurasi manual di atas akan segera dimigrasikan ke Terraform untuk memastikan reproducibility dan version control pada infrastruktur Edge. Dokumen spesifikasi Terraform akan ditambahkan pada update berikutnya.*

## 7. Audit & Changelog
- **2026-06-30:** Initial Edge Hardening applied (HSTS, TLS 1.2+, Managed Transforms, Bot Fight Mode).
- **2026-06-26:** Cloudflare Access Policy implemented for 6 internal applications.
- **2026-06-17:** Cloudflare Tunnel `prod-wsl2-sg-core` rebuilt.
