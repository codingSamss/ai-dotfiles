# All My AI Needs（Claude Code + Codex）

这个仓库现在采用**平台完全隔离**：

- Claude 平台源：`platforms/claude/`
- Codex 平台源：`platforms/codex/`

两边目录独立维护，技术实现允许不同，不强行统一。

## 目录约定

1. `platforms/claude/`
- Claude 的 `skills/agents/hooks/.mcp.json/.claude-plugin` 等完整配置源。

2. `platforms/codex/`
- Codex 的 `skills` 官方配置源（`SKILL.md` 规范）。
- 同时维护 Codex 根目录受管配置：`AGENTS.md`、`agents/bin/hooks/scripts/rules`（`config.toml` 默认不覆盖本机）。

## 快速使用

### Claude 侧

```bash
# 读取 platforms/claude 作为源执行配置
./setup.sh

# 按 skill 执行
./setup.sh reddit
./setup.sh cc-codex-review peekaboo
```

`setup.sh` 退出码：
- `0`：全部自动完成
- `2`：存在需手动完成项
- `1`：存在失败项

### Codex 侧

```bash
# 默认同步到 ~/.codex（skills + 受管 root 配置，默认不覆盖本机 config.toml）
./scripts/sync_to_codex.sh

# 预览
./scripts/sync_to_codex.sh --dry-run

# 如需显式同步 config.toml
./scripts/sync_to_codex.sh --sync-config
```

### 新机一键

```bash
./scripts/bootstrap.sh all
```

## 设计原则

- 不再维护 `personal-skills` 中间目录。
- 仓库内以 `platforms/claude` 与 `platforms/codex` 作为唯一真源。

## 平台差异约束

- `cc-codex-review` 只保留在 Claude 平台，不同步到 Codex。
- Codex Skills 严格使用 `SKILL.md`，默认同步到 `~/.codex/skills`。
- skill 若需要声明依赖、手动步骤、验证命令，统一放在 `runtime.yaml`；字段最小集合以平台 `runtime.yaml` 里的 `skill_runtime_contract` 为准，新增 skill 不应要求改动同步脚本。
- Codex 根目录受管配置同步到 `~/.codex/{AGENTS.md,agents,bin,hooks,scripts,rules}`。
- `~/.codex/config.toml` 默认保留本机版本；仅在显式执行 `./scripts/sync_to_codex.sh --sync-config` 时同步。
- 同步策略：增量同步（保留 `.system` 与本地未托管内容）。
- 换机若用户名或目录不同，请复核 `~/.codex/config.toml` 的绝对路径配置。
- 同步、提交、推送前，由读取本仓库的 AI 比较本地 `~/.codex`、`~/.claude` 与仓库受管全局配置；忽略 secrets、占位符和运行态噪音，若本地有值得保留的新内容，先回写仓库。
- 各平台 README 作为第一手操作指引。

## 平台文档入口

- Claude：`platforms/claude/README.md`
- Codex：`platforms/codex/README.md`
