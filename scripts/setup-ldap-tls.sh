#!/usr/bin/env bash

set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run this script as root." >&2
  exit 1
fi

# shellcheck source=./common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Missing ${ENV_FILE}. Create it from .env.dist or host-local config first." >&2
  exit 1
fi

# shellcheck disable=SC1090
source "${ENV_FILE}"

if [[ "${LDAP_LDAPS_ENABLED:-false}" != "true" ]]; then
  echo "LDAP_LDAPS_ENABLED is not true, skipping LDAPS setup."
  exit 0
fi

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

install -d -m 0750 -o root -g openldap /etc/ldap/tls
install -m 0640 -o root -g openldap "${ldap_tls_cert_file}" /etc/ldap/tls/server.crt
install -m 0640 -o root -g openldap "${ldap_tls_key_file}" /etc/ldap/tls/server.key

ldif_path="${RUNTIME_DIR}/ldap-tls.ldif"
cat >"${ldif_path}" <<EOF
dn: cn=config
changetype: modify
replace: olcTLSCertificateFile
olcTLSCertificateFile: /etc/ldap/tls/server.crt
-
replace: olcTLSCertificateKeyFile
olcTLSCertificateKeyFile: /etc/ldap/tls/server.key
EOF

if [[ -n "${ldap_tls_ca_file}" ]]; then
  if [[ ! -f "${ldap_tls_ca_file}" ]]; then
    echo "Missing LDAP TLS CA file: ${ldap_tls_ca_file}" >&2
    exit 1
  fi
  install -m 0644 -o root -g root "${ldap_tls_ca_file}" /etc/ldap/tls/ca.crt
  cat >>"${ldif_path}" <<EOF
-
replace: olcTLSCACertificateFile
olcTLSCACertificateFile: /etc/ldap/tls/ca.crt
EOF
fi

ldapmodify -Y EXTERNAL -H ldapi:/// -f "${ldif_path}"
