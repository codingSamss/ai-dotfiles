# Codex 平台目录（codex）

`platforms/codex` 是 Codex 平台唯一真源。这个 README 负责展示当前 Codex agent 的完整能力与同步方式。

## 同步入口

```bash
./scripts/sync_to_codex.sh
./scripts/sync_to_codex.sh --dry-run
./scripts/sync_to_codex.sh --sync-config
```

说明：

- 默认同步 `skills/` 与受管 root 配置到 `~/.codex`
- `config.toml` 默认不覆盖本机，仅在显式 `--sync-config` 时同步
- `~/.codex/skills` 保留 `.system` 与本地未托管技能

## 当前 Skills

以下技能简介以各自 `SKILL.md` 的 `description` 为准，并压缩为便于浏览的摘要。

| Skill | 能力 | 运行说明 |
| --- | --- | --- |
| `bird-twitter` | 只读访问 X/Twitter 内容 | 依赖 Bird CLI |
| `google-workspace` | 只读访问 Google Workspace 内容 | 依赖 gogcli 与 OAuth 登录态 |
| `image-gen` | 图片生成与结构化图表生成 | 依赖图片 provider 配置 |
| `linuxdo` | 只读访问 LINUX DO 论坛 | 依赖 Chrome Cookie |
| `midea-recall-diagnose-playwright` | keyword 检索漏召回排障与请求复现 | 依赖 Playwright 会话与本地脚本 |
| `openai-docs` | OpenAI 官方文档与 API 实现指引 | 依赖官方 docs MCP |
| `orbit-os` | OrbitOS Obsidian Vault 共享配置与规范 | 供 orbit-* 系列 skill 引用 |
| `orbit-session-diary` | 基于本地会话日志生成 Obsidian 日记 | 依赖本地 jsonl 与目标 Vault |
| `peekaboo` | macOS 截图与视觉分析 | 依赖 Peekaboo |
| `pinchtab` | PinchTab 优先的浏览器自动化 | PinchTab + `agents/openai.yaml` + `playwright-ext` |
| `playwright` | MCP-only 真实浏览器自动化 | 依赖 `playwright-ext` 浏览器扩展会话 |
| `reddit` | 只读访问 Reddit 内容 | 依赖 Composio MCP |
| `scrapling` | Scrapling 优先的网页抓取与结构化提取 | `scrapling[fetchers]` + `agents/openai.yaml` + `playwright-ext` |
| `screenshot` | 系统级截图与区域捕获 | 使用 OS 级截图能力 |
| `ui-ux-pro-max` | UI/UX 设计知识检索与落地辅助 | 依赖本地 scripts/知识库 |
| `video-transcribe` | 视频/音频转录、关键帧分析与总结 | 依赖 yt-dlp / ffmpeg / Groq |
| `xiaohongshu-session-reader` | 小红书 HTTP/API 优先读取 | Chrome Cookie + Playwright fallback |

## 平台能力资产

- 受管 root 配置：`AGENTS.md`、`agents/`、`bin/`、`hooks/`、`scripts/`、`rules/`
- `./scripts/sync_to_codex.sh` 负责把 `platforms/codex` 应用到 `~/.codex`
- `platforms/codex/config.toml` 默认不自动覆盖本机 `~/.codex/config.toml`
- `platforms/codex/config.toml` 已内置浏览器 MCP：`playwright-ext` 与 `chrome-devtools`（需 `--sync-config` 才会写入本机）
- skill 若需要依赖、手动步骤、验证命令，统一写入 skill 目录下的 `runtime.yaml`
- 平台级 `platforms/codex/runtime.yaml` 仅用于仓库内 AI 理解迁移规则，不会同步到 `~/.codex` 根目录
- skill 级 `runtime.yaml` 仅会同步到 `~/.codex/skills/<skill>/runtime.yaml`
