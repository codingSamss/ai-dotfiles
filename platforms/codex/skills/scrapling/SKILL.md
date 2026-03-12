---
name: "scrapling"
description: "Use Scrapling for web extraction (HTTP, async, dynamic, stealth fetchers). Prefer Scrapling for scraping pipelines; fallback to `playwright-ext` when blocked."
---

# Scrapling Skill

Use Scrapling as the primary extraction layer for scraping and structured data retrieval. Keep `playwright-ext` as fallback for blocked or unsupported scenarios.

## When to Use This Skill

Triggered by:
- "scrape this site"
- "extract structured data from pages"
- "anti-bot scraping"
- "dynamic page extraction"
- "batch crawling pipeline"

## Prerequisite Check

```bash
python3 --version
python3 -c "from scrapling.fetchers import Fetcher, AsyncFetcher, DynamicFetcher, StealthyFetcher"
codex mcp get playwright-ext
```

If you need to fetch packages or sources from GitHub/PyPI, use local proxy env:

```bash
HTTP_PROXY=http://127.0.0.1:7897 HTTPS_PROXY=http://127.0.0.1:7897 <download-command>
```

## Core Workflow

1. Start with `Fetcher` / `AsyncFetcher` for standard HTTP extraction.
2. Escalate to `DynamicFetcher` / `StealthyFetcher` for JS-heavy or anti-bot pages.
3. When blocked by risk control/captcha/session wall, fallback to `playwright-ext`.
4. Report clearly which layer was used for final output.

## Fallback Rules (Mandatory)

Fallback to `playwright-ext` when:
- fetcher returns persistent anti-bot/captcha blocks.
- target requires interaction that Scrapling fetchers cannot complete reliably.
- credentialed browser state is required for final extraction.

Minimal fallback check:

```bash
codex mcp get playwright-ext
```

## Guardrails

- Prefer the lightest fetcher that can complete the task.
- Keep extraction reproducible (explicit URL/input and deterministic selectors where possible).
- Do not claim HTTP-only extraction when fallback browser automation was actually used.
