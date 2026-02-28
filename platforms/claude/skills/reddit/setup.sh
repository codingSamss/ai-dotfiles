#!/bin/bash
set -euo pipefail

NEED_MANUAL=0
PROXY_HTTP="${HTTP_PROXY:-http://127.0.0.1:7897}"
PROXY_HTTPS="${HTTPS_PROXY:-http://127.0.0.1:7897}"
COMPOSIO_API_KEY_ENV="${COMPOSIO_API_KEY_ENV:-COMPOSIO_API_KEY}"

# Ensure user-level binaries are discoverable in non-interactive shells.
export PATH="$HOME/.local/bin:$PATH"

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
    echo "[reddit] 尝试安装 composio（优先 --user）"
    if [ -n "${VIRTUAL_ENV:-}" ]; then
      if HTTP_PROXY="$PROXY_HTTP" HTTPS_PROXY="$PROXY_HTTPS" \
           python3 -m pip install composio >/dev/null 2>&1; then
        echo "[reddit] 在虚拟环境中安装 composio 完成"
      else
        echo "[reddit] composio 自动安装失败（可能是网络或索引源问题）"
        echo "[reddit] 建议手动执行以下任一方案："
        echo "  1) python3 -m pip install composio"
        echo "  2) python3 -m venv ~/.venvs/reddit-skill && ~/.venvs/reddit-skill/bin/pip install composio"
        NEED_MANUAL=1
      fi
    else
      if HTTP_PROXY="$PROXY_HTTP" HTTPS_PROXY="$PROXY_HTTPS" \
           python3 -m pip install --user --break-system-packages composio >/dev/null 2>&1; then
        echo "[reddit] composio 安装完成"
      else
        echo "[reddit] composio 自动安装失败（可能是系统 Python 受限）"
        echo "[reddit] 建议手动执行以下任一方案："
        echo "  1) python3 -m pip install --user --break-system-packages composio"
        echo "  2) python3 -m venv ~/.venvs/reddit-skill && ~/.venvs/reddit-skill/bin/pip install composio"
        NEED_MANUAL=1
      fi
    fi
  fi
fi

CLAUDE_JSON="$HOME/.claude.json"
if [ -f "$CLAUDE_JSON" ] && python3 - <<'PY' "$CLAUDE_JSON" "$COMPOSIO_API_KEY_ENV" >/dev/null 2>&1
import json
import sys

cfg_path = sys.argv[1]
api_key_env = sys.argv[2]
with open(cfg_path, "r", encoding="utf-8") as f:
    cfg = json.load(f)

server = cfg.get("mcpServers", {}).get("composio-reddit", {})
if not server:
    raise SystemExit(1)

token_env = server.get("bearer_token_env_var")
if token_env and token_env != api_key_env:
    raise SystemExit(2)

raise SystemExit(0)
PY
then
  echo "[reddit] composio-reddit MCP 已配置（~/.claude.json）"
elif [ -f "$CLAUDE_JSON" ] && python3 - <<'PY' "$CLAUDE_JSON" "$COMPOSIO_API_KEY_ENV" >/dev/null 2>&1
import json
import sys

cfg_path = sys.argv[1]
api_key_env = sys.argv[2]
with open(cfg_path, "r", encoding="utf-8") as f:
    cfg = json.load(f)
server = cfg.get("mcpServers", {}).get("composio-reddit", {})
raise SystemExit(0 if server and server.get("bearer_token_env_var") and server.get("bearer_token_env_var") != api_key_env else 1)
PY
then
  echo "[reddit] composio-reddit MCP 已存在，但 bearer token 环境变量与当前预期不一致"
  echo "[reddit] 预期环境变量: $COMPOSIO_API_KEY_ENV"
  NEED_MANUAL=1
else
  echo "[reddit] composio-reddit MCP 未配置，请按 README 指引完成 OAuth 授权"
  NEED_MANUAL=1
fi

echo "[reddit] 检查 Composio API Key 环境变量..."
if [ -n "${!COMPOSIO_API_KEY_ENV:-}" ]; then
  echo "[reddit] ${COMPOSIO_API_KEY_ENV} 已设置"
else
  echo "[reddit] 未检测到 ${COMPOSIO_API_KEY_ENV}，请先在 shell 中 export"
  NEED_MANUAL=1
fi

if [ "$NEED_MANUAL" -eq 1 ]; then
  exit 2
fi
