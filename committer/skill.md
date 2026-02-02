---
name: committer
description: "安全的git提交辅助。指定文件提交、输入验证、防止意外全量提交。关键词: commit, 提交, git commit, 安全提交"
---

# Committer 安全提交 Skill

安全地进行git提交，只提交指定文件，防止意外提交整个仓库。

## 触发条件

- 用户要求提交代码时
- 用户说"commit"、"提交"等关键词时
- 完成代码修改后需要提交时

## 使用方式

### 基本用法
```bash
~/.claude/scripts/committer "commit message" "file1" "file2"
```

### 带force参数（清理stale lock）
```bash
~/.claude/scripts/committer --force "commit message" "file1"
```

## 安全特性

- 只stage指定文件，不会意外提交整个仓库
- 阻止使用"."作为参数
- 验证commit message非空
- 验证文件存在或在git历史中
- 检测参数顺序错误
- 支持已删除文件的提交

## 使用原则

1. 提交前先用 `git status` 确认状态
2. commit message遵循 Conventional Commits 格式
3. 明确列出要提交的文件，不要用通配符
4. 提交后确认结果

## 示例

```bash
# 提交单个文件
~/.claude/scripts/committer "feat: 添加用户登录功能" "src/login.java"

# 提交多个文件
~/.claude/scripts/committer "fix: 修复空指针异常" "src/User.java" "src/UserService.java"

# 提交删除的文件
~/.claude/scripts/committer "chore: 移除废弃代码" "src/deprecated.java"
```