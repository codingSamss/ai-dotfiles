---
name: orbit-session-diary
description: "Summarize today's non-work Codex/Claude session operations from local JSONL logs into Obsidian diary, with directory filtering and idempotent section updates. Use when user asks to aggregate daily sessions, write diary logs, or summarize cross-directory operations while excluding work projects (for example rag-flow/rag-recall)."
---

# Orbit Session Diary Skill

把当天 `Codex + Claude` 会话日志（`jsonl`）聚合成一段可回写到 Obsidian 日记的总结，默认排除工作项目目录（如 `rag-flow`、`rag-recall`）。

## Script Path

```bash
SKILLS_HOME="$HOME/.claude/skills"
SCRIPT="$SKILLS_HOME/orbit-session-diary/scripts/session_diary.py"
```

## Default Behavior

1. 自动读取当天会话：
   - `~/.codex/sessions/YYYY/MM/DD/*.jsonl`
   - `~/.claude/projects/**/*.jsonl`
2. 默认排除 `rag-flow` / `rag-recall`（可在 `references/excludes.json` 扩展）。
3. 仅提取用户意图与关键命令，跳过大段系统提示，降低上下文噪音。
4. 在日记内维护固定区块（幂等覆盖）：
   - `<!-- SESSION_SUMMARY_AUTO_START -->`
   - `<!-- SESSION_SUMMARY_AUTO_END -->`
5. 写入 `.md` 后自动 `touch` 目标文件，触发 Obsidian/iCloud 感知更新。

## Commands

### 1) 预览当天总结（不写入）

```bash
python3 "$SCRIPT" --date "$(date +%F)" --dry-run
```

### 2) 写入当天日记

```bash
python3 "$SCRIPT" --date "$(date +%F)"
```

### 3) 指定日期

```bash
python3 "$SCRIPT" --date 2026-02-26
```

### 4) 自定义 Vault 根目录

```bash
python3 "$SCRIPT" \
  --vault-root "$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Sam's" \
  --date 2026-02-26
```

### 5) 调整数据来源

```bash
python3 "$SCRIPT" --sources codex
python3 "$SCRIPT" --sources claude
python3 "$SCRIPT" --sources codex,claude
```

## Notes

- 若用户明确要求“只总结某几个目录”，优先更新 `references/excludes.json` 后再执行。
- 若用户指定不同日记区块标题，可用 `--section-title` 覆盖默认值 `会话总结（自动）`。
