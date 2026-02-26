# orbit-session-diary

把当日 Codex/Claude 会话按目录与操作聚合，写入 Obsidian `01_日记/YYYY-MM-DD.md` 的自动总结区块。

## 入口

- Skill: `SKILL.md`
- Script: `scripts/session_diary.py`
- Excludes: `references/excludes.json`

## 快速使用

```bash
SKILLS_HOME="$HOME/.claude/skills"
python3 "$SKILLS_HOME/orbit-session-diary/scripts/session_diary.py" --dry-run
python3 "$SKILLS_HOME/orbit-session-diary/scripts/session_diary.py"
```
