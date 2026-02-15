# ui-ux-pro-max

## 作用
提供 UI/UX 设计知识检索与落地辅助，覆盖风格、配色、排版、组件与多技术栈实践。

## 平台支持
- Claude Code（已支持）
- Codex（已支持）

## 工作原理
Skill 通过本地 `search.py` 在内置数据集中检索，再由模型综合结果生成设计方案与实现建议。

## 配置命令

```bash
./setup.sh ui-ux-pro-max
# 或直接执行
platforms/codex/skills/ui-ux-pro-max/setup.sh
```

## 配置脚本行为

- 退出码：`0` 自动完成，`2` 需手动补齐，`1` 执行失败
- 自动检查项：
  - Python3 是否可用（缺失时尝试安装）
- 需手动补齐项：
  - 没有 Homebrew 且缺少 Python3

## 验证命令

```bash
python3 --version
```

## 使用方式
- 触发词：`design`、`build`、`review UI`、`improve UX`
- 检索流程与示例见：`platforms/codex/skills/ui-ux-pro-max/SKILL.md`

## 依赖
- Python3
