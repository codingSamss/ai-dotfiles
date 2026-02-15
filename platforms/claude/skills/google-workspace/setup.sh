#!/bin/bash
set -euo pipefail

NEED_MANUAL=0

echo "[google-workspace] 检查 gogcli..."
if command -v gog >/dev/null 2>&1; then
  echo "[google-workspace] gogcli 已安装"
else
  if command -v brew >/dev/null 2>&1; then
    echo "[google-workspace] 安装 gogcli"
    brew install steipete/tap/gogcli
  else
    echo "[google-workspace] 未检测到 Homebrew，请手动安装: brew install steipete/tap/gogcli"
    NEED_MANUAL=1
  fi
fi

if command -v gog >/dev/null 2>&1; then
  if gog auth status >/dev/null 2>&1; then
    echo "[google-workspace] OAuth 认证已就绪"
  else
    echo "[google-workspace] 需要手动完成 OAuth，建议执行: gog auth status"
    NEED_MANUAL=1
  fi
fi

if [ "$NEED_MANUAL" -eq 1 ]; then
  exit 2
fi
