# Artifacts

## Primary Project Files

- `.ai/guidelines.md` — repository-scoped agent entry point
- `.ai/project/context.md` — project identity and scope boundaries
- `.ai/project/tech-spec.md` — stack and repository structure
- `.ai/project/environments.md` — local and LXC environment model
- `README.md` — operator-facing project overview
- `docs/deployment.md` — deployment procedure
- `docs/backup.md` — backup and restore
- `docs/logging.md` — log locations and rotation
- `docs/failover.md` — future failover options
- `docs/nextcloud.md` — Nextcloud/LDAP integration notes

## Host-Local Runtime Paths

These paths are referenced by documentation but should not be committed with
runtime content:

- `/etc/lxc-reverse-proxy-ldap/`
- `/etc/nginx/conf.d/`
- `/var/www/service-index/`
- `/var/backups/lxc-reverse-proxy-ldap/`
