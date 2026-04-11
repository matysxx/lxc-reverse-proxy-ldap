# AI Agent Guidelines

This file is the single entry point for AI agents working on this project. Read it first, then follow references based on the task type.

## Before Any Task

Read these files to understand the project:

1. `project/context.md` — project identity, workflow tools, task management
2. `project/tech-spec.md` — technology stack, QA tools, project structure

## Role Selection

Determine the task type and read the corresponding role index:

| Task type | Role | Read |
|-----------|------|------|
| New feature or task | Full workflow | Follow "New Task" below |
| Continue existing task | Coder | `roles/coder/coder.md` |
| Bug investigation | Debugger | `roles/debugger/debugger.md` |
| Write or update E2E tests | E2E Tester | `roles/e2e-tester/e2e-tester.md` |
| Create commit | Manager | `roles/manager/commit-message.md` |
| Create PR description | Manager | `roles/manager/pr-description.md` |
| Set up or audit AI instructions | Meta | `meta/meta.md` |
| General conversation | — | No additional files needed |

## New Task Workflow

When starting a new task from scratch:

1. **Design phase** — Read `roles/designer/designer.md`
   - Gather requirements → create `prd/{TASK_KEY}/requirements.md`
   - Follow design principles from `roles/designer/design-principles.md`
2. **Planning phase** — Create implementation plan in `prd/{TASK_KEY}/implementation-plan.md`
3. **Implementation phase** — Read `roles/coder/coder.md`
   - Follow coding standards, testing rules, code quality guidelines
4. **Commit phase** — Read `roles/manager/commit-message.md`
   - Create task entry via `roles/manager/create-task.md`
   - Close task via `roles/manager/close-task.md`

## Task Continuation

When continuing work on an existing task:

1. Read the task requirements: `prd/{TASK_KEY}/requirements.md`
2. Read `roles/coder/coder.md` and referenced files
3. If the task has an implementation plan, follow it
4. After completion, follow commit and close-task procedures

## Environment Access

When debugging or verifying deployments, read:
- `project/environments.md` — access details, logs, services
- `roles/debugger/debugger.md` — debugging methodology

## Important Rules

- **Do not modify portable files** in `roles/` or `meta/` — they are shared across projects.
- **Project-specific content** goes in `project/` and `prd/` only.
- **Always ask before** making assumptions that could change scope.
- **Follow the tech-spec** — use the project's tools, not your defaults.
