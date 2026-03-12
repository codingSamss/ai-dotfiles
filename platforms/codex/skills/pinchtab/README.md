# pinchtab

## 作用
通过 PinchTab 执行浏览器自动化流程（多标签页、会话、页面交互），并在失败时回退到 `playwright-ext`。

## 平台支持
- Codex（已支持）

## 工作原理
- 默认优先 PinchTab 作为浏览器控制通道。
- 当 PinchTab 不可达、鉴权失败或能力不足时，立即回退到 `playwright-ext`。
- 本 skill 仅提供分层路由与检查约定，不改动现有 Playwright 默认能力。

## 配置命令

```bash
./setup.sh pinchtab
# 或直接执行
platforms/codex/skills/pinchtab/setup.sh
```

## 配置脚本行为

- 退出码：`0` 自动完成，`2` 需手动补齐，`1` 执行失败
- 注意：`setup.sh` 只校验，不自动安装；校验失败表示当前环境不可用，需先补齐依赖再使用。
- 自动检查项：
  - `pinchtab` 命令是否可用，且版本可读
  - `http://127.0.0.1:9867/health` 是否可访问
  - `playwright-ext` 兜底通道是否可检查（`codex` 可用时）
- 需手动补齐项：
  - 未安装 PinchTab
  - PinchTab 服务未启动或健康检查失败
  - `playwright-ext` 未就绪（且本机可用 `codex`）

## 验证命令

```bash
pinchtab --version
curl -fsS --max-time 3 http://127.0.0.1:9867/health
codex mcp get playwright-ext
```

## 安装与启动参考

```bash
# install.sh
HTTP_PROXY=http://127.0.0.1:7897 HTTPS_PROXY=http://127.0.0.1:7897 \
curl -fsSL https://pinchtab.com/install.sh | bash

# npm
npm install -g pinchtab@latest

# docker
docker run --rm -p 9867:9867 ghcr.io/pinchtab/pinchtab:latest
```

说明：以上命令来自 PinchTab 官方安装路径，具体运行参数请以官方文档为准。
