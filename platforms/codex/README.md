# Codex 平台目录（codex）

## 目录说明

`platforms/codex` 是 Codex 平台唯一配置源，包含：

- `platforms/codex/skills/`
- `platforms/codex/agents/`
- `platforms/codex/hooks/`
- `platforms/codex/scripts/`

## 同步入口

```bash
./scripts/sync_to_codex.sh
```

预览：

```bash
./scripts/sync_to_codex.sh --dry-run
```

说明：

- 同步为镜像模式（`rsync --delete`），会清理 `~/.codex` 下与源目录不一致的旧文件。
- 建议先执行 `--dry-run` 预览变更，再正式执行。

## 当前策略

- `cc-codex-review` 不进入 Codex 平台（该 Skill 专用于 Claude 调 Codex）
- `cc-codex-review` 关联的 Battle Agent 也不进入 Codex 平台
- Codex 与 Claude 不要求同构，按平台各自演进
