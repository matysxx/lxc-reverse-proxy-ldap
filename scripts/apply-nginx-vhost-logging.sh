#!/usr/bin/env bash

set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run this script as root." >&2
  exit 1
fi

# shellcheck source=./common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

if [[ -f "${ENV_FILE}" ]]; then
  # shellcheck disable=SC1090
  source "${ENV_FILE}"
fi

NGINX_SERVICE_LOG_DIR="${NGINX_SERVICE_LOG_DIR:-/var/log/nginx/services}"
install -d -m 0755 "${NGINX_SERVICE_LOG_DIR}"

python3 - "$NGINX_SERVICE_LOG_DIR" <<'PY'
from pathlib import Path
import sys

log_dir = sys.argv[1]

for conf in sorted(Path("/etc/nginx/conf.d").glob("*.conf")):
    name = conf.stem
    access = f"  access_log {log_dir}/{name}.access.log;"
    error = f"  error_log {log_dir}/{name}.error.log warn;"
    lines = conf.read_text().splitlines()
    out = []
    server_depth = 0
    inserted = False

    for line in lines:
      stripped = line.strip()
      if stripped.startswith("server {"):
        server_depth += 1
        inserted = False
        out.append(line)
        continue

      if server_depth > 0 and stripped.startswith("server_name ") and not inserted:
        out.append(line)
        out.append(access)
        out.append(error)
        inserted = True
        continue

      if server_depth > 0 and (stripped.startswith("access_log ") or stripped.startswith("error_log ")):
        continue

      out.append(line)

      if "}" in stripped and server_depth > 0:
        server_depth -= stripped.count("}")

    conf.write_text("\n".join(out) + "\n")
PY

nginx -t
systemctl reload nginx

echo "Per-vhost nginx logging applied."
