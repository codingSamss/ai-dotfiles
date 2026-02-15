# doc

## 作用
用于读取、创建和编辑 `.docx` 文档，强调版式与渲染一致性。

## 平台支持
- Codex（已支持）

## 工作原理
Skill 通过 `python-docx` 做结构化处理，并结合 `render_docx.py` + `poppler` 做可视化渲染校验。

## 配置命令

```bash
platforms/codex/skills/doc/setup.sh
```

## 配置脚本行为

- 退出码：`0` 自动完成，`2` 需手动补齐，`1` 执行失败
- 自动检查项：
  - Python3
  - Python 包：`python-docx`、`pdf2image`
  - 渲染工具：`soffice`（LibreOffice）、`pdftoppm`（Poppler）
- 需手动补齐项：
  - 没有 Homebrew 且缺少系统依赖
  - pip 安装受限或网络不可用

## 验证命令

```bash
python3 -c "import docx, pdf2image"
python3 platforms/codex/skills/doc/scripts/render_docx.py --help
```

## 依赖
- Python3
- python-docx
- pdf2image
- LibreOffice
- Poppler

