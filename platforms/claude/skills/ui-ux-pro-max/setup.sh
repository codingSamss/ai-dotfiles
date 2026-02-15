#!/bin/bash
set -euo pipefail

NEED_MANUAL=0

echo "[ui-ux-pro-max] 检查 Python3..."
if command -v python3 >/dev/null 2>&1; then
  echo "[ui-ux-pro-max] Python3 已安装"
else
  if command -v brew >/dev/null 2>&1; then
    echo "[ui-ux-pro-max] 安装 Python3"
    brew install python3
  else
    echo "[ui-ux-pro-max] 未检测到 Homebrew，请手动安装 Python3"
    NEED_MANUAL=1
  fi
fi

if [ "$NEED_MANUAL" -eq 1 ]; then
  exit 2
fi
