# Repository Guidelines

## 项目结构与模块组织
本仓库采用平台隔离设计，`platforms/claude/` 与 `platforms/codex/` 分别维护，互不混用实现细节。

- `platforms/claude/`：Claude 的 `skills/`、`agents/`、`hooks/`、`.claude-plugin/` 与安装脚本。
- `platforms/codex/`：Codex 的 `skills/`（官方加载源）及扩展资产（`agents/`、`hooks/`、`scripts/`）。
- 根脚本：`setup.sh`、`scripts/bootstrap.sh`、`scripts/sync_to_codex.sh`。

每个技能目录建议包含 `SKILL.md`、`README.md`、`setup.sh`；其中 Codex 技能必须有 `SKILL.md`。

## 构建、测试与开发命令
- `./setup.sh list`：列出可执行配置的 Claude 技能。
- `./setup.sh all`：执行 Claude 的核心配置与全部技能配置。
- `./setup.sh <skill...>`：仅配置指定技能。
- `./scripts/sync_to_codex.sh --dry-run`：预览 Codex 配置同步结果。
- `./scripts/sync_to_codex.sh`：同步 `platforms/codex/skills` 与受管 root 配置到 `~/.codex`。
- `./scripts/bootstrap.sh all`：新机一次执行 Claude 配置 + Codex 同步。

## 代码风格与命名约定
- Shell 脚本统一使用 Bash，并默认开启 `set -euo pipefail`。
- 退出码语义保持一致：`0` 成功，`1` 失败，`2` 需人工补齐。
- 技能目录名使用小写短横线风格，例如 `openai-docs`、`bird-twitter`。
- 文档优先给出可执行命令、路径与验证步骤，避免空泛描述。

## 测试与验证规范
仓库未统一使用单一测试框架，变更主要通过可执行校验完成：

- 直接运行受影响的 `setup.sh`。
- 用 `codex mcp list` 或 `claude mcp list` 验证 MCP 状态。
- 涉及同步逻辑时，先跑 `./scripts/sync_to_codex.sh --dry-run` 再正式执行。

新增技能时，必须在该技能 `README.md` 中提供至少一条验证命令。

## 提交与合并请求规范
提交信息遵循 Conventional Commits，例如：
- `feat(scope): ...`
- `fix(scope): ...`
- `docs: ...`
- `refactor: ...`
- `chore: ...`

一次提交尽量只覆盖一个平台或一个技能。合并请求需说明改动路径、执行过的验证命令、行为变化与手工步骤。

## 同步一致性与发布门禁
- 以下三处必须保持一致：
  - GitHub 仓库状态
  - 本地项目目录（仓库工作区）
  - 本地 CLI 根目录（`~/.claude`、`~/.codex`）
- Codex 同步链路：`platforms/codex/skills` -> `~/.codex/skills`（`./scripts/sync_to_codex.sh`）。
- Codex root 受管配置同步链路：`platforms/codex/{AGENTS.md,config.toml,agents,bin,hooks,scripts,rules}` -> `~/.codex/...`。
- Claude 同步链路：通过 `./setup.sh` 将仓库配置应用到本地 Claude 根目录。
- 推送 GitHub 前必须获得用户明确确认，不允许自动推送。

## 安全与配置建议
- 禁止提交密钥、令牌和机器私有配置。
- 凭据统一使用环境变量注入。
- 访问 GitHub 相关资源时默认使用本地代理：
  - `HTTP_PROXY=http://127.0.0.1:7897`
  - `HTTPS_PROXY=http://127.0.0.1:7897`
