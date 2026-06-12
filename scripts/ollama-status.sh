#!/bin/bash
# File: ~/scripts/ollama-status.sh
# Purpose: Check Ollama service status and models
# Usage: bash ~/scripts/ollama-status.sh

set -e

echo "=== Ollama Status ==="
echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# Check if Ollama process is running
if pgrep -f "ollama serve" > /dev/null; then
    echo "Service: Running"
    echo ""
    
    # List models
    echo "Models:"
    ollama list 2>/dev/null || echo "  (Failed to list models)"
    echo ""
    
    # API version check
    echo "API Version:"
    curl -s http://localhost:11434/api/version 2>/dev/null || echo "  (API unreachable)"
    echo ""
    
    # Quick inference test (optional, comment out if not needed)
    # echo "Quick Test:"
    # ollama run llama3.2:latest "ping" --nowordwrap 2>/dev/null | head -1 || echo "  (Test skipped)"
    
else
    echo "Service: Not running"
    echo ""
    echo "To start Ollama:"
    echo "  ollama serve"
    echo ""
    echo "Or via morning-start.sh:"
    echo "  bash ~/scripts/morning-start.sh"
fi
