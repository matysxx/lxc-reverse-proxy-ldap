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

## Notes

- This repository vendors both repository-local project context and portable AI
  workflow content under `.ai/`.
- `.ai/guidelines.md` and `.ai/project/*.md` are the repository-local source of
  truth for project context.
- Global agent bootstrap may still exist in the parent workspace, but it should
  not override repository-specific facts.
