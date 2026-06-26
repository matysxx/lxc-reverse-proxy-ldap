# AI Agent Guidelines

This file is the repository-scoped entry point for AI agents working on
`lxc-reverse-proxy-ldap`.

## Before Any Task

Read these files first:

1. `project/context.md`
2. `project/tech-spec.md`
3. `project/environments.md`

## Current Project State

- This repository is initialized and published on GitHub.
- The repository stores only reusable templates, scripts, and documentation.
- Runtime addresses, private hostnames, secrets, certificates, and service maps
  must remain outside Git-tracked files.

## Project Rules

- Keep project-specific knowledge only in `.ai/project/`.
- Do not store host-local configuration in repository templates.
- Do not modify backend hosts outside the LXC without explicit approval.
- Treat the target Debian 13 LXC as the default operational scope.
- Keep repository content generic and reusable.

## Task Wiki / Local Context

Use `.ai/wiki/tasks/{TASK_KEY}/` as the local task context layer for handoff,
continuation, observations, and current execution state.

When a task key is known, read the smallest useful context set before changing
files:

1. `.ai/wiki/tasks/{TASK_KEY}/summary.md`
2. `.ai/wiki/tasks/{TASK_KEY}/heartbeat.md`
3. `.ai/wiki/tasks/{TASK_KEY}/handoff.md`

During work, record durable observations in:

- `.ai/wiki/tasks/{TASK_KEY}/observations.md`

Update these files when status, blockers, next owner, or handoff state changes:

- `.ai/wiki/tasks/{TASK_KEY}/heartbeat.md`
- `.ai/wiki/tasks/{TASK_KEY}/handoff.md`

After a meaningful phase or when context grows too large, compress the current
state into:

- `.ai/wiki/tasks/{TASK_KEY}/summary.md`
- `.ai/wiki/tasks/{TASK_KEY}/reflection.md`

Repository rule:

- GitHub contains procedures, policies, reusable templates, and anonymized
  project context only.
- `.ai/wiki/tasks/**` is local operational memory and must not be committed.
- Do not commit private IPs, customer-specific names, secrets, certificates,
  logs, raw command output, service maps, or host-local deployment details.

## Notes

- This repository vendors both repository-local project context and portable AI
  workflow content under `.ai/`.
- `.ai/guidelines.md` and `.ai/project/*.md` are the repository-local source of
  truth for project context.
- Global agent bootstrap may still exist in the parent workspace, but it should
  not override repository-specific facts.
