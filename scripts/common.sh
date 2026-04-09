#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOST_CONFIG_DIR="${HOST_CONFIG_DIR:-/etc/lxc-reverse-proxy-ldap}"
RUNTIME_DIR="${ROOT_DIR}/runtime"

if [[ -f "${HOST_CONFIG_DIR}/env" ]]; then
  ENV_FILE="${HOST_CONFIG_DIR}/env"
  TLS_CERT_SOURCE="${HOST_CONFIG_DIR}/ssl/tls.crt"
  TLS_KEY_SOURCE="${HOST_CONFIG_DIR}/ssl/tls.key"
else
  ENV_FILE="${ROOT_DIR}/.env"
  TLS_CERT_SOURCE="${ROOT_DIR}/config/nginx/ssl/tls.crt"
  TLS_KEY_SOURCE="${ROOT_DIR}/config/nginx/ssl/tls.key"
fi
