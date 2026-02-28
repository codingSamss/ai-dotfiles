#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "[core] 配置公共组件..."

# hooks（使用复制，避免软链接失效）
echo "[core] 复制 hooks/notify.sh -> ~/.claude/hooks/notify.sh"
mkdir -p "$HOME/.claude/hooks"
install -m 755 "$PLUGIN_DIR/hooks/notify.sh" "$HOME/.claude/hooks/notify.sh"

# scripts（使用复制，避免软链接失效）
echo "[core] 同步 scripts -> ~/.claude/scripts/"
mkdir -p "$HOME/.claude/scripts"
for script in "$PLUGIN_DIR"/scripts/*; do
  [ -f "$script" ] || continue
  name="$(basename "$script")"
  install -m 755 "$script" "$HOME/.claude/scripts/$name"
  echo "  - $name"
done

# agents（使用复制，避免软链接失效）
echo "[core] 复制 agents -> ~/.claude/agents/"
mkdir -p "$HOME/.claude/agents"
for agent in "$PLUGIN_DIR"/agents/*.md; do
  [ -f "$agent" ] || continue
  name="$(basename "$agent")"
  install -m 644 "$agent" "$HOME/.claude/agents/$name"
  echo "  - $name"
done

# CLAUDE.md（全局指令同步到 ~/.claude/CLAUDE.md，覆盖前需用户确认）
if [ -f "$PLUGIN_DIR/CLAUDE.md" ]; then
  TARGET_CLAUDE_MD="$HOME/.claude/CLAUDE.md"
  if [ -f "$TARGET_CLAUDE_MD" ] && ! diff -q "$PLUGIN_DIR/CLAUDE.md" "$TARGET_CLAUDE_MD" >/dev/null 2>&1; then
    echo "[core] 检测到 ~/.claude/CLAUDE.md 与仓库版本存在差异："
    diff --color=auto "$TARGET_CLAUDE_MD" "$PLUGIN_DIR/CLAUDE.md" || true
    if [ ! -t 0 ]; then
      echo "[core] 非交互环境，默认跳过覆盖 ~/.claude/CLAUDE.md（保留本地版本）"
      answer="n"
    else
      printf "[core] 是否用仓库版本覆盖 ~/.claude/CLAUDE.md？[y/N] "
      read -r answer || answer=""
    fi
    if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
      install -m 644 "$PLUGIN_DIR/CLAUDE.md" "$TARGET_CLAUDE_MD"
      echo "[core] CLAUDE.md 已覆盖"
    else
      echo "[core] 跳过 CLAUDE.md（保留本地版本）"
    fi
  elif [ ! -f "$TARGET_CLAUDE_MD" ]; then
    echo "[core] 复制 CLAUDE.md -> ~/.claude/CLAUDE.md（首次安装）"
    install -m 644 "$PLUGIN_DIR/CLAUDE.md" "$TARGET_CLAUDE_MD"
  else
    echo "[core] CLAUDE.md 无变化，跳过"
  fi
fi

# .mcp.json（掩码模板，仅检查本地是否缺少 server，不覆盖已有配置）
MCP_TEMPLATE="$PLUGIN_DIR/.mcp.json"
LOCAL_MCP="$HOME/.claude.json"
if [ -f "$MCP_TEMPLATE" ] && [ -f "$LOCAL_MCP" ]; then
  echo "[core] 检查 MCP server 配置..."
  CHECK_OK=1
  MISSING=""
  MCP_ERR_FILE="$(mktemp /tmp/claude-core-mcp-check.XXXXXX.err)"
  if MISSING=$(python3 -c "
import json,sys
tpl_path=sys.argv[1]
local_path=sys.argv[2]
with open(tpl_path, encoding='utf-8') as f:
    tpl_root=json.load(f)
with open(local_path, encoding='utf-8') as f:
    local_root=json.load(f)
tpl=tpl_root.get('mcpServers', {})
local=local_root.get('mcpServers', {})
if not isinstance(tpl, dict) or not isinstance(local, dict):
    raise ValueError('mcpServers 字段必须是对象')
missing=[k for k in tpl if k not in local]
print('\n'.join(missing))
" "$MCP_TEMPLATE" "$LOCAL_MCP" 2>"$MCP_ERR_FILE"); then
    :
  else
    CHECK_OK=0
    echo "[core] MCP server 配置检查失败，请确认以下文件是合法 JSON："
    echo "  - $MCP_TEMPLATE"
    echo "  - $LOCAL_MCP"
    if [ -s "$MCP_ERR_FILE" ]; then
      sed 's/^/[core] /' "$MCP_ERR_FILE"
    fi
    MISSING=""
  fi
  rm -f "$MCP_ERR_FILE"
  if [ "$CHECK_OK" -eq 1 ]; then
    if [ -n "$MISSING" ]; then
      echo "[core] 本地缺少以下 MCP server（请用 claude mcp add 手动添加，项目模板含掩码需替换真实密钥）："
      echo "$MISSING" | while read -r name; do echo "  - $name"; done
    else
      echo "[core] MCP server 配置完整，无缺失"
    fi
  else
    echo "[core] 跳过缺失项判断，请修复 JSON 后重试"
  fi
elif [ -f "$MCP_TEMPLATE" ] && [ ! -f "$LOCAL_MCP" ]; then
  echo "[core] 未找到 ~/.claude.json，请先启动一次 Claude Code 再运行同步"
fi

# skills（同步 SKILL.md 到 ~/.claude/skills/）
echo "[core] 同步 skills -> ~/.claude/skills/"
for skill_dir in "$PLUGIN_DIR"/skills/*/; do
  [ -d "$skill_dir" ] || continue
  skill_name="$(basename "$skill_dir")"
  target_dir="$HOME/.claude/skills/$skill_name"
  # 清理后重建，确保已删除的文件不会残留
  rm -rf "$target_dir"
  mkdir -p "$target_dir"
  # 同步 SKILL.md
  if [ -f "$skill_dir/SKILL.md" ]; then
    install -m 644 "$skill_dir/SKILL.md" "$target_dir/SKILL.md"
  fi
  # 同步子目录（如 workflows/）
  for sub in "$skill_dir"*/; do
    [ -d "$sub" ] || continue
    cp -r "${sub%/}" "$target_dir/"
  done
  echo "  - $skill_name"
done

echo "[core] 完成"
