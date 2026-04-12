#!/usr/bin/env bash

set -euo pipefail

PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

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

BACKUP_ROOT="${BACKUP_ROOT:-/var/backups/lxc-reverse-proxy-ldap}"
BACKUP_KEEP_COUNT="${BACKUP_KEEP_COUNT:-14}"
SLAPCAT_BIN="$(command -v slapcat || true)"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
HOSTNAME_SHORT="$(hostname -s)"
ARCHIVE_NAME="backup-${HOSTNAME_SHORT}-${STAMP}.tar.gz"
WORKDIR="$(mktemp -d)"
STAGING_DIR="${WORKDIR}/bundle"

if [[ -z "${SLAPCAT_BIN}" ]]; then
  echo "slapcat not found in PATH: ${PATH}" >&2
  exit 1
fi

cleanup() {
  rm -rf "${WORKDIR}"
}
trap cleanup EXIT

copy_into_bundle() {
  local src="$1"
  local dest_root="$2"

  if [[ -e "${src}" ]]; then
    install -d -m 0755 "${dest_root}/$(dirname "${src}")"
    cp -a "${src}" "${dest_root}/${src}"
  fi
}

install -d -m 0755 "${BACKUP_ROOT}"
install -d -m 0755 "${STAGING_DIR}/ldap"
install -d -m 0755 "${STAGING_DIR}/files"
install -d -m 0755 "${STAGING_DIR}/meta"

"${SLAPCAT_BIN}" -n 0 -l "${STAGING_DIR}/ldap/config.ldif"
"${SLAPCAT_BIN}" -n 1 -l "${STAGING_DIR}/ldap/data.ldif"

copy_into_bundle "/etc/lxc-reverse-proxy-ldap" "${STAGING_DIR}/files"
copy_into_bundle "/etc/nginx/conf.d" "${STAGING_DIR}/files"
copy_into_bundle "/etc/nginx/nginx.conf" "${STAGING_DIR}/files"
copy_into_bundle "/etc/default/slapd" "${STAGING_DIR}/files"
copy_into_bundle "/etc/phpldapadmin/config_local.php" "${STAGING_DIR}/files"
copy_into_bundle "/etc/phpldapadmin/apache.conf" "${STAGING_DIR}/files"
copy_into_bundle "/etc/apache2/ports.conf" "${STAGING_DIR}/files"
copy_into_bundle "/var/www/service-index" "${STAGING_DIR}/files"
copy_into_bundle "/root/lxc-reverse-proxy-ldap.secrets" "${STAGING_DIR}/files"

cat > "${STAGING_DIR}/meta/backup.env" <<EOF
BACKUP_TIMESTAMP=${STAMP}
BACKUP_HOSTNAME=${HOSTNAME_SHORT}
BACKUP_ROOT=${BACKUP_ROOT}
ENV_FILE=${ENV_FILE}
EOF

dpkg-query -W slapd nginx apache2 phpldapadmin mc > "${STAGING_DIR}/meta/packages.txt" 2>/dev/null || true
sha256sum "${STAGING_DIR}/ldap/"*.ldif > "${STAGING_DIR}/meta/checksums.txt"

tar -C "${STAGING_DIR}" -czf "${BACKUP_ROOT}/${ARCHIVE_NAME}" .

mapfile -t archives < <(find "${BACKUP_ROOT}" -maxdepth 1 -type f -name 'backup-*.tar.gz' | sort)
if (( ${#archives[@]} > BACKUP_KEEP_COUNT )); then
  remove_count=$(( ${#archives[@]} - BACKUP_KEEP_COUNT ))
  for archive in "${archives[@]:0:${remove_count}}"; do
    rm -f "${archive}"
  done
fi

echo "Backup created: ${BACKUP_ROOT}/${ARCHIVE_NAME}"
