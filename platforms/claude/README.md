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
