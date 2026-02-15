#!/bin/bash
set -euo pipefail

NEED_MANUAL=0
CLAUDE_JSON="$HOME/.claude.json"

echo "[cc-codex-review] 检查 Codex MCP 配置..."
if [ -f "$CLAUDE_JSON" ] && python3 -c "
import json, sys
with open('$CLAUDE_JSON') as f:
    cfg = json.load(f)
sys.exit(0 if 'codex' in cfg.get('mcpServers', {}) else 1)
" 2>/dev/null; then
  echo "[cc-codex-review] codex MCP 已配置"
else
  echo "[cc-codex-review] 未检测到 codex MCP，请执行:"
  echo "  claude mcp add codex -s user --transport stdio -- uvx --from git+https://github.com/codingSamss/codexmcp.git codexmcp"
  NEED_MANUAL=1
fi

echo "[cc-codex-review] 检查 Python3..."
if command -v python3 >/dev/null 2>&1; then
  echo "[cc-codex-review] Python3 已安装"
else
  echo "[cc-codex-review] 请手动安装 Python3 (3.8+)"
  NEED_MANUAL=1
fi

if [ "$NEED_MANUAL" -eq 1 ]; then
  exit 2
fi
