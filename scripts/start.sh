#!/usr/bin/env bash

set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run this script as root." >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

"${ROOT_DIR}/scripts/check-env.sh"
"${ROOT_DIR}/scripts/render-config.sh"

cd "${ROOT_DIR}"
nginx -t
systemctl restart slapd
if systemctl list-unit-files apache2.service >/dev/null 2>&1; then
  systemctl restart apache2
fi
systemctl restart nginx
