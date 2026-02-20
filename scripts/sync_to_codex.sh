#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PLATFORM_ROOT="$REPO_ROOT/platforms/codex"
SKILLS_SOURCE_ROOT="$PLATFORM_ROOT/skills"
CODEX_HOME_DIR="${CODEX_HOME:-$HOME/.codex}"
DRY_RUN="false"
SYNC_SKILLS="true"
SYNC_ROOT="true"
AUTO_YES="false"

MANAGED_ROOT_DIRS=(
  "agents"
  "hooks"
  "scripts"
  "rules"
  "bin"
)
MANAGED_ROOT_FILES=(
  "AGENTS.md"
  "config.toml"
)

usage() {
  cat <<'USAGE'
用法:
  ./scripts/sync_to_codex.sh
  ./scripts/sync_to_codex.sh --dry-run
  ./scripts/sync_to_codex.sh --yes
  ./scripts/sync_to_codex.sh --skills-only
  ./scripts/sync_to_codex.sh --root-only
  ./scripts/sync_to_codex.sh --codex-home /path/to/.codex

说明:
  默认同步到：
  - ~/.codex/skills
  - ~/.codex/{AGENTS.md,config.toml,agents,hooks,scripts,rules,bin}

  目录内每个 skill 必须包含 SKILL.md
  所有同步均为增量模式（保留目录外未托管内容）
  同步 root/config.toml 时会保留本地 composio-reddit 鉴权字段，避免覆盖本机 key 配置
  覆盖确认支持交互；非交互默认跳过覆盖。可用 --yes 自动覆盖
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
    --yes)
      AUTO_YES="true"
      ;;
    --skills-only)
      SYNC_ROOT="false"
      ;;
    --root-only)
      SYNC_SKILLS="false"
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

if ! command -v rsync >/dev/null 2>&1; then
  echo "[错误] 未找到 rsync，无法执行镜像同步"
  exit 1
fi

if [ "$SYNC_SKILLS" != "true" ] && [ "$SYNC_ROOT" != "true" ]; then
  echo "[错误] 无可执行同步目标（skills/root 均被关闭）"
  exit 1
fi

if [ "$SYNC_SKILLS" = "true" ]; then
  if [ ! -d "$SKILLS_SOURCE_ROOT" ]; then
    echo "[错误] Codex skills 目录不存在: $SKILLS_SOURCE_ROOT"
    exit 1
  fi

  # 严格校验：每个 skill 必须有 SKILL.md（Codex 官方要求）
  has_skill="false"
  for skill_dir in "$SKILLS_SOURCE_ROOT"/*; do
    [ -d "$skill_dir" ] || continue
    has_skill="true"
    if [ ! -f "$skill_dir/SKILL.md" ]; then
      echo "[错误] 缺少 SKILL.md: $skill_dir"
      exit 1
    fi
  done

  if [ "$has_skill" != "true" ]; then
    echo "[错误] 未发现任何可同步 skill: $SKILLS_SOURCE_ROOT"
    exit 1
  fi
fi

base_rsync_args=(
  "-a"
  "--exclude" ".gitkeep"
  "--exclude" "__pycache__/"
  "--exclude" "*.pyc"
  "--exclude" "*.pyo"
  "--exclude" ".DS_Store"
)
if [ "$DRY_RUN" = "true" ]; then
  base_rsync_args+=("--dry-run" "--itemize-changes")
fi

echo "=== Codex 平台同步 ==="
echo "源目录(Codex 平台): $PLATFORM_ROOT"
echo "目标目录(CODEX_HOME): $CODEX_HOME_DIR"

sync_dir_incremental() {
  local source_dir="$1"
  local target_dir="$2"
  local label="$3"
  local rsync_args=("${base_rsync_args[@]}")

  if [ ! -d "$source_dir" ]; then
    echo "[跳过] ${label}（源目录不存在）: $source_dir"
    return 0
  fi

  mkdir -p "$target_dir"
  echo "[同步] ${label}: $source_dir -> $target_dir"
  rsync "${rsync_args[@]}" "$source_dir"/ "$target_dir"/
}

extract_composio_reddit_auth_lines() {
  local config_file="$1"
  local output_file="$2"

  : > "$output_file"
  [ -f "$config_file" ] || return 0

  awk '
    /^\[mcp_servers\.composio-reddit\]$/ { in_section=1; next }
    /^\[/ { if (in_section) exit }
    in_section && $1 ~ /^(bearer_token_env_var|http_headers|env_http_headers)$/ { print }
  ' "$config_file" > "$output_file"
}

restore_composio_reddit_auth_lines() {
  local config_file="$1"
  local auth_file="$2"

  [ -f "$config_file" ] || return 0
  [ -s "$auth_file" ] || return 0

  local tmp_file
  tmp_file="$(mktemp)"

  awk -v auth_file="$auth_file" '
    BEGIN {
      while ((getline line < auth_file) > 0) {
        auth[++auth_count] = line
      }
      close(auth_file)
    }
    function print_auth_lines() {
      for (i = 1; i <= auth_count; i++) print auth[i]
    }
    /^\[mcp_servers\.composio-reddit\]$/ {
      in_section = 1
      auth_inserted = 0
      print
      next
    }
    in_section && /^\[/ {
      if (!auth_inserted) {
        print_auth_lines()
        auth_inserted = 1
      }
      in_section = 0
      print
      next
    }
    in_section {
      if ($1 ~ /^(bearer_token_env_var|http_headers|env_http_headers)$/) {
        next
      }
      print
      if (!auth_inserted && $1 == "url") {
        print_auth_lines()
        auth_inserted = 1
      }
      next
    }
    { print }
    END {
      if (in_section && !auth_inserted) {
        print_auth_lines()
      }
    }
  ' "$config_file" > "$tmp_file"

  mv "$tmp_file" "$config_file"
}

sync_file_incremental() {
  local source_file="$1"
  local target_file="$2"
  local label="$3"
  local rsync_args=("${base_rsync_args[@]}")
  local local_auth_tmp=""

  if [ ! -f "$source_file" ]; then
    echo "[跳过] ${label}（源文件不存在）: $source_file"
    return 0
  fi

  mkdir -p "$(dirname "$target_file")"

  # 目标文件已存在且内容有差异时，需用户确认才覆盖
  if [ -f "$target_file" ] && ! diff -q "$source_file" "$target_file" >/dev/null 2>&1; then
    echo "[注意] ${label} 与本地版本存在差异："
    diff --color=auto "$target_file" "$source_file" || true
    if [ "$DRY_RUN" = "true" ]; then
      echo "[跳过] ${label}（dry-run 模式）"
      return 0
    fi

    if [ "$AUTO_YES" = "true" ]; then
      answer="y"
      echo "[确认] --yes 已启用，自动覆盖: $target_file"
    elif [ ! -t 0 ]; then
      echo "[跳过] ${label}（非交互环境，保留本地版本；可用 --yes 自动覆盖）"
      return 0
    else
      printf "[确认] 是否用仓库版本覆盖 %s？[y/N] " "$target_file"
      read -r answer || answer=""
    fi

    if [ "${answer:-}" != "y" ] && [ "${answer:-}" != "Y" ]; then
      echo "[跳过] ${label}（保留本地版本）"
      return 0
    fi
  elif [ -f "$target_file" ]; then
    echo "[跳过] ${label}（无变化）"
    return 0
  fi

  if [ "$label" = "root/config.toml" ] && [ -f "$target_file" ] && [ "$DRY_RUN" != "true" ]; then
    local_auth_tmp="$(mktemp)"
    extract_composio_reddit_auth_lines "$target_file" "$local_auth_tmp"
  fi

  echo "[同步] ${label}: $source_file -> $target_file"
  rsync "${rsync_args[@]}" "$source_file" "$target_file"

  if [ -n "$local_auth_tmp" ]; then
    restore_composio_reddit_auth_lines "$target_file" "$local_auth_tmp"
    if [ -s "$local_auth_tmp" ]; then
      echo "[保留] ${label} composio-reddit 本地鉴权配置已保留"
    fi
    rm -f "$local_auth_tmp"
  fi
}

if [ "$SYNC_SKILLS" = "true" ]; then
  sync_dir_incremental "$SKILLS_SOURCE_ROOT" "$CODEX_HOME_DIR/skills" "skills"
  skill_count="$(find "$SKILLS_SOURCE_ROOT" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
  echo "技能数: $skill_count"
fi

if [ "$SYNC_ROOT" = "true" ]; then
  for rel_dir in "${MANAGED_ROOT_DIRS[@]}"; do
    sync_dir_incremental "$PLATFORM_ROOT/$rel_dir" "$CODEX_HOME_DIR/$rel_dir" "root/$rel_dir"
  done

  for rel_file in "${MANAGED_ROOT_FILES[@]}"; do
    sync_file_incremental "$PLATFORM_ROOT/$rel_file" "$CODEX_HOME_DIR/$rel_file" "root/$rel_file"
  done
fi

echo ""
if [ "$DRY_RUN" = "true" ]; then
  echo "预览完成（未写入目标目录）。"
else
  echo "同步完成（skills 与受管 root 配置已增量同步）。"
fi
