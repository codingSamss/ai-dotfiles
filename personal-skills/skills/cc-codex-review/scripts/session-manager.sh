#!/bin/bash
# session-manager.sh - CC-Codex 协作审查 SESSION_ID 管理脚本
#
# 用法:
#   session-manager.sh read <项目根目录> <阶段名>
#   session-manager.sh save <项目根目录> <阶段名> <session_id>
#   session-manager.sh reset <项目根目录> <阶段名>
#   session-manager.sh reset-all <项目根目录>
#   session-manager.sh status <项目根目录>
#
# 阶段名: plan-review | code-review | final-review

set -euo pipefail

ACTION="${1:-}"
PROJECT_ROOT="${2:-}"
PHASE="${3:-}"
SESSION_ID="${4:-}"

# 数据目录
DATA_DIR=".cc-codex"
SESSIONS_DIR="${DATA_DIR}/sessions"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

usage() {
    echo "用法: session-manager.sh <action> <project_root> [phase] [session_id]"
    echo ""
    echo "Actions:"
    echo "  read       读取指定阶段的 SESSION_ID"
    echo "  save       保存指定阶段的 SESSION_ID"
    echo "  reset      重置指定阶段的会话"
    echo "  reset-all  重置所有阶段的会话"
    echo "  status     显示所有阶段的会话状态"
    echo ""
    echo "Phases: plan-review | code-review | final-review"
    exit 1
}

# 验证阶段名是否合法
validate_phase() {
    local phase="$1"
    case "$phase" in
        plan-review|code-review|final-review)
            return 0
            ;;
        *)
            echo -e "${RED}错误: 无效的阶段名 '${phase}'${NC}" >&2
            echo "合法值: plan-review | code-review | final-review" >&2
            exit 1
            ;;
    esac
}

# 确保数据目录存在
ensure_dirs() {
    local root="$1"
    mkdir -p "${root}/${SESSIONS_DIR}"
}

# 获取会话文件路径
session_file() {
    local root="$1"
    local phase="$2"
    echo "${root}/${SESSIONS_DIR}/${phase}.session"
}

# 读取 SESSION_ID
do_read() {
    local root="$1"
    local phase="$2"
    validate_phase "$phase"

    local file
    file=$(session_file "$root" "$phase")

    if [[ -f "$file" ]]; then
        cat "$file"
    else
        echo ""
    fi
}

# 保存 SESSION_ID
do_save() {
    local root="$1"
    local phase="$2"
    local sid="$3"
    validate_phase "$phase"

    if [[ -z "$sid" ]]; then
        echo -e "${RED}错误: SESSION_ID 不能为空${NC}" >&2
        exit 1
    fi

    ensure_dirs "$root"
    local file
    file=$(session_file "$root" "$phase")
    echo "$sid" > "$file"
    echo -e "${GREEN}已保存 ${phase} 的 SESSION_ID${NC}"
}

# 重置指定阶段
do_reset() {
    local root="$1"
    local phase="$2"
    validate_phase "$phase"

    local file
    file=$(session_file "$root" "$phase")

    if [[ -f "$file" ]]; then
        rm "$file"
        echo -e "${YELLOW}已重置 ${phase} 的会话${NC}"
    else
        echo -e "${YELLOW}${phase} 无活跃会话${NC}"
    fi
}

# 重置所有阶段
do_reset_all() {
    local root="$1"
    local dir="${root}/${SESSIONS_DIR}"

    if [[ -d "$dir" ]]; then
        rm -f "${dir}"/*.session
        echo -e "${YELLOW}已重置所有阶段的会话${NC}"
    else
        echo -e "${YELLOW}无活跃会话${NC}"
    fi
}

# 显示状态
do_status() {
    local root="$1"
    local phases=("plan-review" "code-review" "final-review")

    echo "=== CC-Codex 审查会话状态 ==="
    echo "项目: ${root}"
    echo ""

    for phase in "${phases[@]}"; do
        local file
        file=$(session_file "$root" "$phase")
        if [[ -f "$file" ]]; then
            local sid
            sid=$(cat "$file")
            local short_id="${sid:0:12}..."
            echo -e "  ${phase}: ${GREEN}活跃${NC} (${short_id})"
        else
            echo -e "  ${phase}: ${RED}无会话${NC}"
        fi
    done

    echo ""

    # 检查计划文件
    if [[ -f "${root}/${DATA_DIR}/plan.md" ]]; then
        echo -e "  共识计划: ${GREEN}存在${NC}"
    else
        echo -e "  共识计划: ${RED}未创建${NC}"
    fi

    # 检查审查日志
    if [[ -f "${root}/${DATA_DIR}/review-log.md" ]]; then
        echo -e "  审查日志: ${GREEN}存在${NC}"
    else
        echo -e "  审查日志: ${RED}未创建${NC}"
    fi
}

# 参数校验
if [[ -z "$ACTION" ]]; then
    usage
fi

if [[ -z "$PROJECT_ROOT" ]]; then
    echo -e "${RED}错误: 必须指定项目根目录${NC}" >&2
    usage
fi

# 分发命令
case "$ACTION" in
    read)
        [[ -z "$PHASE" ]] && usage
        do_read "$PROJECT_ROOT" "$PHASE"
        ;;
    save)
        [[ -z "$PHASE" ]] && usage
        [[ -z "$SESSION_ID" ]] && usage
        do_save "$PROJECT_ROOT" "$PHASE" "$SESSION_ID"
        ;;
    reset)
        [[ -z "$PHASE" ]] && usage
        do_reset "$PROJECT_ROOT" "$PHASE"
        ;;
    reset-all)
        do_reset_all "$PROJECT_ROOT"
        ;;
    status)
        do_status "$PROJECT_ROOT"
        ;;
    *)
        echo -e "${RED}错误: 未知操作 '${ACTION}'${NC}" >&2
        usage
        ;;
esac
