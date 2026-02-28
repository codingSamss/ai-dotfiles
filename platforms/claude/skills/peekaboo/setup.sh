#!/bin/bash
set -euo pipefail

NEED_MANUAL=0
PROXY_HTTP="${HTTP_PROXY:-http://127.0.0.1:7897}"
PROXY_HTTPS="${HTTPS_PROXY:-http://127.0.0.1:7897}"
PEEKABOO_URL="${PEEKABOO_URL:-https://github.com/steipete/Peekaboo/releases/download/v3.0.0-beta3/peekaboo-macos-universal.tar.gz}"
PEEKABOO_SHA256="${PEEKABOO_SHA256:-77eadf6fd5c54eac64b4844d5cc887890b6d6f45d49af61b05c6e29ea2cbd245}"

# Ensure user-level binaries are discoverable in non-interactive shells.
export PATH="$HOME/.local/bin:$PATH"

install_peekaboo_from_release() {
  local tmp_dir
  tmp_dir="$(mktemp -d /tmp/peekaboo-install.XXXXXX)"
  if HTTP_PROXY="$PROXY_HTTP" HTTPS_PROXY="$PROXY_HTTPS" \
       curl -fsSL "$PEEKABOO_URL" -o "$tmp_dir/peekaboo.tar.gz" &&
     echo "$PEEKABOO_SHA256  $tmp_dir/peekaboo.tar.gz" | shasum -a 256 -c - >/dev/null &&
     tar -xzf "$tmp_dir/peekaboo.tar.gz" -C "$tmp_dir" &&
     install -m 755 "$tmp_dir/peekaboo-macos-universal/peekaboo" "$HOME/.local/bin/peekaboo"; then
    rm -rf "$tmp_dir"
    return 0
  fi
  rm -rf "$tmp_dir"
  return 1
}

echo "[peekaboo] 检查 Peekaboo..."
if command -v peekaboo >/dev/null 2>&1; then
  echo "[peekaboo] Peekaboo 已安装"
else
  if command -v brew >/dev/null 2>&1; then
    echo "[peekaboo] 尝试通过 Homebrew 安装 Peekaboo"
    if brew install steipete/tap/peekaboo; then
      echo "[peekaboo] Homebrew 安装成功"
    else
      echo "[peekaboo] Homebrew 安装失败，尝试直连 release 安装"
    fi
  fi

  if ! command -v peekaboo >/dev/null 2>&1; then
    if install_peekaboo_from_release; then
      echo "[peekaboo] release 安装成功: $(command -v peekaboo)"
    else
      echo "[peekaboo] 自动安装失败，请手动安装 Peekaboo"
      echo "[peekaboo] 可尝试: brew install steipete/tap/peekaboo"
      NEED_MANUAL=1
    fi
  fi
fi

if command -v peekaboo >/dev/null 2>&1; then
  if peekaboo list permissions --json >/tmp/peekaboo_permissions.json 2>/dev/null && \
     python3 - <<'PY' /tmp/peekaboo_permissions.json >/dev/null 2>&1
import json
import sys

with open(sys.argv[1], "r", encoding="utf-8") as f:
    data = json.load(f)

perms = data.get("permissions", [])
required = [p for p in perms if p.get("isRequired")]
ok = all(p.get("isGranted") for p in required) if required else False
raise SystemExit(0 if ok else 1)
PY
  then
    echo "[peekaboo] 屏幕访问权限已就绪"
  else
    echo "[peekaboo] 需要手动授予屏幕录制权限（系统设置 -> 隐私与安全性）"
    NEED_MANUAL=1
  fi
fi

if [ "$NEED_MANUAL" -eq 1 ]; then
  exit 2
fi
