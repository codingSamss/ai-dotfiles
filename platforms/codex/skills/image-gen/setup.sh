#!/bin/bash
set -euo pipefail

NEED_MANUAL=0
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CODEX_HOME_DIR="${CODEX_HOME:-$HOME/.codex}"
TARGET_DIR="$CODEX_HOME_DIR/skills/image-gen"

echo "[image-gen] 检查 Python3..."
if ! command -v python3 >/dev/null 2>&1; then
  if command -v brew >/dev/null 2>&1; then
    echo "[image-gen] 安装 Python3"
    brew install python3
  else
    echo "[image-gen] 未检测到 Python3，且无 Homebrew，请手动安装 Python3"
    NEED_MANUAL=1
  fi
fi

# 同步 scripts/ 到 ~/.codex/skills/image-gen/scripts/
echo "[image-gen] 同步 scripts -> $TARGET_DIR/scripts/"
mkdir -p "$TARGET_DIR/scripts"
if [ -f "$SCRIPT_DIR/scripts/image-gen.py" ]; then
  SRC_SCRIPT="$SCRIPT_DIR/scripts/image-gen.py"
  DST_SCRIPT="$TARGET_DIR/scripts/image-gen.py"
  if [ "$SRC_SCRIPT" = "$DST_SCRIPT" ]; then
    echo "[image-gen] image-gen.py 已就绪（当前即目标路径）"
  else
    install -m 755 "$SRC_SCRIPT" "$DST_SCRIPT"
    echo "[image-gen] image-gen.py 已同步"
  fi
else
  echo "[image-gen] 缺少脚本: $SCRIPT_DIR/scripts/image-gen.py"
  exit 1
fi

# 同步 providers.json 模板（仅在目标不存在时复制，不覆盖已有配置）
if [ ! -f "$TARGET_DIR/providers.json" ]; then
  if [ -f "$SCRIPT_DIR/scripts/providers.json" ]; then
    install -m 644 "$SCRIPT_DIR/scripts/providers.json" "$TARGET_DIR/providers.json"
    echo "[image-gen] providers.json 模板已复制（请编辑填入 api_key）"
    NEED_MANUAL=1
  else
    echo "[image-gen] 缺少模板: $SCRIPT_DIR/scripts/providers.json"
    exit 1
  fi
else
  echo "[image-gen] providers.json 已存在，跳过覆盖"
fi

# 检查 active provider 的 api_key 是否已填写
if command -v python3 >/dev/null 2>&1 && [ -f "$TARGET_DIR/providers.json" ]; then
  API_KEY=$(python3 -c "
import json, sys
try:
    cfg = json.load(open('$TARGET_DIR/providers.json'))
    active = cfg.get('active', '')
    key = cfg.get('providers', {}).get(active, {}).get('api_key', '')
    print(key)
except Exception:
    print('')
" 2>/dev/null) || API_KEY=""
  if [ -z "$API_KEY" ]; then
    echo "[image-gen] 当前 active provider 的 api_key 为空"
    echo "[image-gen] 请编辑 $TARGET_DIR/providers.json 填入 api_key"
    NEED_MANUAL=1
  else
    echo "[image-gen] active provider api_key 已配置"
  fi
fi

if [ "$NEED_MANUAL" -eq 1 ]; then
  exit 2
fi
