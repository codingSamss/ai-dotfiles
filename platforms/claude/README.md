# Claude 平台目录（claude）

## 目录说明

`platforms/claude` 是 Claude 平台唯一配置源，包含：

- `platforms/claude/skills/`
- `platforms/claude/agents/`
- `platforms/claude/hooks/`
- `platforms/claude/.mcp.json`
- `platforms/claude/.claude-plugin/`

## 配置入口

```bash
./setup.sh
```

按 Skill 执行：

```bash
./setup.sh <skill-name>
```

## 退出码

- `0`：自动完成
- `2`：需手动补齐
- `1`：失败

## 维护约定

- `platforms/claude` 是 Claude 平台唯一真源。
- 不再维护 `personal-skills` 兼容目录。
- skill 若需要描述依赖、手动步骤、验证命令，统一使用 `runtime.yaml`；字段最小集合见 `platforms/claude/runtime.yaml` 的 `skill_runtime_contract`；新增 skill 不需要改动平台同步设计。
- 平台级 `platforms/claude/runtime.yaml` 仅用于仓库内 AI 迁移说明，不会同步到 `~/.claude` 根目录；skill 级 `runtime.yaml` 仅会进入对应 skill 目录。
