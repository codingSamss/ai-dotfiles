# pdf

## 作用
用于 PDF 的生成、读取与版式检查，强调渲染结果可靠。

## 平台支持
- Codex（已支持）

## 工作原理
Skill 使用 Python 工具链（`reportlab`、`pdfplumber`、`pypdf`）处理内容，并结合 `pdftoppm` 做渲染校验。

## 配置命令

```bash
platforms/codex/skills/pdf/setup.sh
```

## 配置脚本行为

- 退出码：`0` 自动完成，`2` 需手动补齐，`1` 执行失败
- 自动检查项：
  - Python3
  - Python 包：`reportlab`、`pdfplumber`、`pypdf`
  - 渲染工具：`pdftoppm`（Poppler）
- 需手动补齐项：
  - 没有 Homebrew 且缺少 Python3
  - pip 安装受限或网络不可用
  - 未安装 Poppler

## 验证命令

```bash
python3 -c "import reportlab, pdfplumber, pypdf"
pdftoppm -h | head -n 1
```

## 依赖
- Python3
- reportlab
- pdfplumber
- pypdf
- Poppler
