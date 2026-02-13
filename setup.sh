#!/bin/bash
set -euo pipefail

# Personal Skills - 外部依赖安装脚本
# 用于安装插件系统无法自动处理的外部依赖

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_DIR="$SCRIPT_DIR/personal-skills"

echo "=== Personal Skills Setup ==="
echo ""

# --- 1. Homebrew 工具 ---
if command -v brew &>/dev/null; then
    echo "[1/5] 安装 Homebrew 依赖..."

    # bird-twitter skill 依赖
    if ! command -v bird &>/dev/null; then
        echo "  - 安装 Bird CLI..."
        brew install steipete/tap/bird
    else
        echo "  - Bird CLI 已安装, 跳过"
    fi

    # peekaboo skill 依赖
    if ! command -v peekaboo &>/dev/null; then
        echo "  - 安装 Peekaboo..."
        brew install steipete/tap/peekaboo
    else
        echo "  - Peekaboo 已安装, 跳过"
    fi

    # ui-ux-pro-max skill 依赖
    if ! command -v python3 &>/dev/null; then
        echo "  - 安装 Python 3..."
        brew install python3
    else
        echo "  - Python 3 已安装, 跳过"
    fi

    # hooks/notify.sh 依赖
    if ! command -v jq &>/dev/null; then
        echo "  - 安装 jq..."
        brew install jq
    else
        echo "  - jq 已安装, 跳过"
    fi
else
    echo "[1/5] Homebrew 未安装, 跳过工具安装"
    echo "  请手动安装: bird, peekaboo, python3, jq"
fi

echo ""

# --- 2. Python 依赖 (pip) ---
echo "[2/5] 安装 Python 依赖..."

# reddit skill 依赖 Composio SDK
if python3 -c "import composio" &>/dev/null; then
    echo "  - composio 已安装, 跳过"
else
    echo "  - 安装 composio..."
    pip3 install composio
fi
echo "  done"

echo ""

# --- 3. Reddit MCP 配置 ---
echo "[3/5] 配置 Reddit MCP (Composio)..."
CLAUDE_JSON="$HOME/.claude.json"
if [ -f "$CLAUDE_JSON" ] && python3 -c "
import json, sys
with open('$CLAUDE_JSON') as f:
    cfg = json.load(f)
sys.exit(0 if 'composio-reddit' in cfg.get('mcpServers', {}) else 1)
" 2>/dev/null; then
    echo "  - composio-reddit MCP 已配置, 跳过"
else
    echo "  - composio-reddit MCP 未配置"
    echo "  需要手动配置 (需要 Composio API Key 和 Reddit OAuth):"
    echo "    1. 注册 Composio 账号: https://app.composio.dev"
    echo "    2. 获取 API Key"
    echo "    3. 运行: composio add reddit"
    echo "    4. 使用 Composio SDK 创建 tool router session 并添加到 ~/.claude.json"
    echo "  详见 skills/reddit/skill.md"
fi

echo ""

# --- 4. 符号链接: hooks/notify.sh ---
echo "[4/5] 链接 hooks/notify.sh -> ~/.claude/hooks/notify.sh"
mkdir -p ~/.claude/hooks
ln -sf "$PLUGIN_DIR/hooks/notify.sh" ~/.claude/hooks/notify.sh
echo "  done"

echo ""

# --- 5. 符号链接: agents ---
echo "[5/5] 链接 agents -> ~/.claude/agents/"
mkdir -p ~/.claude/agents
for agent in "$PLUGIN_DIR"/agents/*.md; do
    name="$(basename "$agent")"
    ln -sf "$agent" ~/.claude/agents/"$name"
    echo "  - $name"
done
echo "  done"

echo ""
echo "=== Setup 完成 ==="
echo "请重启 Claude Code 以加载新配置"
