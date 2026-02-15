#!/bin/bash
set -euo pipefail

NEED_MANUAL=0
PROXY_HTTP="${HTTP_PROXY:-http://127.0.0.1:7897}"
PROXY_HTTPS="${HTTPS_PROXY:-http://127.0.0.1:7897}"

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

echo "[reddit] 检查 Codex MCP 配置..."
if command -v codex >/dev/null 2>&1 && codex mcp list 2>/dev/null | grep -qE '^composio-reddit[[:space:]]'; then
  echo "[reddit] composio-reddit MCP 已配置"
else
  echo "[reddit] composio-reddit MCP 未配置，请按 README 指引完成 OAuth 授权（codex mcp add ...）"
  NEED_MANUAL=1
fi

if [ "$NEED_MANUAL" -eq 1 ]; then
  exit 2
fi
