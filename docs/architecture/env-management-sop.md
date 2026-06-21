# SOP: Centralized .env Resolution
## Pola
- Single source of truth: ~/projects/kaisa-automation-core/.env
- Distribusi: Relative symlink (../../.env) di setiap folder services/[name]/
- Permission: chmod 600 .env (owner read/write only)
- Git: .env di .gitignore. Symlink pointer aman di-commit.

## Alasan Arsitektural
- Mencegah config drift antar environment
- Konsisten dengan eksekusi script otomatis (morning-start.sh, CI/CD)
- Menghilangkan ketergantungan pada CWD atau flag -f

## Roadmap Phase 2
- Migrasi ke explicit env_file: ../../.env di docker-compose.yml
- Pemecahan .env.service per klien untuk isolasi credential (Skenario 02/03)
