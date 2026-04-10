#!/usr/bin/env bash

set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run this script as root." >&2
  exit 1
fi

usage() {
  cat <<'EOF'
Usage:
  ./scripts/restore-host.sh /path/to/backup.tar.gz --force

This operation restores LDAP configuration/data and host-local service
configuration from a backup created by backup-host.sh.
EOF
}

if [[ $# -lt 2 ]]; then
  usage >&2
  exit 1
fi

ARCHIVE_PATH="$1"
FORCE_FLAG="$2"

if [[ ! -f "${ARCHIVE_PATH}" ]]; then
  echo "Backup archive not found: ${ARCHIVE_PATH}" >&2
  exit 1
fi

if [[ "${FORCE_FLAG}" != "--force" ]]; then
  echo "Refusing restore without --force." >&2
  usage >&2
  exit 1
fi

# shellcheck source=./common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

WORKDIR="$(mktemp -d)"
ROLLBACK_ROOT="/var/backups/lxc-reverse-proxy-ldap"
ROLLBACK_STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
ROLLBACK_ARCHIVE="${ROLLBACK_ROOT}/pre-restore-${ROLLBACK_STAMP}.tar.gz"

cleanup() {
  rm -rf "${WORKDIR}"
}
trap cleanup EXIT

extract_path="$(mktemp -d)"
trap 'rm -rf "${WORKDIR}" "${extract_path}"' EXIT

tar -C "${extract_path}" -xzf "${ARCHIVE_PATH}"

install -d -m 0755 "${ROLLBACK_ROOT}"
tar -czf "${ROLLBACK_ARCHIVE}" \
  /etc/lxc-reverse-proxy-ldap \
  /etc/nginx/conf.d \
  /etc/default/slapd \
  /var/www/service-index \
  /root/lxc-reverse-proxy-ldap.secrets \
  /etc/phpldapadmin/config_local.php \
  /etc/phpldapadmin/apache.conf \
  /etc/apache2/ports.conf \
  2>/dev/null || true

systemctl stop nginx || true
if systemctl list-unit-files apache2.service >/dev/null 2>&1; then
  systemctl stop apache2 || true
fi
systemctl stop slapd || true

restore_copy() {
  local src="$1"
  local dest="$2"

  if [[ -e "${src}" ]]; then
    rm -rf "${dest}"
    install -d -m 0755 "$(dirname "${dest}")"
    cp -a "${src}" "${dest}"
  fi
}

restore_copy "${extract_path}/files/etc/lxc-reverse-proxy-ldap" "/etc/lxc-reverse-proxy-ldap"
restore_copy "${extract_path}/files/etc/nginx/conf.d" "/etc/nginx/conf.d"
restore_copy "${extract_path}/files/etc/nginx/nginx.conf" "/etc/nginx/nginx.conf"
restore_copy "${extract_path}/files/etc/default/slapd" "/etc/default/slapd"
restore_copy "${extract_path}/files/etc/phpldapadmin/config_local.php" "/etc/phpldapadmin/config_local.php"
restore_copy "${extract_path}/files/etc/phpldapadmin/apache.conf" "/etc/phpldapadmin/apache.conf"
restore_copy "${extract_path}/files/etc/apache2/ports.conf" "/etc/apache2/ports.conf"
restore_copy "${extract_path}/files/var/www/service-index" "/var/www/service-index"
restore_copy "${extract_path}/files/root/lxc-reverse-proxy-ldap.secrets" "/root/lxc-reverse-proxy-ldap.secrets"

rm -rf /etc/ldap/slapd.d/* /var/lib/ldap/*
slapadd -F /etc/ldap/slapd.d -n 0 -l "${extract_path}/ldap/config.ldif"
slapadd -F /etc/ldap/slapd.d -n 1 -l "${extract_path}/ldap/data.ldif"
chown -R openldap:openldap /etc/ldap/slapd.d /var/lib/ldap
chmod -R go-rwx /etc/ldap/slapd.d

nginx -t
systemctl start slapd
if systemctl list-unit-files apache2.service >/dev/null 2>&1; then
  systemctl start apache2
fi
systemctl start nginx

echo "Restore finished."
echo "Rollback snapshot: ${ROLLBACK_ARCHIVE}"
