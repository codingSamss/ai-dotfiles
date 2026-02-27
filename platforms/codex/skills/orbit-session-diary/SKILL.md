---
name: orbit-session-diary
description: "Use local Codex/Claude JSONL logs as evidence, then produce a human-written daily diary summary and write it into Obsidian. Keep directory filtering (for example rag-flow/rag-recall) and avoid mechanical script-style output."
---

# Orbit Session Diary Skill

把当天 `Codex + Claude` 会话日志（`jsonl`）作为证据输入，供助手进行人工汇总并**直接写入日记正文**。重点是“人写总结”，不是脚本拼装内容。

## Script Path

```bash
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
SCRIPT="$CODEX_HOME/skills/orbit-session-diary/scripts/session_diary.py"
```

## Default Behavior

1. 自动读取当天会话：
   - `~/.codex/sessions/YYYY/MM/DD/*.jsonl`
   - `~/.claude/projects/**/*.jsonl`
2. 默认排除 `rag-flow` / `rag-recall`（可在 `references/excludes.json` 扩展）。
3. 先运行脚本提取证据包（`output-mode=evidence`）。
4. 助手必须基于证据进行人工归纳，直接写入日记正文（主线、主题聚合、结果汇总、关联项目）。
5. 自动区块 `write-auto` 仅用于附录或对账，不能替代正文。

## 最终产出（强制）

调用本 skill 的最终交付必须是“已写入日记正文”的人工总结，格式要有叙事感与关联性，不是日志拼接。

### 正文结构模板

```md
# YYYY-MM-DD 周X

> 今日主线：一句话说明当天主推进线。

## 今天做了什么
- [x] 3-6 条关键完成项（写结果，不写操作细枝末节）

## 主题聚合（核心）
### 主题 A：...
- 做了什么：...
- 输出了什么：...
- 得到什么结果：...
- 来源（可选）：...

### 主题 B：...
...

## 结果汇总
- 2-4 条“结果/影响/下一步”结论句

## 关联项目
- [[项目A]]
- [[项目B]]
```

### 质量约束

- 禁止把脚本 evidence 区块原样粘贴为正文。
- 禁止正文堆命令流水账、绝对路径列表、工具调用明细。
- 主题必须体现“决策 -> 动作 -> 结果”的闭环，而不是平铺事件。
- 写作前优先对比同周日记风格，保持语气与结构连续。
- 自动区块只作证据附录，可保留但应简洁，不抢正文。
- 写作前先看 evidence 的“写作校验（防偏题）”。
- 当天 `涉及目录 >= 2` 时，正文必须至少覆盖 2 条不同目录主线。
- 若出现“偏题提醒”，正文必须补写被遗漏目录/主题，不得只围绕当前会话。

## Commands

### 1) 提取当天证据（默认，不写文件）

```bash
python3 "$SCRIPT" --date "$(date +%F)"
```

### 2) 兼容旧参数（已废弃，等同默认行为）

```bash
python3 "$SCRIPT" --date "$(date +%F)" --dry-run
```

### 3) 仅在明确要求时写入自动区块

```bash
python3 "$SCRIPT" --date "$(date +%F)" --output-mode write-auto
```

### 4) 指定日期

```bash
python3 "$SCRIPT" --date 2026-02-26
```

### 5) 自定义 Vault 根目录

```bash
python3 "$SCRIPT" \
  --vault-root "$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Sam's" \
  --date 2026-02-26
```

### 6) 调整数据来源

```bash
python3 "$SCRIPT" --sources codex
python3 "$SCRIPT" --sources claude
python3 "$SCRIPT" --sources codex,claude
```

## Notes

- 若用户明确要求“只总结某几个目录”，优先更新 `references/excludes.json` 后再执行。
- 若用户指定不同日记区块标题，可用 `--section-title` 覆盖默认值 `会话总结（自动）`。
- 日记正文必须由助手人工汇总生成，禁止直接复制脚本证据包到正文。
- 同步写作时要参考同周其他日期风格，确保关联性与叙事连续性。
- 若通过终端改动 `.md`，修改后需 `touch <file>` 触发 Obsidian 感知刷新。
- 若用户反馈“写偏了”，先判断是成文偏差还是 evidence 偏差，再反向更新 skill 规则。
