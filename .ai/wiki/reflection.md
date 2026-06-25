# Reflection

The useful durable context is the repository boundary: keep reusable templates
and documentation in Git, keep deployed runtime configuration outside Git, and
avoid backend-host changes without explicit approval.

The most important compliance gap is not a leaked secret, but process drift:
the file named `task-status.local.md` is tracked despite being intended as a
local-only tracker.

The most important operational risk during this snapshot was VPN route
ambiguity. When the target host address is reachable through a VPN interface,
do not assume it is the intended LXC without additional identity checks.
