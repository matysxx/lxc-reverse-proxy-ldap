# Compliance Audit

Date: 2026-06-26

Scope: repository `lxc-reverse-proxy-ldap`, checked against repository-local
`.ai/guidelines.md` and `.ai/project/*.md`.

## Checks Performed

- Read repository-local AI entrypoint and project context files.
- Checked tracked files for private RFC1918 addresses.
- Checked tracked files for secret/private-key indicators.
- Checked working tree for certificate/key/env file extensions.
- Checked Git tracking status for the local task status tracker.

## Results

### Passed

- Repository has `.ai/guidelines.md`.
- Repository has `.ai/project/context.md`, `.ai/project/tech-spec.md`, and
  `.ai/project/environments.md`.
- No tracked private IP addresses were found during the scan.
- No certificate/private-key files were found in the working tree scan.
- Secret keyword scan found placeholders, variable names, and documented
  host-local paths, not actual secret values.
- Documentation consistently states that runtime config belongs outside Git.

### Findings

1. `.ai/prd/task-status.local.md` is tracked by Git.

   Impact: this conflicts with the file's local-only purpose and can lead to
   accidental publication of operational notes.

   Recommended fix: add `.ai/prd/task-status.local.md` to `.gitignore` and
   remove it from Git tracking with `git rm --cached`, after approval.

2. `.ai/wiki` did not exist in the repository before this task.

   Impact: the new context policy had no repository-local place to store compact
   wiki snapshots.

   Status: `.ai/wiki` has been created locally.

3. LXC verification was not completed.

   Impact: unable to confirm whether the new wiki/guideline state exists on the
   target LXC.

   Reason: current VPN routing sends the target address through a VPN interface,
   which makes host identity ambiguous. LXC mutation was intentionally stopped.

## Overall Status

Partially compliant.

The repository structure and tracked content are mostly aligned with the
guidelines. The main fix needed is to stop tracking the local task status file
or explicitly reclassify it as a committed project artifact.
