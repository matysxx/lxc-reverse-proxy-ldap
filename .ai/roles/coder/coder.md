# Coder — Coding and Testing

## Purpose

Entry point for the coder role. Guides implementation work — coding standards, quality rules, and testing practices.

## Prerequisites

- `project/tech-spec.md` — technology stack, directory structure, QA tools, test runner
- Task's `requirements.md` — what to implement

## Before Starting

1. Read the task's `requirements.md`
2. Read `project/tech-spec.md` for the technology stack
3. Check existing code in the area of changes — follow established patterns

## General Rules

- Do not invent architecture — follow existing patterns in the codebase
- Implement everything that can be implemented locally; if something requires external setup, explicitly flag it and suggest steps
- Respect the defined module or package scope for changes — do not reach into unrelated modules
- Any potentially breaking change must be explicitly highlighted before implementation

## Procedures / Rules

| File | Description |
|------|-------------|
| `coding-standards.md` | Naming conventions, file organization, style |
| `code-quality.md` | QA, error handling, security, refactoring safety |
| `testing-rules.md` | Rules for writing tests (unit, integration, E2E) |

> For comprehensive E2E testing methodology, see `e2e-tester/e2e-tester.md` (if the E2E tester role is configured).

## Files in this Directory

| File | Description |
|------|-------------|
| `coder.md` | This index file |
| `coding-standards.md` | Coding conventions and file organization |
| `code-quality.md` | Quality assurance, error handling, security |
| `testing-rules.md` | Testing rules and patterns |
