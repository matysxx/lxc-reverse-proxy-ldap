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

export DEBIAN_FRONTEND=noninteractive

debconf-set-selections <<EOF
slapd slapd/internal/generated_adminpw password ${LDAP_ADMIN_PASSWORD}
slapd slapd/internal/adminpw password ${LDAP_ADMIN_PASSWORD}
slapd slapd/password2 password ${LDAP_ADMIN_PASSWORD}
slapd slapd/password1 password ${LDAP_ADMIN_PASSWORD}
slapd slapd/domain string ${LDAP_DOMAIN}
slapd shared/organization string ${LDAP_ORGANISATION}
slapd slapd/no_configuration boolean false
slapd slapd/backend select MDB
slapd slapd/purge_database boolean false
slapd slapd/move_old_database boolean true
slapd slapd/allow_ldap_v2 boolean false
EOF

apt-get update
apt-get install -y \
  ca-certificates \
  gettext-base \
  ldap-utils \
  logrotate \
  mc \
  nginx \
  openssl \
  slapd

phpldapadmin_available=false
if [[ "${LDAP_PHPLDAPADMIN_ENABLED}" == "true" ]] && apt-cache show phpldapadmin >/dev/null 2>&1; then
  apt-get install -y \
    apache2 \
    libapache2-mod-php \
    phpldapadmin
  phpldapadmin_available=true
fi

install -d -m 0755 "${RUNTIME_DIR}"
install -d -m 0755 "${HOST_CONFIG_DIR}"
install -d -m 0755 "${HOST_CONFIG_DIR}/ssl"

"${ROOT_DIR}/scripts/setup-logging.sh"
"${ROOT_DIR}/scripts/render-config.sh"

if [[ -f /etc/default/slapd ]]; then
  sed -i "s|^SLAPD_SERVICES=.*|SLAPD_SERVICES=\"ldap:/// ldapi:///\"|" /etc/default/slapd
fi

systemctl enable slapd nginx
systemctl restart slapd

if ! ldapsearch -x -D "${LDAP_ADMIN_DN}" -w "${LDAP_ADMIN_PASSWORD}" -b "${LDAP_USERS_OU},${LDAP_BASE_DN}" -s base dn >/dev/null 2>&1; then
  if ! ldapadd -x -D "${LDAP_ADMIN_DN}" -w "${LDAP_ADMIN_PASSWORD}" -f "${ROOT_DIR}/runtime/base.ldif"; then
    echo "Failed to import LDAP organizational units. Verify LDAP_ADMIN_DN and LDAP_BASE_DN." >&2
    exit 1
  fi
fi

if [[ "${phpldapadmin_available}" == "true" ]]; then
  cat >/etc/phpldapadmin/config_local.php <<EOF
<?php
\$servers->setValue('server','host','127.0.0.1');
\$servers->setValue('server','base',array('${LDAP_BASE_DN}'));
\$servers->setValue('login','bind_id','${LDAP_ADMIN_DN}');
EOF

  if [[ -f /etc/apache2/ports.conf ]]; then
    sed -i '/^Listen 80$/d' /etc/apache2/ports.conf || true
    if ! grep -q '^Listen 127.0.0.1:8080$' /etc/apache2/ports.conf; then
      printf '\nListen 127.0.0.1:8080\n' >> /etc/apache2/ports.conf
    fi
  fi

  if [[ -f /etc/phpldapadmin/apache.conf ]]; then
    sed -i 's/<VirtualHost \*:80>/<VirtualHost 127.0.0.1:8080>/' /etc/phpldapadmin/apache.conf || true
  fi

  a2enconf phpldapadmin >/dev/null 2>&1 || true
  systemctl enable apache2
  systemctl restart apache2
else
  echo "phpLDAPadmin package not installed. LDAP remains available without the web panel."
fi

nginx -t
systemctl restart nginx

cat <<'INFO'
Host bootstrap finished.

Next steps:
1. Verify DNS for the configured LDAP hostnames.
2. Replace placeholder TLS material if still using temporary files.
3. Run ldapsearch and log into phpLDAPadmin if enabled.
INFO
