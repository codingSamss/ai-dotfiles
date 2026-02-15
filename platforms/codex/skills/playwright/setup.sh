#!/bin/bash
set -euo pipefail

NEED_MANUAL=0
PROXY_HTTP="${HTTP_PROXY:-http://127.0.0.1:7897}"
PROXY_HTTPS="${HTTPS_PROXY:-http://127.0.0.1:7897}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PWCLI="$SCRIPT_DIR/scripts/playwright_cli.sh"

echo "[playwright] 检查 npx..."
if command -v npx >/dev/null 2>&1; then
  echo "[playwright] npx 已安装"
else
  if command -v brew >/dev/null 2>&1; then
    echo "[playwright] 安装 Node.js（提供 npx）"
    brew install node
  else
    echo "[playwright] 未检测到 Homebrew，请手动安装 Node.js/npm"
    NEED_MANUAL=1
  fi
fi

if [ ! -x "$PWCLI" ]; then
  chmod +x "$PWCLI" 2>/dev/null || true
fi

if command -v npx >/dev/null 2>&1; then
  echo "[playwright] 检查 playwright-cli 可用性..."
  if HTTP_PROXY="$PROXY_HTTP" HTTPS_PROXY="$PROXY_HTTPS" "$PWCLI" --help >/dev/null 2>&1; then
    echo "[playwright] playwright-cli 已就绪"
  else
    echo "[playwright] playwright-cli 检查失败，请手动确认网络与依赖："
    echo "  1) HTTP_PROXY/HTTPS_PROXY 可用（默认: http://127.0.0.1:7897）"
    echo "  2) 手动验证: HTTP_PROXY=$PROXY_HTTP HTTPS_PROXY=$PROXY_HTTPS $PWCLI --help"
    echo "  3) 或全局安装: npm install -g @playwright/cli@latest"
    NEED_MANUAL=1
  fi
fi

if [ "$NEED_MANUAL" -eq 1 ]; then
  exit 2
fi
