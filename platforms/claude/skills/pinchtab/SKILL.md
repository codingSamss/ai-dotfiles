---
name: "pinchtab"
description: "Use PinchTab for browser automation flows (tab/session operations, low-token snapshots). Prefer PinchTab first; fallback to `playwright-ext` when PinchTab is unavailable or blocked."
---

# PinchTab Skill

Use PinchTab as the primary browser control channel for multi-step interactive workflows. Keep `playwright-ext` as the final fallback path.

## When to Use This Skill

Triggered by:
- "pinchtab"
- "browser automation with low token usage"
- "multi-step website operation"
- "tab/session management"
- "agent browser control"

## Prerequisite Check

```bash
pinchtab --version
curl -fsS --max-time 3 http://127.0.0.1:9867/health
claude mcp list | rg "playwright-ext"
```

If you need to fetch installation assets from GitHub, use local proxy env:

```bash
HTTP_PROXY=http://127.0.0.1:7897 HTTPS_PROXY=http://127.0.0.1:7897 <download-command>
```

## Core Workflow

1. Verify PinchTab binary and health endpoint.
2. Execute browser workflow through PinchTab first.
3. If PinchTab fails due to unreachability/auth/capability limits, switch to `playwright-ext`.
4. In responses, explicitly mention fallback reason when switching channels.

## Fallback Rules (Mandatory)

Immediately fallback to `playwright-ext` when:
- PinchTab service is unreachable.
- PinchTab returns authentication/authorization errors.
- Required browser action is not supported in the current PinchTab flow.

Minimal fallback check:

```bash
claude mcp list | rg "playwright-ext"
```

## Guardrails

- Do not claim PinchTab succeeded when execution has already switched to `playwright-ext`.
- Keep action sequence explicit and auditable (navigate -> inspect -> interact -> verify).
- Follow user intent boundaries; do not perform unrelated side-effect operations.
