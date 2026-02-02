# Claude Code Agent Skills 开发项目

这是一个用于开发个人 Claude Code agent skills 的项目。

## 项目结构

```
.claude/
├── commands/            # 自定义 skills 目录
│   └── hello.md        # 示例 skill
└── settings.local.json  # Claude Code 配置文件
```

## 什么是 Claude Code Skills？

Skills 是 Claude Code 的可重用命令，通过斜杠命令（如 `/hello`）触发。它们允许你：
- 自动化常见的开发工作流
- 创建项目特定的命令
- 扩展 Claude Code 的功能

## 如何使用现有的 Skill

在 Claude Code CLI 中，直接输入斜杠命令即可：

```
/hello
```

## 开发新的 Skill

### 1. 创建 Skill 文件

在 `.claude/commands/` 目录下创建一个 Markdown 文件，文件名即为命令名。

例如，创建 `myskill.md` 文件，就可以通过 `/myskill` 调用。

### 2. Skill 文件格式

Skill 文件由两部分组成：

**YAML Frontmatter（可选）**
```yaml
---
description: Skill 的描述信息
---
```

**Markdown 内容（必需）**
包含给 Claude 的指令，描述 skill 应该做什么。

### 3. 示例 Skill

查看 `.claude/commands/hello.md` 了解基本结构。

### 4. 高级功能

**参数传递**
Skills 可以接受参数：
- `$ARGUMENTS` - 获取所有参数
- `$1`, `$2` - 获取位置参数

**Hooks**
可以在 skill 执行的不同阶段添加钩子函数。

## 验证 Skill 配置

在 Claude Code CLI 中输入以下命令测试：

```
/hello
```

如果配置正确，Claude 会执行 hello skill 中定义的指令。

## 参考资源

- [Claude Code 官方文档](https://claude.com)
- [Agent Skills 标准](https://anthropic.com)

## 下一步

1. 尝试运行 `/hello` 命令验证配置
2. 创建更多自定义 skills
3. 探索 hooks 和高级功能
