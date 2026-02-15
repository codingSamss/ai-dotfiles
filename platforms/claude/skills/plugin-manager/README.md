# plugin-manager

## 作用
管理 Claude Code 插件，包括列表、详情、检查更新、批量更新、备份与导出。

## 平台支持
- Claude Code（已支持）
- Codex（暂不支持，依赖 Claude 插件系统）

## 工作原理
Skill 调用 `plugin-manager` 脚本，对 Claude 插件缓存与安装清单做查询和操作封装。

## 配置命令

```bash
./setup.sh plugin-manager
# 或直接执行
platforms/claude/skills/plugin-manager/setup.sh
```

## 配置脚本行为

- 退出码：`0` 自动完成，`2` 需手动补齐，`1` 执行失败
- 自动检查项：
  - `claude` 命令是否可用
- 需手动补齐项：
  - 本机尚未安装或配置 Claude Code CLI

## 验证命令

```bash
claude --version
```

## 使用方式
- 触发词：`列出插件`、`更新插件`、`备份插件`
- 详细命令见：`platforms/claude/skills/plugin-manager/SKILL.md`

## 依赖
- 无额外系统依赖（需本机可执行 `claude` 命令）
