# Decisions

## Repository Boundary

Repository content must stay reusable and generic:

- templates
- scripts
- documentation
- examples with placeholders
- AI/project context

Host-local runtime configuration must stay outside Git.

## Runtime Configuration

Active vhost definitions, service maps, TLS material, LDAP secrets, and deployed
portal HTML belong on the target host outside the repository checkout.

## Backend Host Safety

Backend hosts behind the reverse proxy are out of scope unless the user gives
explicit approval for that host and task.

## Wiki Context

The repository uses `.ai/wiki` for compact context snapshots. It should not
become a transcript archive and must not contain secrets or full command output.
