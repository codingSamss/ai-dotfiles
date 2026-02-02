#!/bin/bash
# 列出所有本地 skills

SKILLS_DIR="$HOME/.claude/skills"

# 颜色定义
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
DIM='\033[2m'
NC='\033[0m'

echo -e "${CYAN}本地 Skills:${NC}"
echo "===================="
echo ""

count=0
for dir in "$SKILLS_DIR"/*/; do
    [ -d "$dir" ] || continue

    name=$(basename "$dir")
    skill_file="$dir/SKILL.md"

    # 读取描述
    if [ -f "$skill_file" ]; then
        # 从 SKILL.md 提取 description
        desc=$(grep -A1 "^description:" "$skill_file" 2>/dev/null | head -1 | sed 's/description: *"\{0,1\}//' | sed 's/"\{0,1\}$//' | cut -c1-60)
        if [ -z "$desc" ]; then
            desc="(无描述)"
        fi
    else
        desc="${DIM}(无 SKILL.md)${NC}"
    fi

    # 检查是否为 git 仓库
    if [ -d "$dir/.git" ]; then
        type_tag="${YELLOW}[git]${NC}"
    else
        type_tag="${DIM}[local]${NC}"
    fi

    echo -e "${GREEN}$name${NC} $type_tag"
    echo -e "  $desc"
    echo ""

    ((count++))
done

echo "===================="
echo -e "共计: ${GREEN}$count${NC} 个 skills"