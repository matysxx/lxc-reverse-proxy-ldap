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
BACKUP_SECRET_PASSPHRASE_FILE="${BACKUP_SECRET_PASSPHRASE_FILE:-/root/lxc-reverse-proxy-ldap-backup.passphrase}"
BACKUP_ENCRYPTED_SECRET_GLOBS="${BACKUP_ENCRYPTED_SECRET_GLOBS:-/root/ldap-mail-integration/*.secret}"
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

log() {
  printf '[%s] %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$*"
}

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
install -d -m 0700 "${STAGING_DIR}/secrets"

log "Starting backup for ${HOSTNAME_SHORT}"
log "Using slapcat at ${SLAPCAT_BIN}"

"${SLAPCAT_BIN}" -n 0 -l "${STAGING_DIR}/ldap/config.ldif"
"${SLAPCAT_BIN}" -n 1 -l "${STAGING_DIR}/ldap/data.ldif"

copy_into_bundle "/etc/lxc-reverse-proxy-ldap" "${STAGING_DIR}/files"
copy_into_bundle "/etc/ldap/tls" "${STAGING_DIR}/files"
copy_into_bundle "/etc/nginx/conf.d" "${STAGING_DIR}/files"
copy_into_bundle "/etc/nginx/nginx.conf" "${STAGING_DIR}/files"
copy_into_bundle "/etc/default/slapd" "${STAGING_DIR}/files"
copy_into_bundle "/etc/phpldapadmin/config_local.php" "${STAGING_DIR}/files"
copy_into_bundle "/etc/phpldapadmin/apache.conf" "${STAGING_DIR}/files"
copy_into_bundle "/etc/apache2/ports.conf" "${STAGING_DIR}/files"
copy_into_bundle "/var/www/service-index" "${STAGING_DIR}/files"
copy_into_bundle "/root/lxc-reverse-proxy-ldap.secrets" "${STAGING_DIR}/files"

if [[ -f "${BACKUP_SECRET_PASSPHRASE_FILE}" ]]; then
  SECRET_WORKDIR="${WORKDIR}/private-secrets"
  install -d -m 0700 "${SECRET_WORKDIR}/files"
  found_secret=0

  while IFS= read -r secret_glob; do
    [[ -n "${secret_glob}" ]] || continue
    while IFS= read -r secret_path; do
      [[ -e "${secret_path}" ]] || continue
      found_secret=1
      install -d -m 0700 "${SECRET_WORKDIR}/files/$(dirname "${secret_path}")"
      cp -a "${secret_path}" "${SECRET_WORKDIR}/files/${secret_path}"
    done < <(compgen -G "${secret_glob}" || true)
  done < <(tr ':' '\n' <<< "${BACKUP_ENCRYPTED_SECRET_GLOBS}")

  if (( found_secret )); then
    tar -C "${SECRET_WORKDIR}" -czf - . \
      | openssl enc -aes-256-cbc -salt -pbkdf2 -iter 200000 \
          -pass "file:${BACKUP_SECRET_PASSPHRASE_FILE}" \
          -out "${STAGING_DIR}/secrets/private-secrets.tar.gz.enc"
    chmod 0600 "${STAGING_DIR}/secrets/private-secrets.tar.gz.enc"
    (
      cd "${STAGING_DIR}"
      sha256sum "secrets/private-secrets.tar.gz.enc" > "meta/private-secrets.sha256"
    )
    log "Encrypted private secrets bundle created"
  else
    log "No files matched BACKUP_ENCRYPTED_SECRET_GLOBS; encrypted secrets bundle skipped"
  fi
else
  log "Encrypted secrets bundle skipped: passphrase file not found at ${BACKUP_SECRET_PASSPHRASE_FILE}"
fi

cat > "${STAGING_DIR}/meta/backup.env" <<EOF
BACKUP_TIMESTAMP=${STAMP}
BACKUP_HOSTNAME=${HOSTNAME_SHORT}
BACKUP_ROOT=${BACKUP_ROOT}
ENV_FILE=${ENV_FILE}
BACKUP_SECRET_PASSPHRASE_FILE=${BACKUP_SECRET_PASSPHRASE_FILE}
BACKUP_ENCRYPTED_SECRET_GLOBS=${BACKUP_ENCRYPTED_SECRET_GLOBS}
EOF

dpkg-query -W slapd nginx apache2 phpldapadmin mc > "${STAGING_DIR}/meta/packages.txt" 2>/dev/null || true
sha256sum "${STAGING_DIR}/ldap/"*.ldif > "${STAGING_DIR}/meta/checksums.txt"

tar -C "${STAGING_DIR}" -czf "${BACKUP_ROOT}/${ARCHIVE_NAME}" .

mapfile -t archives < <(find "${BACKUP_ROOT}" -maxdepth 1 -type f -name 'backup-*.tar.gz' | sort)
if (( ${#archives[@]} > BACKUP_KEEP_COUNT )); then
  remove_count=$(( ${#archives[@]} - BACKUP_KEEP_COUNT ))
  log "Applying rotation: removing ${remove_count} old backup(s)"
  for archive in "${archives[@]:0:${remove_count}}"; do
    log "Removing ${archive}"
    rm -f "${archive}"
  done
fi

current_count=$(find "${BACKUP_ROOT}" -maxdepth 1 -type f -name 'backup-*.tar.gz' | wc -l | tr -d ' ')
archive_size_bytes=$(stat -c '%s' "${BACKUP_ROOT}/${ARCHIVE_NAME}")
log "Backup created: ${BACKUP_ROOT}/${ARCHIVE_NAME} (${archive_size_bytes} bytes)"
log "Stored backups after rotation: ${current_count}"
log "Backup finished successfully"
