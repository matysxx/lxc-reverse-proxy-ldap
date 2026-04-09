#!/usr/bin/env bash

set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run this script as root." >&2
  exit 1
fi

# shellcheck source=./common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

cd "${ROOT_DIR}"
systemctl stop nginx
if systemctl list-unit-files apache2.service >/dev/null 2>&1; then
  systemctl stop apache2
fi
systemctl stop slapd
