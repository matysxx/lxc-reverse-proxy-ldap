# Manager — Task and Code Management

## Purpose

Entry point for the manager role. Coordinates task lifecycle, commit discipline, branching strategy, and issue tracker integration.

## Prerequisites

- `project/context.md` — project key, issue tracker type, repository host, commit format, MCP availability
- `project/tech-spec.md` — QA tools, test runner

## Procedures

| File | When to use |
|------|-------------|
| `create-task.md` | Creating a new task from scratch (branch, directory, index entry) |
| `create-task-from-ticket.md` | Starting work on an existing issue tracker ticket |
| `close-task.md` | Closing a task (QA, commit, status, PR) |
| `conventional-commits.md` | Commit message format — Conventional Commits standard (`feat:`, `fix:`, etc.) |
| `custom-commits.md` | Commit message format — ticket-prefixed with bulleted body |
| `pr-description.md` | Generating a PR description for a task |
| `update-ticket.md` | Adding comments or changing status on an issue tracker ticket |

## Git Workflow

### Branching Strategy

```
main (production-ready)
  +-- feature/{PROJECT_KEY}-N-description
  +-- fix/{PROJECT_KEY}-N-bug-description
  +-- refactor/description
  +-- hotfix/description
```

> Get `{PROJECT_KEY}` from `project/context.md`.

### Branch Naming

| Type | Pattern | Example |
|------|---------|---------|
| Feature | `feature/{KEY}-N-description` | `feature/PROJ-123-user-auth` |
| Bug Fix | `fix/{KEY}-N-description` | `fix/PROJ-456-cache-bug` |
| Refactor | `refactor/description` | `refactor/service-extraction` |
| Hotfix | `hotfix/description` | `hotfix/auth-token-expiry` |

### Merging

- Squash merge for clean history
- Delete branch after merge

## Status Tracking

Task statuses are tracked in `prd/task-status.local.md` (gitignored, local only).

- Allowed statuses: `Planned`, `In Progress`, `Done`
- `In Progress` — branch and requirements exist
- `Done` — commit created, acceptance criteria fulfilled
- Scope change — record in the task's requirements document

## Files in this Directory

| File | Description |
|------|-------------|
| `manager.md` | This index file |
| `create-task.md` | Procedure for creating a new task from scratch |
| `create-task-from-ticket.md` | Procedure for starting work from an issue tracker ticket |
| `close-task.md` | Procedure for closing a task |
| `conventional-commits.md` | Commit format — Conventional Commits standard |
| `custom-commits.md` | Commit format — ticket-prefixed with bulleted body |
| `pr-description.md` | Procedure for generating PR descriptions |
| `update-ticket.md` | Procedure for updating issue tracker tickets |
