# Context Policy — Observer, Reflector, Heartbeat

## Purpose

Define how agents manage task context without letting local memory grow into another full transcript.

## Core Model

Use three lightweight mechanisms:

1. **Observer** — records important task events in `observations.md`
2. **Reflector** — periodically compresses observations into `summary.md` and `reflection.md`
3. **Heartbeat** — records the current execution checkpoint in `heartbeat.md`

The task wiki is not a chat log. It is a compact operational memory.

## Read Policy

Agents must read the smallest useful context set:

1. Always read `summary.md` first, if it exists.
2. Read `handoff.md` when continuing work from another role.
3. Read `heartbeat.md` when task execution order, blockers, or parallel work matter.
4. Read `decisions.md` before changing architecture, scope, or public behavior.
5. Read `artifacts.md` to locate source documents instead of duplicating them.
6. Read `reflection.md` when prior observations may affect the current decision.
7. Read `observations.md` only when the compressed context is insufficient.
8. Do not read `archive/` unless explicitly needed.

## Write Policy

Agents should write only durable, useful context:

- Record important events in `observations.md`
- Update `summary.md` after completing a meaningful phase
- Update `handoff.md` before switching roles or stopping work
- Update `heartbeat.md` when status, blocker, owner, or next action changes
- Move stale details to `archive/` instead of expanding the active context

Do not store raw transcripts, full command output, large diffs, secrets, credentials, or sensitive data.

## Compression Policy

Run reflection when any of these conditions is true:

- `summary.md` exceeds 150 lines
- `observations.md` exceeds 200 lines
- A role finishes a major phase
- A handoff occurs between roles
- The current context contains obsolete details that could confuse the next agent

Reflection means:

1. Review recent observations and handoff notes.
2. Keep durable facts, decisions, blockers, and next actions.
3. Remove stale details from active files.
4. Move historical detail to `archive/` only when it may be useful later.
5. Rewrite `summary.md` so the next agent can start from it directly.

## Sealing Policy

When observations have been reflected into `summary.md` or `reflection.md`, treat the old details as sealed:

- Do not keep re-reading sealed details by default.
- Do not copy sealed details back into `summary.md` unless they become relevant again.
- Preserve only references or short notes needed for traceability.

## Heartbeat Policy

`heartbeat.md` is the task checkpoint. It should answer:

- What is the current status?
- Who or which role owns the next action?
- What is blocked?
- Which dependencies must finish first?
- What can run in parallel?
- What is the next concrete step?

Keep it short and update it more often than `summary.md`.

