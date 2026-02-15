# security-best-practices

## 作用
提供按语言/框架划分的安全最佳实践基线，用于安全评审与修复指导。

## 平台支持
- Codex（已支持）

## 工作原理
Skill 读取 `references/` 下的安全文档，根据项目技术栈匹配对应基线。

## 配置命令

```bash
platforms/codex/skills/security-best-practices/setup.sh
```

## 配置脚本行为

- 退出码：`0` 自动完成，`1` 执行失败
- 自动检查项：
  - `SKILL.md` 是否存在
  - `references/` 目录是否存在
  - 是否存在可用安全基线文档（`*.md`）

## 验证命令

```bash
find platforms/codex/skills/security-best-practices/references -type f -name '*.md' | wc -l
```

## 依赖
- 无额外运行时依赖（文档型 Skill）
