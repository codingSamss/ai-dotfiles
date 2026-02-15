#!/bin/bash
set -euo pipefail

NEED_MANUAL=0
PROXY_HTTP="${HTTP_PROXY:-http://127.0.0.1:7897}"
PROXY_HTTPS="${HTTPS_PROXY:-http://127.0.0.1:7897}"

install_python_pkg() {
  local module="$1"
  local package="$2"

  if python3 -c "import ${module}" >/dev/null 2>&1; then
    echo "[pdf] Python 包已安装: ${package}"
    return 0
  fi

  echo "[pdf] 尝试安装 Python 包: ${package}"
  if [ -n "${VIRTUAL_ENV:-}" ]; then
    if python3 -m pip install "${package}" >/dev/null 2>&1; then
      echo "[pdf] 在虚拟环境中安装完成: ${package}"
      return 0
    fi
    if HTTP_PROXY="$PROXY_HTTP" HTTPS_PROXY="$PROXY_HTTPS" \
         python3 -m pip install "${package}" >/dev/null 2>&1; then
      echo "[pdf] 在虚拟环境中通过代理安装完成: ${package}"
      return 0
    fi
  else
    if python3 -m pip install --user "${package}" >/dev/null 2>&1; then
      echo "[pdf] 安装完成: ${package}"
      return 0
    fi

    if python3 -m pip install --user --break-system-packages "${package}" >/dev/null 2>&1; then
      echo "[pdf] 通过 --break-system-packages 安装完成: ${package}"
      return 0
    fi

    if HTTP_PROXY="$PROXY_HTTP" HTTPS_PROXY="$PROXY_HTTPS" \
         python3 -m pip install --user --break-system-packages "${package}" >/dev/null 2>&1; then
      echo "[pdf] 通过代理安装完成: ${package}"
      return 0
    fi
  fi

  echo "[pdf] 自动安装失败: ${package}"
  echo "[pdf] 建议手动执行: python3 -m pip install --user --break-system-packages ${package}"
  NEED_MANUAL=1
}

echo "[pdf] 检查 Python3..."
if command -v python3 >/dev/null 2>&1; then
  echo "[pdf] Python3 已安装"
else
  if command -v brew >/dev/null 2>&1; then
    echo "[pdf] 安装 Python3"
    brew install python3
  else
    echo "[pdf] 未检测到 Homebrew，请手动安装 Python3"
    NEED_MANUAL=1
  fi
fi

if command -v python3 >/dev/null 2>&1; then
  install_python_pkg "reportlab" "reportlab"
  install_python_pkg "pdfplumber" "pdfplumber"
  install_python_pkg "pypdf" "pypdf"
fi

echo "[pdf] 检查 PDF 渲染工具..."
if command -v pdftoppm >/dev/null 2>&1; then
  echo "[pdf] Poppler(pdftoppm) 已安装"
else
  echo "[pdf] 未检测到 Poppler，请手动安装: brew install poppler"
  NEED_MANUAL=1
fi

if [ "$NEED_MANUAL" -eq 1 ]; then
  exit 2
fi
