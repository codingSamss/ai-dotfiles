#!/bin/bash
set -euo pipefail

NEED_MANUAL=0

echo "[peekaboo] 检查 Peekaboo..."
if command -v peekaboo >/dev/null 2>&1; then
  echo "[peekaboo] Peekaboo 已安装"
else
  if command -v brew >/dev/null 2>&1; then
    echo "[peekaboo] 安装 Peekaboo"
    brew install steipete/tap/peekaboo
  else
    echo "[peekaboo] 未检测到 Homebrew，请手动安装: brew install steipete/tap/peekaboo"
    NEED_MANUAL=1
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
