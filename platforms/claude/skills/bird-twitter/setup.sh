#!/bin/bash
set -euo pipefail

NEED_MANUAL=0

echo "[bird-twitter] 检查 Bird CLI..."
if command -v bird >/dev/null 2>&1; then
  echo "[bird-twitter] Bird CLI 已安装"
else
  if command -v brew >/dev/null 2>&1; then
    echo "[bird-twitter] 安装 Bird CLI"
    brew install steipete/tap/bird
  else
    echo "[bird-twitter] 未检测到 Homebrew，请手动安装: brew install steipete/tap/bird"
    NEED_MANUAL=1
  fi
fi

if command -v bird >/dev/null 2>&1; then
  if bird --cookie-source chrome whoami >/dev/null 2>&1; then
    echo "[bird-twitter] Bird 认证已就绪"
  else
    echo "[bird-twitter] 需要手动登录 X/Twitter 后执行: bird --cookie-source chrome whoami"
    NEED_MANUAL=1
  fi
fi

if [ "$NEED_MANUAL" -eq 1 ]; then
  exit 2
fi
