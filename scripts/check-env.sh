#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${ROOT_DIR}/.env"

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Missing ${ENV_FILE}. Create it from .env.dist." >&2
  exit 1
fi

# shellcheck disable=SC1090
source "${ENV_FILE}"

required_vars=(
  LDAP_ORGANISATION
  LDAP_DOMAIN
  LDAP_BASE_DN
  LDAP_ADMIN_DN
  LDAP_ADMIN_PASSWORD
  LDAP_HOSTNAME
  LDAP_PHPLDAPADMIN_HOSTNAME
  LDAP_PHPLDAPADMIN_ENABLED
  LDAP_USERS_OU
  LDAP_GROUPS_OU
  PROXY_HTTP_PORT
  PROXY_HTTPS_PORT
)

for var_name in "${required_vars[@]}"; do
  if [[ -z "${!var_name:-}" ]]; then
    echo "Missing required variable: ${var_name}" >&2
    exit 1
  fi
done

if [[ ! -f "${ROOT_DIR}/config/nginx/ssl/tls.crt" ]]; then
  echo "Missing TLS certificate: config/nginx/ssl/tls.crt" >&2
  exit 1
fi

if [[ ! -f "${ROOT_DIR}/config/nginx/ssl/tls.key" ]]; then
  echo "Missing TLS private key: config/nginx/ssl/tls.key" >&2
  exit 1
fi

echo "Environment validation passed."
