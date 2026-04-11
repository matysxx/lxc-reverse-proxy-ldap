# Technical Specification

This document records the current technical baseline for the repository.

## Stack

- Target OS: Debian 13 on Proxmox LXC
- Directory service: OpenLDAP (`slapd`, `ldap-utils`)
- Reverse proxy: nginx
- Optional admin UI: phpLDAPadmin with Apache
- Backup: archive-based host-local backup and restore scripts
- Logging: nginx per-vhost logs, Debian logrotate, journald for system services

## Repository Structure

```text
.
├── .ai/
│   ├── guidelines.md
│   └── project/
├── config/
├── docs/
├── proxmox/
├── runtime/
├── scripts/
└── templates/
```

## Deployment Model

- The repository checkout is intended to live at `/opt/lxc-reverse-proxy-ldap`
  on the target LXC.
- Active runtime configuration is expected outside Git, for example:
  - `/etc/lxc-reverse-proxy-ldap/`
  - `/etc/nginx/conf.d/`
  - `/var/www/service-index/`
- Certificates are staged locally and deployed outside the repository checkout.

## Validation and Operations

Current validation methods:

- shell syntax checks via `bash -n`
- `nginx -t` on the target LXC
- manual service verification on the target LXC
- Git sync verification between local checkout, GitHub, and deployed checkout

Current operational features in the repository:

- bootstrap/install scripts
- render and environment validation scripts
- backup and restore scripts
- per-vhost logging setup
- static service-index template

## Constraints

- Repository templates must stay generic.
- Runtime hostnames and service bindings belong only to deployed host-local
  configuration.
- The repository should remain usable as a clean scaffold for another LXC.
