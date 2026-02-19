# AI 新闻简报

抓取、去重、排序 AI 新闻内容，生成每日摘要。

## 数据源（本地优先）

### 本地原子能力（优先）

- `bird-twitter`: AI 相关趋势、列表、书签、关键词搜索
- `reddit`: `r/artificial`、`r/MachineLearning`、`r/LocalLLaMA` 等社区动态
- `linuxdo`: AI/工具相关最新、热门、讨论帖

### RSS 源（补全）

- **TLDR AI**: `https://bullrich.dev/tldr-rss/ai.rss`
- **The Rundown AI**: `https://rss.beehiiv.com/feeds/2R3C6Bt5wj.xml`

## 工作流

1. **检查缓存**: 查找 `50_资源/Newsletters/YYYY-MM/YYYY-MM-DD-摘要.md`，存在则返回缓存
2. **采集（按优先级）**:
   - 先用本地原子能力（`bird-twitter` / `reddit` / `linuxdo`）收集候选条目
   - 再用 RSS 源补全（可用 WebFetch 或其他可用抓取方式）
   - 每条保留: `title`, `link`, `pubDate`, `description`, `source`
3. **去重**: URL 相同直接合并；标题 80%+ 词重叠合并，保留描述更完整者
4. **排序**: AI 相关性 > 可执行内容机会 > 时效性 > 来源多样性 > 新颖性
5. **生成摘要**: 精选推荐 (3-5条，含内容角度) + AI动态 + 生产力工具 + 统计 + 来源覆盖说明
6. **保存**:
   - `50_资源/Newsletters/YYYY-MM/YYYY-MM-DD-摘要.md`
   - `50_资源/Newsletters/YYYY-MM/原始数据/YYYY-MM-DD_Twitter-Raw.md`（如有）
   - `50_资源/Newsletters/YYYY-MM/原始数据/YYYY-MM-DD_Reddit-Raw.md`（如有）
   - `50_资源/Newsletters/YYYY-MM/原始数据/YYYY-MM-DD_LinuxDO-Raw.md`（如有）
   - `50_资源/Newsletters/YYYY-MM/原始数据/YYYY-MM-DD_TLDR-AI-Raw.md`（如有）
   - `50_资源/Newsletters/YYYY-MM/原始数据/YYYY-MM-DD_Rundown-AI-Raw.md`（如有）

## 输出格式

**手动调用**: 显示完整摘要。

**来自 start-my-day**: 返回精简列表:
```
**内容机会 (5):**
- [标题] - [角度]
完整摘要: [[YYYY-MM-DD-摘要]]
```

## 错误处理
- 单个本地源不可用: 跳过该源，继续其他源并注明
- RSS 不可用: 继续使用本地源并注明
- 本地与 RSS 均不可用: 使用昨日存档并警告
- 空结果: 创建最小摘要注明"今日无新内容"
