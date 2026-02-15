#!/bin/bash
set -euo pipefail

NEED_MANUAL=0

echo "[plugin-manager] 检查 Claude CLI..."
if command -v claude >/dev/null 2>&1; then
  echo "[plugin-manager] Claude CLI 已可用"
else
  echo "[plugin-manager] 未检测到 claude 命令，请先安装/配置 Claude Code CLI"
  NEED_MANUAL=1
fi

if [ "$NEED_MANUAL" -eq 1 ]; then
  exit 2
fi
