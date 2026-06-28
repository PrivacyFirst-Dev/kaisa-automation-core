# Windows Host Baseline untuk WSL2 Production
## Status: HARDENED & LOCKED
- WSL2 Memory Limit: 16GB (via .wslconfig)
- WSL2 Config: vmIdleTimeout=-1, firewall=true, pageReporting=false
- Swap/Pagefile: D:\ (32-65GB) — C:\ SSD protected
- Defender Exclusions: Active (D:\WSL, D:\DockerData, wsl.exe, vmwp.exe)
- Power Plan: High Performance (plugged in), Sleep Prevention S3 locked
- Startup Apps: Minimal (non-essential disabled)
- Docker Backend: WSL2 Native (no Hyper-V overhead)
- Browser RAM: Firefox multi-process ~5.5GB (monitor during prod)

## Audit Findings (Baseline)
- vmmemWSL: ~6.8GB (within 16GB limit)
- Container RAM: ~2.18GB total (12 containers, optimal)
- High CPU accumulators: Firefox, CrossDeviceService, audiodg
- Action: Disable non-critical startup, enforce High Performance plan
