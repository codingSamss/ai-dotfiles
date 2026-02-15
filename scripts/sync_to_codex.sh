#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SOURCE_ROOT="$REPO_ROOT/platforms/codex/skills"
CODEX_HOME_DIR="${CODEX_HOME:-$HOME/.codex}"
DRY_RUN="false"

usage() {
  cat <<'USAGE'
用法:
  ./scripts/sync_to_codex.sh
  ./scripts/sync_to_codex.sh --dry-run
  ./scripts/sync_to_codex.sh --codex-home /path/to/.codex

说明:
  默认同步到：
  - ~/.codex/skills

  目录内每个 skill 必须包含 SKILL.md
  ~/.codex/skills 使用增量同步（保留 .system 与其他本地技能）
USAGE
}

while [ $# -gt 0 ]; do
  case "$1" in
    --codex-home)
      shift
      [ $# -gt 0 ] || { echo "[错误] --codex-home 缺少参数"; exit 1; }
      CODEX_HOME_DIR="$1"
      ;;
    --dry-run)
      DRY_RUN="true"
      ;;
    -h|--help|help)
      usage
      exit 0
      ;;
    *)
      echo "[错误] 未知参数: $1"
      usage
      exit 1
      ;;
  esac
  shift
done

if [ ! -d "$SOURCE_ROOT" ]; then
  echo "[错误] Codex skills 目录不存在: $SOURCE_ROOT"
  exit 1
fi

if ! command -v rsync >/dev/null 2>&1; then
  echo "[错误] 未找到 rsync，无法执行镜像同步"
  exit 1
fi

# 严格校验：每个 skill 必须有 SKILL.md（Codex 官方要求）
has_skill="false"
for skill_dir in "$SOURCE_ROOT"/*; do
  [ -d "$skill_dir" ] || continue
  has_skill="true"
  if [ ! -f "$skill_dir/SKILL.md" ]; then
    echo "[错误] 缺少 SKILL.md: $skill_dir"
    exit 1
  fi
done

if [ "$has_skill" != "true" ]; then
  echo "[错误] 未发现任何可同步 skill: $SOURCE_ROOT"
  exit 1
fi

base_rsync_args=("-a" "--exclude" ".gitkeep")
if [ "$DRY_RUN" = "true" ]; then
  base_rsync_args+=("--dry-run" "--itemize-changes")
fi

echo "=== Codex 平台同步 ==="
echo "源目录(官方 skills): $SOURCE_ROOT"

sync_one() {
  local target_root="$1"
  local rsync_args=("${base_rsync_args[@]}")
  echo "目标目录(CODEX_HOME): $target_root"
  mkdir -p "$target_root"
  rsync "${rsync_args[@]}" "$SOURCE_ROOT"/ "$target_root"/
}

sync_one "$CODEX_HOME_DIR/skills"

skill_count="$(find "$SOURCE_ROOT" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
echo "技能数: $skill_count"

echo ""
if [ "$DRY_RUN" = "true" ]; then
  echo "预览完成（未写入目标目录）。"
else
  echo "同步完成（目标目录已与官方 skills 源镜像一致）。"
fi
