# Observations

## 2026-06-26

- Repository-local `.ai/guidelines.md` exists and defines repository-specific
  rules for `lxc-reverse-proxy-ldap`.
- Repository-local `.ai/project/*.md` files exist and contain project context,
  technical baseline, and environment assumptions.
- Parent workspace contains `.ai/wiki/context-policy.md`; repository did not
  have a `.ai/wiki` directory before this snapshot.
- Git-tracked file scan found no private RFC1918 addresses in tracked files.
- File scan found no certificate/private-key material in the working tree.
- Secret-keyword scan found only placeholders, documented secret paths, and
  script variable names; no actual secret values were identified.
- `.ai/prd/task-status.local.md` is tracked by Git, which conflicts with the
  local-only intent described in that file.
- Active VPN can change routing to the LXC address through a VPN interface;
  avoid LXC mutation until the route and host identity are safe.
