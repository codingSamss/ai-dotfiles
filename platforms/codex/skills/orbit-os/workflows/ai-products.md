# AI 产品发布

抓取、去重、排序 AI 产品发布，生成每日摘要。

## 数据源（本地优先）

### 本地原子能力（优先）

| 源 | 用途 |
|----|------|
| `bird-twitter` | 捕捉新品发布、作者线程、早期口碑与传播热度 |
| `reddit` | 捕捉社区实测反馈、对比讨论、问题报告 |
| `linuxdo` | 捕捉中文社区真实使用场景与落地讨论 |

### 外部结构化源（补全）

| 源 | URL |
|----|-----|
| Product Hunt | `https://www.producthunt.com/feed` |
| Hacker News | `https://hn.algolia.com/api/v1/search?tags=show_hn&numericFilters=created_at_i>TIMESTAMP` |
| GitHub Trending | `https://mshibanami.github.io/GitHubTrendingRSS/daily/python.xml` |
| Techmeme | `https://techmeme.com/river` |

## 工作流

1. **检查缓存**: `50_资源/产品发布/YYYY-MM/YYYY-MM-DD-摘要.md`
2. **采集（按优先级）**:
   - 先用本地原子能力（`bird-twitter` / `reddit` / `linuxdo`）收集候选发布
   - 再用 Product Hunt / HN / GitHub Trending / Techmeme 补全
   - 抓取方式不强制单一工具，可用 WebFetch 或其他可用方式
   - 每条保留: `产品名`, `URL`, `描述`, `互动指标`, `source`
3. **过滤**: 仅保留 AI 相关（关键词: AI, ML, LLM, GPT, Claude, agent, model, inference, RAG, copilot）
4. **去重**: 跨源同产品合并（URL、产品名近似、主页域名匹配），保留最佳描述并聚合多源指标
5. **排序**: AI 相关性 > 互动量（归一化）> 本地可落地性 > 内容潜力 > 时效
6. **生成摘要**: 精选推荐 + LLM与AI模型 + 开发者工具 + 生产力与自动化 + 开源亮点
7. **保存**:
   - `50_资源/产品发布/YYYY-MM/YYYY-MM-DD-摘要.md`
   - `50_资源/产品发布/YYYY-MM/原始数据/` 下各源原始数据（含 Twitter/Reddit/LinuxDO，如有）

## 输出格式

**手动调用**: 完整摘要。

**来自 start-my-day**:
```
**产品发布机会 (5):**
- [产品名] - [内容角度] - [关键指标]
完整摘要: [[YYYY-MM-DD-摘要]]
```

## 内容角度逻辑
- 高互动 + 教程友好: "教程机会"
- 新颖 + 早期: "抢先报道优势"
- 开源 + 复杂: "深度分析"
- SaaS + 实用: "工具评测"
- 类似已有: "对比 vs [竞品]"

## 错误处理
- 单源不可用: 继续其他源并在摘要中注明
- 仅本地源可用: 继续输出并标注“外部结构化源缺失”
- <2 源可用: 回退到昨日存档
- 空结果: "今日无新AI产品"
