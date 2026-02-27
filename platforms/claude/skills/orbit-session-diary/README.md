# orbit-session-diary

把当日 Codex/Claude 会话按目录与操作聚合为“证据包”，再由助手人工归纳并直接写入 Obsidian 日记正文。

## 入口

- Skill: `SKILL.md`
- Script: `scripts/session_diary.py`
- Excludes: `references/excludes.json`

## 快速使用

```bash
SKILLS_HOME="$HOME/.claude/skills"
python3 "$SKILLS_HOME/orbit-session-diary/scripts/session_diary.py"
```

1. 先跑脚本拿证据（上面命令）。
2. 助手基于证据人工汇总并直接写 `01_日记/YYYY-MM-DD.md` 正文。
3. 若通过终端改动 `.md`，执行 `touch <file>` 刷新 Obsidian 感知。

正文输出建议固定为：`今日主线` + `今天做了什么` + `主题聚合（核心）` + `结果汇总` + `关联项目`。
写作前先通过 evidence 的“写作校验（防偏题）”确认目录覆盖是否达标。

说明：
- `--output-mode write-auto` 仅用于维护自动附录区块，不作为正文生成方式。
- `--dry-run` 已废弃，默认行为即 evidence 模式，无需额外指定。
