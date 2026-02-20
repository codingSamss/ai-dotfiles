# reddit

## 作用
通过 Composio MCP 以只读方式访问 Reddit（搜索、热帖、帖子与评论）。

## 平台支持
- Codex（已支持）

## 工作原理
Skill 调用 `composio-reddit` MCP 工具链，仅开放只读能力，避免写操作风险。

## 配置命令

```bash
./setup.sh reddit
# 或直接执行
platforms/codex/skills/reddit/setup.sh
```

## 配置脚本行为

- 退出码：`0` 自动完成，`2` 需手动补齐，`1` 执行失败
- 自动检查项：
  - Python3 是否可用（缺失时尝试安装）
  - Composio SDK 是否可导入（缺失时尝试 `python3 -m pip install --user --break-system-packages composio`）
  - `composio-reddit` MCP 是否已在 Codex 中注册（`codex mcp list`）
  - `composio-reddit` 是否绑定 `COMPOSIO_API_KEY`（`bearer_token_env_var`）
- 需手动补齐项：
  - 没有 Homebrew 且缺少 Python3
  - 缺少 `COMPOSIO_API_KEY` 环境变量
  - Composio Reddit OAuth 未完成

## 验证命令

```bash
python3 -c "import composio"
codex mcp list
codex mcp get composio-reddit
```

## 启动失败快速修复（MCP startup incomplete / handshaking decode error）

当出现 `MCP client for composio-reddit failed to start`，通常是服务端要求 API Key 而本地未附带。

```bash
# 1) 准备 Composio API Key（替换成你的真实 key）
export COMPOSIO_API_KEY='your_composio_api_key'

# 2) 重新注册 MCP（绑定 bearer token 环境变量）
codex mcp remove composio-reddit
codex mcp add composio-reddit \
  --url "https://backend.composio.dev/tool_router/trs_XmogRrjwpzM_/mcp" \
  --bearer-token-env-var COMPOSIO_API_KEY

# 3) 验证
codex mcp get composio-reddit
```

说明：
- `codex mcp login composio-reddit` 当前会返回 `No authorization support detected`，该服务不是 OAuth 登录模式。
- Reddit 账号授权（OAuth）仍需在 Composio 控制台完成，二者缺一不可。

## 使用方式
- 触发词：`search reddit`、`hot posts`、`reddit comments`
- 详细工具映射见：`platforms/codex/skills/reddit/SKILL.md`

## 依赖
- Python3
- Composio SDK（`python3 -m pip install --user --break-system-packages composio`）
- Composio API Key（环境变量 `COMPOSIO_API_KEY`）
- Composio Reddit OAuth 授权
