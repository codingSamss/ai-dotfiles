#!/bin/bash
set -euo pipefail

NEED_MANUAL=0
PROXY_HTTP="${HTTP_PROXY:-http://127.0.0.1:7897}"
PROXY_HTTPS="${HTTPS_PROXY:-http://127.0.0.1:7897}"
BIRD_NPM_PACKAGE="${BIRD_NPM_PACKAGE:-@jcheesepkg/bird}"

# Ensure user-level binaries are discoverable in non-interactive shells.
export PATH="$HOME/.local/bin:$PATH"

echo "[bird-twitter] 检查 Bird CLI..."
if command -v bird >/dev/null 2>&1; then
  echo "[bird-twitter] Bird CLI 已安装"
else
  if command -v brew >/dev/null 2>&1; then
    echo "[bird-twitter] 尝试通过 Homebrew 安装 Bird CLI"
    if brew install steipete/tap/bird; then
      echo "[bird-twitter] Homebrew 安装成功"
    else
      echo "[bird-twitter] Homebrew 安装失败（上游公式可能已下线）"
    fi
  fi

  if ! command -v bird >/dev/null 2>&1; then
    if command -v npm >/dev/null 2>&1; then
      echo "[bird-twitter] 尝试通过 npm 安装 Bird CLI（社区镜像）: $BIRD_NPM_PACKAGE"
      if HTTP_PROXY="$PROXY_HTTP" HTTPS_PROXY="$PROXY_HTTPS" \
           npm install -g --prefix "$HOME/.local" "$BIRD_NPM_PACKAGE"; then
        echo "[bird-twitter] npm 安装完成"
      else
        echo "[bird-twitter] npm 安装失败"
      fi
    fi
  fi

  if ! command -v bird >/dev/null 2>&1; then
    echo "[bird-twitter] 未能自动安装 Bird CLI。"
    echo "[bird-twitter] 建议手动确认可用来源（Homebrew 公式已下线时可通过 npm 社区镜像安装）。"
    echo "[bird-twitter] 例如：npm install -g --prefix \"\$HOME/.local\" @jcheesepkg/bird"
    NEED_MANUAL=1
  else
    echo "[bird-twitter] Bird CLI 已可用: $(command -v bird)"
  fi
fi

if command -v bird >/dev/null 2>&1; then
  if HTTP_PROXY="$PROXY_HTTP" HTTPS_PROXY="$PROXY_HTTPS" \
       bird --cookie-source chrome --timeout 15000 whoami >/dev/null 2>&1; then
    echo "[bird-twitter] Bird 认证已就绪"
  else
    echo "[bird-twitter] Bird 认证检查失败，请先确认："
    echo "  1) Chrome 已登录 X/Twitter"
    echo "  2) 代理可用（HTTP_PROXY/HTTPS_PROXY），默认尝试: http://127.0.0.1:7897"
    echo "  3) 可手动验证:"
    echo "     HTTP_PROXY=$PROXY_HTTP HTTPS_PROXY=$PROXY_HTTPS bird --cookie-source chrome --timeout 15000 whoami"
    NEED_MANUAL=1
  fi
fi

if [ "$NEED_MANUAL" -eq 1 ]; then
  exit 2
fi
