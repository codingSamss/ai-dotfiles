#!/bin/bash
set -euo pipefail

NEED_MANUAL=0

echo "[pinchtab] 本脚本仅做校验，不会自动安装依赖"

echo "[pinchtab] 检查 pinchtab 可执行..."
if command -v pinchtab >/dev/null 2>&1; then
  if pinchtab --version >/dev/null 2>&1; then
    echo "[pinchtab] pinchtab 已安装，版本可读"
  else
    echo "[pinchtab] pinchtab 已存在，但版本检查失败"
    NEED_MANUAL=1
  fi
else
  echo "[pinchtab] 未检测到 pinchtab，请先安装"
  echo "[pinchtab] 参考：curl -fsSL https://pinchtab.com/install.sh | bash"
  echo "[pinchtab] 或：npm install -g pinchtab@latest"
  NEED_MANUAL=1
fi

echo "[pinchtab] 检查 PinchTab 健康端点..."
if command -v curl >/dev/null 2>&1; then
  if curl -fsS --max-time 3 http://127.0.0.1:9867/health >/dev/null 2>&1; then
    echo "[pinchtab] 健康检查通过"
  else
    echo "[pinchtab] 健康检查失败，请确认 PinchTab 服务已启动并监听 127.0.0.1:9867"
    NEED_MANUAL=1
  fi
else
  echo "[pinchtab] 未检测到 curl，无法执行健康检查"
  NEED_MANUAL=1
fi

echo "[pinchtab] 检查 playwright-ext 兜底通道..."
if command -v codex >/dev/null 2>&1; then
  if codex mcp get playwright-ext >/dev/null 2>&1; then
    echo "[pinchtab] playwright-ext MCP 已就绪"
  else
    echo "[pinchtab] 未检测到 playwright-ext MCP，请先配置："
    echo "  codex mcp add playwright-ext --env PLAYWRIGHT_MCP_EXTENSION_TOKEN=<token> -- npx @playwright/mcp@latest --extension"
    NEED_MANUAL=1
  fi
else
  echo "[pinchtab] 未检测到 codex 命令，跳过 playwright-ext 自动校验"
fi

if [ "$NEED_MANUAL" -eq 1 ]; then
  exit 2
fi
