# Codex 平台目录（codex）

## 目录说明

`platforms/codex` 是 Codex 平台唯一配置源，包含：

- `platforms/codex/AGENTS.md`
- `platforms/codex/skills/`
- `platforms/codex/agents/`
- `platforms/codex/bin/`
- `platforms/codex/hooks/`
- `platforms/codex/config.toml`
- `platforms/codex/scripts/`
- `platforms/codex/rules/`

其中，Codex Skills 官方加载路径使用 `~/.codex/skills`（`$CODEX_HOME/skills`）。每个 skill 目录必须包含 `SKILL.md`。

## 同步入口

```bash
./scripts/sync_to_codex.sh
```

预览：

```bash
./scripts/sync_to_codex.sh --dry-run
```

说明：

- 默认目标：
  - `~/.codex/skills`
  - `~/.codex/AGENTS.md`
  - `~/.codex/config.toml`
  - `~/.codex/{agents,bin,hooks,scripts,rules}`
- 可选参数：`--codex-home`（用于自定义 Codex 目录）。
- 可选参数：`--skills-only`（仅同步 skills）、`--root-only`（仅同步受管 root 配置）。
- 同步策略：增量同步（不删除目录外未托管内容）。
- `~/.codex/skills` 保留 `.system` 与本地未托管技能。
- 建议先执行 `--dry-run` 预览变更，再正式执行。

## 当前策略

- `cc-codex-review` 不进入 Codex 平台（该 Skill 专用于 Claude 调 Codex）
- `cc-codex-review` 关联的 Battle Agent 也不进入 Codex 平台
- skills 按 Codex 官方规范管理
- root 受管配置仅维护可迁移内容：`AGENTS.md`、`config.toml`、`agents/bin/hooks/scripts/rules`
- 不同步运行态与敏感文件（如 `auth.json`、`history.jsonl`、`sessions/`、`log/`、`tmp/`）
- 若换机后用户目录发生变化，需检查并更新 `~/.codex/config.toml` 内的绝对路径（如 `notify`、`[projects."..."]`）
