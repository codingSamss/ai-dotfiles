---
name: video-transcribe
description: "Video/audio transcription and summary. Download video from any URL (Twitter, YouTube, Bilibili, etc.), transcribe speech to text, and summarize content. Keywords: video, transcribe, 转录, 视频, 音频, audio, subtitle, 字幕, summary, 总结, 视频内容, whisper, groq, yt-dlp"
---

# Video Transcribe Skill

从任意视频/音频链接提取语音内容，转录为文本并总结。支持 Twitter/X、YouTube、Bilibili 等 1000+ 站点。

## 触发条件

当用户提到以下内容时触发：
- "这个视频说了什么"、"帮我看看这个视频"、"视频内容"、"转录"
- "transcribe this video"、"what does this video say"
- 分享了包含视频的链接并希望了解内容
- "总结这个视频"、"视频摘要"
- "提取字幕"、"语音转文字"

## 前置条件

1. **yt-dlp** 已安装: `brew install yt-dlp`
2. **ffmpeg** 已安装: `brew install ffmpeg`
3. **GROQ_API_KEY** 环境变量已设置（在 `~/.zshrc` 或 `~/.bashrc` 中 export）
   - 申请地址: https://console.groq.com

## 工作目录

所有临时文件保存到: `/tmp/video-transcribe/`

处理完成后自动清理中间文件，仅保留最终转录文本。

## 执行流程

收到视频链接后，按以下步骤执行：

### Step 1: 下载音频

从视频 URL 提取音频，使用 Chrome cookies 处理需要登录的站点：

```bash
mkdir -p /tmp/video-transcribe
yt-dlp --cookies-from-browser chrome \
  -x --audio-format mp3 --audio-quality 5 \
  -o '/tmp/video-transcribe/%(title)s.%(ext)s' \
  '$URL'
```

**参数说明：**
- `-x --audio-format mp3` - 只提取音频转 MP3
- `--audio-quality 5` - 中等质量（语音转录足够，减小体积）
- `--cookies-from-browser chrome` - 使用 Chrome cookies（处理 Twitter 等需登录站点）

**错误处理：**
- 如果 cookies 失败，尝试去掉 `--cookies-from-browser chrome`
- 如果站点不支持，告知用户 yt-dlp 不支持该站点
- 如果 YouTube 报 `No video formats found` / `SABR` 错误，提示用户更新 yt-dlp: `brew upgrade yt-dlp`
- 如果下载超时或文件过大，可加 `--max-filesize 500M` 限制

### Step 2: 检查文件大小并处理

Groq API 单文件限制 25MB。检查下载的音频大小：

```bash
FILE_SIZE=$(stat -f%z '/tmp/video-transcribe/INPUT.mp3')
```

**若文件 <= 24MB：** 直接进入 Step 3。

**若文件 > 24MB：** 用 ffmpeg 按 20 分钟切分：

```bash
ffmpeg -i '/tmp/video-transcribe/INPUT.mp3' \
  -f segment -segment_time 1200 -c copy \
  '/tmp/video-transcribe/segment_%03d.mp3' -y
```

### Step 3: 调用 Groq Whisper API 转录

使用 Groq 的 whisper-large-v3 模型转录：

**单文件转录：**

```bash
curl -s -X POST \
  https://api.groq.com/openai/v1/audio/transcriptions \
  -H "Authorization: Bearer $GROQ_API_KEY" \
  -F "file=@/tmp/video-transcribe/INPUT.mp3" \
  -F "model=whisper-large-v3" \
  -F "response_format=text" \
  -F "language=zh" \
  -o '/tmp/video-transcribe/transcript.txt'
```

**多段文件转录（切分后）：**

对每个 segment 文件依次调用 API，将结果追加到同一个文件：

```bash
> /tmp/video-transcribe/transcript.txt
for f in /tmp/video-transcribe/segment_*.mp3; do
  curl -s -X POST \
    https://api.groq.com/openai/v1/audio/transcriptions \
    -H "Authorization: Bearer $GROQ_API_KEY" \
    -F "file=@$f" \
    -F "model=whisper-large-v3" \
    -F "response_format=text" \
    >> '/tmp/video-transcribe/transcript.txt'
  echo "" >> '/tmp/video-transcribe/transcript.txt'
done
```

**参数说明：**
- `model=whisper-large-v3` - 最高精度模型
- `response_format=text` - 返回纯文本
- `language=zh` - 指定中文。如果音频主要是英文用 `en`，不确定语言时省略此参数让模型自动检测

**错误处理：**
- 401 错误：GROQ_API_KEY 无效或过期，提示用户检查
- 413 错误：文件过大，需要切分处理
- 429 错误：速率限制，等待几秒后重试

### Step 4: 读取并总结

```bash
cat /tmp/video-transcribe/transcript.txt
```

读取转录文本后：
1. 先向用户展示视频基本信息（标题、时长、语言）
2. 提供结构化总结：
   - **核心主题** - 一句话概括
   - **关键要点** - 3-5 个要点
   - **详细内容** - 按话题/章节组织的详细摘要
   - **值得关注** - 有价值的观点、数据、资源链接等

### Step 5: 清理临时文件

转录和总结完成后，清理中间文件：

```bash
# 保留转录文本，删除音频文件
rm -f /tmp/video-transcribe/*.mp3
```

如果用户不再需要转录文本：
```bash
rm -rf /tmp/video-transcribe/
```

## 支持的站点（部分）

yt-dlp 支持 1000+ 站点，常用的包括：
- Twitter/X
- YouTube
- Bilibili（哔哩哔哩）
- Vimeo
- TikTok / 抖音
- 微博视频
- 播客平台（Apple Podcasts、Spotify 等）

完整列表: `yt-dlp --list-extractors`

## 本地模式（备选）

如果无网络或不想使用在线 API，可以使用本地 whisper-cpp 转录：

1. 安装: `brew install whisper-cpp`
2. 下载模型: `curl -L https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-small.bin -o ~/.cache/whisper-cpp/ggml-small.bin`
3. 转码为 WAV: `ffmpeg -i INPUT.mp3 -ar 16000 -ac 1 -c:a pcm_s16le audio.wav -y`
4. 转录: `whisper-cli -m ~/.cache/whisper-cpp/ggml-small.bin -f audio.wav -l auto --no-timestamps -otxt -of transcript`

本地模型精度低于 Groq whisper-large-v3，适合离线或隐私敏感场景。

## 注意事项

- 转录通过 Groq API 处理，音频会上传到 Groq 服务器
- 音频质量直接影响转录精度，背景噪音较大时精度会下降
- 非语音内容（纯音乐、音效）无法转录
- 多语言混合内容可能需要指定主要语言（`language=zh` 或 `language=en`）
- Groq 免费额度充足，日常使用无需担心费用