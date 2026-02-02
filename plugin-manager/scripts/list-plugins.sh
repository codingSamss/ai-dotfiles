#!/bin/bash
# 列出所有已安装的 Claude Code 插件
# 按市场来源分组显示，包含描述信息

PLUGINS_JSON="$HOME/.claude/plugins/installed_plugins.json"

# 颜色定义
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
DIM='\033[2m'
NC='\033[0m'

# 清理 Markdown 语法
clean_markdown() {
    local text="$1"
    echo "$text" | \
        sed -E 's/\[([^]]*)\]\([^)]*\)/\1/g' | \
        sed -E 's/\*\*([^*]*)\*\*/\1/g' | \
        sed -E 's/\*([^*]*)\*/\1/g' | \
        sed -E 's/`[^`]*`//g' | \
        sed -E 's/^> //' | \
        sed -E 's/^[|>] *//' | \
        sed -E 's/  +/ /g' | \
        sed -E 's/^ +//' | \
        tr -s ' '
}

# 获取插件描述
# 优先级: plugin.json > README.md 第一段
get_description() {
    local install_path="$1"
    local desc=""

    # 尝试从 .claude-plugin/plugin.json 获取
    local plugin_json="$install_path/.claude-plugin/plugin.json"
    if [ -f "$plugin_json" ]; then
        desc=$(jq -r '.description // empty' "$plugin_json" 2>/dev/null)
    fi

    # 如果没有，尝试从 README.md 获取第一段
    if [ -z "$desc" ]; then
        local readme="$install_path/README.md"
        if [ -f "$readme" ]; then
            # 跳过标题、空行、引用行，获取第一段有效内容
            desc=$(grep -v '^#' "$readme" | \
                   grep -v '^>' | \
                   grep -v '^$' | \
                   grep -v '^\[' | \
                   grep -v '^|' | \
                   head -2 | \
                   tr '\n' ' ')
        fi
    fi

    # 清理 Markdown 语法并截断
    if [ -n "$desc" ]; then
        desc=$(clean_markdown "$desc")
        echo "${desc:0:70}"
    else
        echo ""
    fi
}

echo -e "${CYAN}已安装的插件:${NC}"
echo "===================="
echo ""

# 获取所有市场来源并排序
marketplaces=$(jq -r '.plugins | keys[] | split("@")[1]' "$PLUGINS_JSON" | sort -u)

for marketplace in $marketplaces; do
    echo -e "${YELLOW}[$marketplace]${NC}"

    # 获取该市场的所有插件
    plugins=$(jq -r --arg mp "$marketplace" '
        .plugins | to_entries[] |
        select(.key | endswith("@" + $mp)) |
        "\(.key | split("@")[0])|\(.value[0].version)|\(.value[0].installedAt | split("T")[0])|\(.value[0].installPath)"
    ' "$PLUGINS_JSON" | sort)

    while IFS='|' read -r name version date install_path; do
        [ -z "$name" ] && continue

        # 获取描述
        desc=$(get_description "$install_path")

        echo -e "  ${GREEN}$name${NC} - v$version ($date)"
        if [ -n "$desc" ]; then
            echo -e "    ${DIM}$desc${NC}"
        fi
    done <<< "$plugins"

    echo ""
done

# 统计
total=$(jq '.plugins | length' "$PLUGINS_JSON")
echo "===================="
echo -e "共计: ${GREEN}$total${NC} 个插件"