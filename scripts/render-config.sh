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

install -d -m 0755 "${RUNTIME_DIR}"

export LDAP_HOSTNAME
export LDAP_PHPLDAPADMIN_HOSTNAME
export PROXY_HTTP_PORT
export PROXY_HTTPS_PORT
export SSL_CERT_FILE
export SSL_KEY_FILE

nginx_template="${ROOT_DIR}/config/nginx/templates/ldap-admin-disabled.conf.template"
if [[ "${LDAP_PHPLDAPADMIN_ENABLED}" == "true" ]]; then
  nginx_template="${ROOT_DIR}/config/nginx/templates/ldap-admin.conf.template"
fi

envsubst \
  '${LDAP_HOSTNAME} ${LDAP_PHPLDAPADMIN_HOSTNAME} ${PROXY_HTTP_PORT} ${PROXY_HTTPS_PORT} ${SSL_CERT_FILE} ${SSL_KEY_FILE}' \
  < "${nginx_template}" \
  > "${RUNTIME_DIR}/ldap-admin.conf"

export LDAP_BASE_DN
export LDAP_USERS_OU
export LDAP_GROUPS_OU

envsubst \
  '${LDAP_BASE_DN} ${LDAP_USERS_OU} ${LDAP_GROUPS_OU}' \
  < "${ROOT_DIR}/config/ldap/base.ldif.template" \
  > "${RUNTIME_DIR}/base.ldif"

if [[ -d /etc/nginx/conf.d ]]; then
  install -d -m 0755 /etc/nginx/ssl
  install -m 0644 "${TLS_CERT_SOURCE}" /etc/nginx/ssl/tls.crt
  install -m 0600 "${TLS_KEY_SOURCE}" /etc/nginx/ssl/tls.key
  install -m 0644 "${RUNTIME_DIR}/ldap-admin.conf" /etc/nginx/conf.d/ldap-admin.conf
fi
