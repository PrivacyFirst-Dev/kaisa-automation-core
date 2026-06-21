# Windows Host Baseline untuk WSL2 Production
## Status: LOCKED (06:00-22:00 Cycle)
- WSL2 Memory Limit: 16GB (via .wslconfig)
- Swap/Pagefile: D:\ (32-65GB) — C:\ SSD protected
- Power Plan: High Performance (plugged in)
- Startup Apps: Minimal (non-essential disabled)
- Docker Backend: WSL2 Native (no Hyper-V overhead)
- Browser RAM: Firefox multi-process ~5.5GB (monitor during prod)
- Schedule: Task Scheduler auto-start 06:00, graceful-stop 21:50
## Audit Findings (Baseline)
- vmmemWSL: ~6.8GB (within 16GB limit)
- Container RAM: ~2.15GB total (optimal)
- High CPU accumulators: Firefox, CrossDeviceService, audiodg
- Action: Disable non-critical startup, enforce High Performance plan
