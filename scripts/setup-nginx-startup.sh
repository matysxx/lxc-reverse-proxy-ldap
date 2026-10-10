#!/usr/bin/env bash

set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run this script as root." >&2
  exit 1
fi

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
install -d -m 0755 /etc/systemd/system/nginx.service.d
install -m 0644 "${root_dir}/config/nginx/systemd-retry.conf" \
  /etc/systemd/system/nginx.service.d/retry.conf
systemctl daemon-reload
