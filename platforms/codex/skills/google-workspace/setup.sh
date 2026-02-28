#!/bin/bash
set -euo pipefail

NEED_MANUAL=0
PROXY_HTTP="${HTTP_PROXY:-http://127.0.0.1:7897}"
PROXY_HTTPS="${HTTPS_PROXY:-http://127.0.0.1:7897}"
GOG_URL="${GOG_URL:-https://github.com/steipete/gogcli/releases/download/v0.11.0/gogcli_0.11.0_darwin_arm64.tar.gz}"
GOG_SHA256="${GOG_SHA256:-1126868c3f939a14aa96577d5658f5fef1e1539f332730bf35a06e74162c9e61}"

# Ensure user-level binaries are discoverable in non-interactive shells.
export PATH="$HOME/.local/bin:$PATH"

install_gog_from_release() {
  local tmp_dir
  tmp_dir="$(mktemp -d /tmp/gog-install.XXXXXX)"
  if HTTP_PROXY="$PROXY_HTTP" HTTPS_PROXY="$PROXY_HTTPS" \
       curl -fsSL "$GOG_URL" -o "$tmp_dir/gog.tar.gz" &&
     echo "$GOG_SHA256  $tmp_dir/gog.tar.gz" | shasum -a 256 -c - >/dev/null &&
     tar -xzf "$tmp_dir/gog.tar.gz" -C "$tmp_dir" &&
     install -m 755 "$tmp_dir/gog" "$HOME/.local/bin/gog"; then
    rm -rf "$tmp_dir"
    return 0
  fi
  rm -rf "$tmp_dir"
  return 1
}

echo "[google-workspace] 检查 gogcli..."
if command -v gog >/dev/null 2>&1; then
  echo "[google-workspace] gogcli 已安装"
else
  if command -v brew >/dev/null 2>&1; then
    echo "[google-workspace] 尝试通过 Homebrew 安装 gogcli"
    if brew install steipete/tap/gogcli; then
      echo "[google-workspace] Homebrew 安装成功"
    else
      echo "[google-workspace] Homebrew 安装失败，尝试直连 release 安装"
    fi
  fi

  if ! command -v gog >/dev/null 2>&1; then
    if install_gog_from_release; then
      echo "[google-workspace] release 安装成功: $(command -v gog)"
    else
      echo "[google-workspace] 自动安装失败，请手动安装 gogcli"
      echo "[google-workspace] 可尝试: brew install steipete/tap/gogcli"
      NEED_MANUAL=1
    fi
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
