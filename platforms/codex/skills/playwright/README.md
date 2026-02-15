# playwright

## 作用
通过命令行驱动真实浏览器，完成页面访问、交互、快照、截图与流程调试。

## 平台支持
- Codex（已支持）

## 工作原理
Skill 使用 `scripts/playwright_cli.sh` 包装 `npx --package @playwright/cli playwright-cli`，避免必须全局安装。

## 配置命令

```bash
platforms/codex/skills/playwright/setup.sh
```

## 配置脚本行为

- 退出码：`0` 自动完成，`2` 需手动补齐，`1` 执行失败
- 自动检查项：
  - `npx` 是否可用（缺失时尝试安装 Node.js）
  - 包装脚本 `playwright_cli.sh` 是否可执行
  - `playwright-cli --help` 可用性（默认带本地代理）
- 需手动补齐项：
  - 没有 Homebrew 且缺少 Node.js/npm
  - 网络受限导致 `npx` 拉取 `@playwright/cli` 失败

## 验证命令

```bash
platforms/codex/skills/playwright/scripts/playwright_cli.sh --help
```

## 依赖
- Node.js / npm / npx
- `@playwright/cli`（通过 npx 或全局安装）
