# Context Summary

Last updated: 2026-06-26

## Project

`lxc-reverse-proxy-ldap` is a reusable Debian 13 Proxmox LXC blueprint for:

- OpenLDAP
- nginx reverse proxy
- optional phpLDAPadmin
- static service portal templates
- host-local backup, restore, and logging helpers

The repository must remain generic. Runtime addresses, customer-specific service
maps, host-local vhost files, certificates, private keys, and secrets belong
outside Git.

## Operational Model

- Repository checkout on the target LXC is expected at `/opt/lxc-reverse-proxy-ldap`.
- Active host configuration is expected outside the checkout, mainly under:
  - `/etc/lxc-reverse-proxy-ldap/`
  - `/etc/nginx/conf.d/`
  - `/var/www/service-index/`
  - `/var/backups/lxc-reverse-proxy-ldap/`
- Backend hosts behind the reverse proxy are outside the default change scope.
- Changes on backend hosts require explicit approval.

## Current Important Context

- `.ai/guidelines.md` is the repository-scoped entry point for agents.
- `.ai/project/context.md`, `.ai/project/tech-spec.md`, and
  `.ai/project/environments.md` are the project source of truth.
- The parent workspace contains a wiki context policy using:
  `summary.md`, `observations.md`, `heartbeat.md`, `decisions.md`,
  `artifacts.md`, and `reflection.md`.
- This repository did not previously contain `.ai/wiki`; it has now been added
  for compact operational context snapshots.

## Current Risks

- `.ai/prd/task-status.local.md` is currently tracked by Git even though it is
  described as a local-only task tracker.
- Active VPN routing can make the target LXC address ambiguous. Do not sync or
  mutate the LXC while the route to the LXC goes through a VPN interface unless
  the host identity is explicitly verified.
