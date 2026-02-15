#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SOURCE_ROOT="$REPO_ROOT/platforms/codex"
CODEX_HOME_DIR="${CODEX_HOME:-$HOME/.codex}"
DRY_RUN="false"
COMPONENTS=("skills" "agents" "hooks" "scripts")

usage() {
  cat <<'USAGE'
用法:
  ./scripts/sync_to_codex.sh
  ./scripts/sync_to_codex.sh --dry-run
  ./scripts/sync_to_codex.sh --codex-home /path/to/.codex

说明:
  同步源目录固定为仓库内 platforms/codex
  以镜像方式同步 skills/agents/hooks/scripts 到目标 CODEX_HOME
  会清理目标目录中的陈旧文件（等价 rsync --delete）
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
  echo "[错误] Codex 平台目录不存在: $SOURCE_ROOT"
  exit 1
fi

if ! command -v rsync >/dev/null 2>&1; then
  echo "[错误] 未找到 rsync，无法执行镜像同步"
  exit 1
fi

for component in "${COMPONENTS[@]}"; do
  if [ ! -d "$SOURCE_ROOT/$component" ]; then
    echo "[错误] 缺少源目录: $SOURCE_ROOT/$component"
    exit 1
  fi
done

echo "=== Codex 平台同步 ==="
echo "源目录: $SOURCE_ROOT"
echo "目标目录: $CODEX_HOME_DIR"

sync_component() {
  local component="$1"
  local src_dir="$SOURCE_ROOT/$component"
  local dst_dir="$CODEX_HOME_DIR/$component"

  echo "[同步][$component] $src_dir -> $dst_dir"
  mkdir -p "$dst_dir"

  local rsync_args=("-a" "--delete" "--exclude" ".gitkeep")
  if [ "$DRY_RUN" = "true" ]; then
    rsync_args+=("--dry-run" "--itemize-changes")
  fi

  rsync "${rsync_args[@]}" "$src_dir"/ "$dst_dir"/

  local item_count
  item_count="$(find "$src_dir" -mindepth 1 -maxdepth 1 ! -name '.gitkeep' | wc -l | tr -d ' ')"
  echo "  - 源项目数: $item_count"
}

for component in "${COMPONENTS[@]}"; do
  sync_component "$component"
done

echo ""
if [ "$DRY_RUN" = "true" ]; then
  echo "预览完成（未写入目标目录）。"
else
  echo "同步完成（目标目录已与 platforms/codex 镜像一致）。"
fi
