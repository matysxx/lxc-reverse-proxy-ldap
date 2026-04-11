# Project Context

This document captures the current known context for
`lxc-reverse-proxy-ldap`.

## Business Overview

The repository provides a reusable blueprint for a Debian 13 Proxmox LXC that
combines:

- native OpenLDAP
- nginx as reverse proxy
- optional phpLDAPadmin
- host-local portal, backup, restore, and logging helpers

The repository is meant to stay generic. Environment-specific runtime state is
applied only on the target LXC.

## Project Identifiers

- **Project key:** `WIR`
- **Repository:** `matysxx/lxc-reverse-proxy-ldap`
- **Default branch:** `main`

## Scope Boundaries

- In-scope by default: repository files and the target LXC deployment
- Out of scope by default: backend hosts behind the reverse proxy
- Any changes on non-LXC backend hosts require explicit approval

## Sources of Truth

- repository files in `config/`, `scripts/`, `templates/`, and `docs/`
- repository-local `.ai/project/*.md`
- live verification on the target LXC

## Working Assumptions

- Public Git history must not contain runtime service maps, private IP
  addresses, private hostnames, secrets, or certificates.
- Host-local configuration lives outside the repository checkout.
- Reverse proxy vhost definitions on the deployed LXC are operational data, not
  repository templates.
