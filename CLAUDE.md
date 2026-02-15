# CLAUDE.md

本文档用于指导 Claude Code（claude.ai/code）在本仓库内协作时的行为与约束。

## 项目概览

这是一个多平台技能仓库，Claude 与 Codex 采用完全隔离的目录与实现。仓库包含技能、脚本、Hook 与 Agent 配置。

## 仓库结构

```text
skills/
├── .claude-plugin/marketplace.json   # 插件注册信息
├── setup.sh                          # Claude 平台配置入口
├── scripts/                          # 同步/引导脚本
└── platforms/
    ├── claude/                       # Claude 唯一真源
    │   ├── .claude-plugin/plugin.json
    │   ├── .mcp.json
    │   ├── skills/
    │   ├── hooks/
    │   └── agents/
    └── codex/                        # Codex 唯一真源
        ├── skills/
        ├── hooks/
        ├── agents/
        └── scripts/
```

## Skill 文件格式

每个技能通过 `SKILL.md` 定义，推荐结构如下：

```markdown
---
name: skill-name
description: "包含触发关键词的描述"
---

# Skill 标题

给 Claude 的执行指令...
```

- YAML 头中的 `name` 与 `description` 决定发现与触发行为。
- `description` 建议包含中英文关键词，便于搜索命中。
- Markdown 正文为完整执行指令。
- 参数约定：`$ARGUMENTS`（全部参数）、`$1`/`$2`（位置参数）。

## 关键技能与依赖

| 技能 | 外部依赖 | 运行时 |
|---|---|---|
| bird-twitter | Bird CLI（`brew install steipete/tap/bird`） | - |
| peekaboo | Peekaboo（`brew install steipete/tap/peekaboo`） | - |
| cc-codex-review | Codex MCP 服务 | Python（`scripts/topic-manager.py`） |
| plugin-manager | Claude Code 插件系统 | Bash（`scripts/`） |
| ui-ux-pro-max | Python 3 | Python（`scripts/search.py`、`scripts/core.py`） |

## 架构约定

- 技能目录隔离：每个技能在 `skills/<skill-name>/` 独立维护，避免跨技能耦合。
- 脚本委派：复杂技能通过入口脚本分派到子脚本，不在提示词中堆积逻辑。
- 数据驱动（ui-ux-pro-max）：使用 CSV 作为知识库，结合 BM25（`core.py`）由 `search.py` 查询。

## 本地同步规则

本项目按平台同步生效，提交前必须完成对应同步验证。

- Claude 同步入口：`./setup.sh`（源目录 `platforms/claude`）。
- Codex 同步入口：`./scripts/sync_to_codex.sh`（源目录 `platforms/codex/skills`，同步到 `~/.codex/skills`）。
- 涉及 `platforms/claude/` 或 `platforms/codex/` 的改动，必须执行对应同步并检查结果。
- GitHub 仓库、本地项目目录、本地 CLI 根目录（`~/.claude`、`~/.codex`）三者需保持一致。
- 推送 GitHub 必须等待用户明确确认。

## 通用约定

- 技能描述建议包含中英文触发词。
- `scripts/` 下脚本应保持可执行、可重复运行、无副作用残留。
- 提交信息遵循 Conventional Commits（如 `feat:`、`fix:`、`chore:`）。
