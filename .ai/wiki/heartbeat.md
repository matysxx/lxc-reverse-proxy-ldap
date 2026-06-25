# Heartbeat

Status: context snapshot and guideline compliance audit completed locally.

Owner: next agent working in `lxc-reverse-proxy-ldap`.

Blocked:

- LXC sync was not performed because current VPN routing makes the target host
  address ambiguous. Verify route and host identity before mutating the LXC.

Next actions:

1. Decide whether `.ai/wiki` should be committed to Git.
2. Decide whether to remove `.ai/prd/task-status.local.md` from Git tracking
   and add it to `.gitignore`.
3. When VPN is disconnected or routing is confirmed safe, verify `.ai` state on
   the target LXC and sync if needed.
