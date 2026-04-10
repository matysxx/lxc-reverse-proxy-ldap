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
BACKUP_LOG_FILE="${BACKUP_LOG_FILE:-/var/log/lxc-reverse-proxy-ldap-backup.log}"
LOGROTATE_TEMPLATE="${ROOT_DIR}/config/logrotate/lxc-reverse-proxy-ldap.conf.template"
LOGROTATE_TARGET="/etc/logrotate.d/lxc-reverse-proxy-ldap"

install -d -m 0755 "${NGINX_SERVICE_LOG_DIR}"
touch "${BACKUP_LOG_FILE}"
chown root:adm "${BACKUP_LOG_FILE}"
chmod 0640 "${BACKUP_LOG_FILE}"

envsubst '${NGINX_SERVICE_LOG_DIR} ${BACKUP_LOG_FILE}' \
  < "${LOGROTATE_TEMPLATE}" \
  > "${LOGROTATE_TARGET}"

chmod 0644 "${LOGROTATE_TARGET}"

echo "Logging scaffold installed."
echo "Per-vhost nginx logs: ${NGINX_SERVICE_LOG_DIR}"
echo "Backup log file: ${BACKUP_LOG_FILE}"
