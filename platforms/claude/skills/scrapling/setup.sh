#!/bin/bash
set -euo pipefail

NEED_MANUAL=0

echo "[scrapling] 本脚本仅做校验，不会自动安装依赖"

echo "[scrapling] 检查 Python3..."
if command -v python3 >/dev/null 2>&1; then
  echo "[scrapling] python3 已安装"
else
  echo "[scrapling] 未检测到 python3，请先安装 Python 3.10+"
  NEED_MANUAL=1
fi

echo "[scrapling] 检查 Python 版本 (>= 3.10)..."
if command -v python3 >/dev/null 2>&1; then
  if python3 - <<'PY' >/dev/null 2>&1
import sys
raise SystemExit(0 if sys.version_info >= (3, 10) else 1)
PY
  then
    echo "[scrapling] Python 版本满足要求"
  else
    echo "[scrapling] Python 版本过低，请升级到 3.10+"
    NEED_MANUAL=1
  fi
fi

echo "[scrapling] 检查 Scrapling 依赖..."
if command -v python3 >/dev/null 2>&1; then
  if python3 - <<'PY' >/dev/null 2>&1
from scrapling.fetchers import Fetcher, AsyncFetcher, DynamicFetcher, StealthyFetcher
_ = (Fetcher, AsyncFetcher, DynamicFetcher, StealthyFetcher)
PY
  then
    echo "[scrapling] scrapling.fetchers 可导入"
  else
    echo "[scrapling] 未检测到 Scrapling fetchers 依赖，请执行："
    echo "  python3 -m pip install \"scrapling[fetchers]\""
    echo "  scrapling install"
    NEED_MANUAL=1
  fi
fi

echo "[scrapling] 检查 playwright-ext 兜底通道..."
if command -v claude >/dev/null 2>&1; then
  if claude mcp list 2>/dev/null | grep -q "playwright-ext"; then
    echo "[scrapling] playwright-ext MCP 已就绪"
  else
    echo "[scrapling] 未检测到 playwright-ext MCP，请先在 Claude 侧补齐配置："
    echo "  ./setup.sh core"
    echo "  claude mcp list | grep playwright-ext"
    NEED_MANUAL=1
  fi
else
  echo "[scrapling] 未检测到 claude 命令，跳过 playwright-ext 自动校验"
fi

if [ "$NEED_MANUAL" -eq 1 ]; then
  exit 2
fi
