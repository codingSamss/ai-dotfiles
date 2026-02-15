#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_FILE="$SCRIPT_DIR/SKILL.md"
REF_DIR="$SCRIPT_DIR/references"

echo "[security-best-practices] 检查核心文件..."
if [ ! -f "$SKILL_FILE" ]; then
  echo "[security-best-practices] 缺少 SKILL.md: $SKILL_FILE"
  exit 1
fi

if [ ! -d "$REF_DIR" ]; then
  echo "[security-best-practices] 缺少 references 目录: $REF_DIR"
  exit 1
fi

ref_count="$(find "$REF_DIR" -type f -name '*.md' | wc -l | tr -d ' ')"
if [ "$ref_count" -eq 0 ]; then
  echo "[security-best-practices] references 目录下无安全基线文档"
  exit 1
fi

echo "[security-best-practices] 已检测到 $ref_count 份安全基线文档"
