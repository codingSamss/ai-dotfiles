# scrapling

## 作用
通过 Scrapling 执行网页抓取与结构化提取（HTTP/异步/动态/Stealth），在必要时回退到 `playwright-ext`。

## 平台支持
- Codex（已支持）

## 工作原理
- 默认使用 Scrapling 抓取链路：
  - `Fetcher` / `AsyncFetcher`（轻量抓取）
  - `DynamicFetcher` / `StealthyFetcher`（动态页与反爬场景）
- 若遇到持续风控、验证码或交互要求超出抓取层能力，回退到 `playwright-ext`。

## 配置命令

```bash
./setup.sh scrapling
# 或直接执行
platforms/codex/skills/scrapling/setup.sh
```

## 配置脚本行为

- 退出码：`0` 自动完成，`2` 需手动补齐，`1` 执行失败
- 注意：`setup.sh` 只校验，不自动安装；校验失败表示当前环境不可用，需先补齐依赖再使用。
- 自动检查项：
  - Python3 是否存在且版本 >= 3.10
  - `scrapling` 与 `scrapling.fetchers` 是否可导入
  - `playwright-ext` 兜底通道是否可检查（`codex` 可用时）
- 需手动补齐项：
  - Python 版本不满足
  - Scrapling 依赖缺失
  - `playwright-ext` 未就绪（且本机可用 `codex`）

## 验证命令

```bash
python3 --version
python3 -c "from scrapling.fetchers import Fetcher, AsyncFetcher, DynamicFetcher, StealthyFetcher"
codex mcp get playwright-ext
```

## 推荐安装链路

```bash
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install -U pip
python3 -m pip install "scrapling[fetchers]"
scrapling install
```

说明：建议优先使用虚拟环境安装，避免污染系统 Python。
