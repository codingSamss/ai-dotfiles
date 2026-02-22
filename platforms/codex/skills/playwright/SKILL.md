---
name: "playwright"
description: "Use when the task requires automating a real browser. This skill is MCP-only and uses `playwright-ext` (`@playwright/mcp --extension`) to attach to the browser extension session."
---


# Playwright MCP Skill

Use a single channel only:
- Always use `playwright-ext` MCP.
- Do not use `playwright-cli` wrapper in this skill.
- Do not pivot to `@playwright/test` unless the user explicitly asks for test files.

## Prerequisite check (required)

Before proposing browser actions, verify MCP and runtime dependency:

```bash
codex mcp get playwright-ext
command -v npx >/dev/null 2>&1
```

If `playwright-ext` is missing, configure it with extension token:

```bash
codex mcp add playwright-ext \
  --env PLAYWRIGHT_MCP_EXTENSION_TOKEN=<token> \
  -- npx @playwright/mcp@latest --extension
```

If `npx` is missing, ask the user to install Node.js/npm:

```bash
node --version
npm --version
brew install node
```

## Core workflow

1. Open the page.
2. Snapshot to get stable element refs.
3. Interact using refs from the latest snapshot.
4. Re-snapshot after navigation or significant DOM changes.
5. Capture artifacts (screenshot, pdf, traces) when useful.

## When to snapshot again

Snapshot again after:

- navigation
- clicking elements that change the UI substantially
- opening/closing modals or menus
- tab switches

Refs can go stale. When a command fails due to a missing ref, snapshot again.

## Guardrails

- Always snapshot before referencing element ids like `e12`.
- Re-snapshot when refs seem stale.
- Prefer explicit commands over `eval` and `run-code` unless needed.
- When you do not have a fresh snapshot, use placeholder refs like `eX` and say why; do not bypass refs with `run-code`.
- Use `--headed` when a visual check will help.
- When capturing artifacts in this repo, use `output/playwright/` and avoid introducing new top-level artifact folders.
- Default to MCP actions and workflows, not Playwright test specs.
