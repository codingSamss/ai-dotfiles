#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "[core] 配置公共组件..."

# hooks
echo "[core] 链接 hooks/notify.sh -> ~/.claude/hooks/notify.sh"
mkdir -p "$HOME/.claude/hooks"
ln -sf "$PLUGIN_DIR/hooks/notify.sh" "$HOME/.claude/hooks/notify.sh"

# agents
echo "[core] 链接 agents -> ~/.claude/agents/"
mkdir -p "$HOME/.claude/agents"
for agent in "$PLUGIN_DIR"/agents/*.md; do
  [ -f "$agent" ] || continue
  name="$(basename "$agent")"
  ln -sf "$agent" "$HOME/.claude/agents/$name"
  echo "  - $name"
done

echo "[core] 完成"
