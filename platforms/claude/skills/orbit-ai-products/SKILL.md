---
name: orbit-ai-products
description: "AI 产品发布追踪，多源抓取过滤排序生成每日摘要。Keywords: AI产品, products, 产品发布, Product Hunt, GitHub Trending, AI tools"
---
执行前先读取 `orbit-os/SKILL.md` 获取 Vault 结构和排版规范。

# AI 产品发布

抓取、去重、排序 AI 产品发布，生成每日摘要。

## 数据源

### RSS/API（主源）

| 源 | URL |
|----|-----|
| Product Hunt | `https://www.producthunt.com/feed` |
| Hacker News | `https://hn.algolia.com/api/v1/search?tags=show_hn&numericFilters=created_at_i>TIMESTAMP` |
| GitHub Trending | `https://mshibanami.github.io/GitHubTrendingRSS/daily/python.xml` |
| Techmeme | `https://techmeme.com/river` |

### 扩展源（通过已有 Skill 获取）

| 源 | 获取方式 | 用途 |
|----|---------|------|
| X/Twitter | `bird --cookie-source chrome search "AI launch OR AI tool OR new AI" -n 10 --plain` | 产品发布的社交热度 |
| Reddit | Composio MCP `REDDIT_SEARCH_ACROSS_SUBREDDITS` 搜索 r/LocalLLaMA, r/singularity | 开源项目和新工具讨论 |

## 工作流

1. **检查缓存**: `05_资源/产品发布/YYYY-MM/YYYY-MM-DD-摘要.md`
2. **抓取多源数据**:
   - WebFetch 获取 RSS/API 源，提取产品名、URL、描述、互动指标
   - 并行调用扩展源（任一失败则静默跳过，不阻塞流程）
3. **过滤**: 仅保留 AI 相关（关键词: AI, ML, LLM, GPT, Claude, agent, model）
4. **去重**: 跨源同产品合并，保留最佳描述
5. **排序**: AI 相关性 > 互动量（PH票/500, HN分/100, GH星/1000）> 内容潜力 > 时效
6. **生成摘要**: 精选推荐 + LLM与AI模型 + 开发者工具 + 生产力与自动化 + 开源亮点
7. **保存**:
   - `05_资源/产品发布/YYYY-MM/YYYY-MM-DD-摘要.md`
   - `05_资源/产品发布/YYYY-MM/原始数据/` 下各源原始数据

## 输出格式

**手动调用**: 完整摘要。

**来自其他 skill**:
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
- 单个主源不可用: 继续其他源
- 主源 <2 个可用: 回退到昨日存档
- 扩展源失败（认证过期、网络问题）: 静默跳过，仅用主源，摘要末尾注明
- 空结果: "今日无新AI产品"
