# Environments

This document summarizes the environments relevant to this repository.

## Environment Matrix

| Environment | Purpose | Access | Path |
|-------------|---------|--------|------|
| local | authoring, validation, Git work | local filesystem | repository root |
| proxmox-lxc | target Debian 13 LXC deployment | shell access | `/opt/lxc-reverse-proxy-ldap` |

## Runtime Paths

Expected host-local paths on the target LXC:

- `/etc/lxc-reverse-proxy-ldap/env`
- `/etc/lxc-reverse-proxy-ldap/ssl/`
- `/etc/nginx/conf.d/`
- `/var/www/service-index/`
- `/var/backups/lxc-reverse-proxy-ldap/`

## Services on the Target LXC

- `slapd`
- `nginx`
- optional `apache2`

## Logging

Expected log locations on the target LXC:

- `/var/log/nginx/services/`
- `/var/log/nginx/access.log`
- `/var/log/nginx/error.log`
- `/var/log/lxc-reverse-proxy-ldap-backup.log`
- `journalctl -u slapd -u nginx -u apache2`

## Operational Notes

- The LXC uses `Europe/Warsaw` timezone.
- The LXC inherits clock synchronization behavior from the Proxmox host.
- Backup rotation is handled by repository scripts and a cron entry on the LXC.
- Backend hosts behind the reverse proxy are not part of the default change
  scope.
