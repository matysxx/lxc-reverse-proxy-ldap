#!/usr/bin/env bash

set -euo pipefail

# shellcheck source=./common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Missing ${ENV_FILE}. Create it from .env.dist or host-local config." >&2
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
  LDAP_LDAPS_ENABLED
  LDAP_LDAPS_PORT
  PROXY_HTTP_PORT
  PROXY_HTTPS_PORT
)

for var_name in "${required_vars[@]}"; do
  if [[ -z "${!var_name:-}" ]]; then
    echo "Missing required variable: ${var_name}" >&2
    exit 1
  fi
done

if [[ ! -f "${TLS_CERT_SOURCE}" ]]; then
  echo "Missing TLS certificate: ${TLS_CERT_SOURCE}" >&2
  exit 1
fi

if [[ ! -f "${TLS_KEY_SOURCE}" ]]; then
  echo "Missing TLS private key: ${TLS_KEY_SOURCE}" >&2
  exit 1
fi

if [[ "${LDAP_LDAPS_ENABLED}" == "true" ]]; then
  ldap_tls_cert_file="${LDAP_TLS_CERT_FILE:-${LDAP_TLS_CERT_SOURCE_DEFAULT}}"
  ldap_tls_key_file="${LDAP_TLS_KEY_FILE:-${LDAP_TLS_KEY_SOURCE_DEFAULT}}"
  ldap_tls_ca_file="${LDAP_TLS_CA_FILE:-}"

  if [[ ! -f "${ldap_tls_cert_file}" ]]; then
    echo "Missing LDAP TLS certificate: ${ldap_tls_cert_file}" >&2
    exit 1
  fi

  if [[ ! -f "${ldap_tls_key_file}" ]]; then
    echo "Missing LDAP TLS private key: ${ldap_tls_key_file}" >&2
    exit 1
  fi

  if [[ -n "${ldap_tls_ca_file}" ]] && [[ ! -f "${ldap_tls_ca_file}" ]]; then
    echo "Missing LDAP TLS CA file: ${ldap_tls_ca_file}" >&2
    exit 1
  fi
fi

echo "Environment validation passed."
