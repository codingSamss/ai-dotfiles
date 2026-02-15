#!/bin/bash
set -euo pipefail

NEED_MANUAL=0

echo "[reddit] 检查 Python3..."
if ! command -v python3 >/dev/null 2>&1; then
  if command -v brew >/dev/null 2>&1; then
    echo "[reddit] 安装 Python3"
    brew install python3
  else
    echo "[reddit] 未检测到 Python3，且无 Homebrew，请手动安装 Python3"
    NEED_MANUAL=1
  fi
fi

echo "[reddit] 检查 Composio SDK..."
if command -v python3 >/dev/null 2>&1; then
  if python3 -c "import composio" >/dev/null 2>&1; then
    echo "[reddit] composio 已安装"
  else
    echo "[reddit] 安装 composio"
    python3 -m pip install composio
  fi
fi

CLAUDE_JSON="$HOME/.claude.json"
if [ -f "$CLAUDE_JSON" ] && python3 -c "
import json, sys
with open('$CLAUDE_JSON') as f:
    cfg = json.load(f)
sys.exit(0 if 'composio-reddit' in cfg.get('mcpServers', {}) else 1)
" 2>/dev/null; then
  echo "[reddit] composio-reddit MCP 已配置"
else
  echo "[reddit] composio-reddit MCP 未配置，请按 README 指引完成 OAuth 授权"
  NEED_MANUAL=1
fi

if [ "$NEED_MANUAL" -eq 1 ]; then
  exit 2
fi
