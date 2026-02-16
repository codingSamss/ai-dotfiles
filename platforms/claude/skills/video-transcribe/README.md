# video-transcribe

## 作用
从任意视频/音频链接提取语音内容，使用 Groq Whisper API 转录为文本并总结。支持 Twitter/X、YouTube、Bilibili 等 1000+ 站点。

## 平台支持
- Claude Code（已支持）
- Codex（已支持）

## 工作原理
1. 使用 yt-dlp 下载视频音频轨
2. 调用 Groq Whisper API（whisper-large-v3）在线转录
3. 对超过 25MB 的音频自动切分后逐段转录
4. 输出结构化总结

默认使用 Groq API（在线模式），也支持本地 whisper-cpp 作为备选（离线/隐私场景）。

## 配置命令

```bash
# 默认在线模式（Groq API）
./setup.sh video-transcribe

# 本地模式
TRANSCRIBE_MODE=local ./setup.sh video-transcribe
```

## 配置脚本行为

- 退出码：`0` 自动完成，`2` 需手动补齐，`1` 执行失败
- 模式选择：通过 `TRANSCRIBE_MODE` 环境变量控制，默认 `groq`

### Groq 模式（默认）
- 自动检查项：yt-dlp、ffmpeg、`GROQ_API_KEY` 环境变量、Groq API 连通性
- 需手动补齐项：
  - 未设置 `GROQ_API_KEY` 时提示申请
  - 直连 Groq 返回 `403` 且仅代理可通时，需配置代理环境变量

### Local 模式
- 自动检查项：yt-dlp、ffmpeg、whisper-cpp、Whisper 模型文件
- 自动处理：缺少模型时自动下载 small 模型（~465MB）

## 验证命令

```bash
# 检查 Groq API 连通性
curl -s https://api.groq.com/openai/v1/models \
  -H "Authorization: Bearer $GROQ_API_KEY" | head -1

# 如直连返回 403，可改走本地 7897 代理
HTTP_PROXY=http://127.0.0.1:7897 HTTPS_PROXY=http://127.0.0.1:7897 \
  curl -s https://api.groq.com/openai/v1/models \
  -H "Authorization: Bearer $GROQ_API_KEY" | head -1
```

## 使用方式
- 触发词：`转录`、`视频内容`、`transcribe`、`这个视频说了什么`
- 详细命令与触发规则见：`SKILL.md`

## 依赖
- yt-dlp（`brew install yt-dlp`）
- ffmpeg（`brew install ffmpeg`）
- Groq API Key（https://console.groq.com）
- （本地模式）whisper-cpp（`brew install whisper-cpp`）
