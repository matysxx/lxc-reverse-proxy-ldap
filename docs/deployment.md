# Wdrożenie

## 1. Utworzenie LXC

Minimalna rekomendacja:

- Debian 13
- 2 vCPU
- 2 GB RAM
- 8-16 GB dysku
- statyczny adres IP lub stała dzierżawa DHCP

## 2. Ustawienia LXC w Proxmox

Wystarczy standardowy LXC. `Nesting` nie jest wymagany.

## 3. Instalacja repo wewnątrz LXC

Przykład:

```bash
apt-get update && apt-get install -y git
cd /opt
git clone <nowe-repo> lxc-reverse-proxy-ldap
cd /opt/lxc-reverse-proxy-ldap
install -d -m 0755 /etc/lxc-reverse-proxy-ldap/ssl
cp .env.dist /etc/lxc-reverse-proxy-ldap/env
```

Skrypt bootstrap zainstaluje też `mc` jako narzędzie operatorskie na LXC.

## 4. Konfiguracja

Ustaw w `/etc/lxc-reverse-proxy-ldap/env`:

- domenę LDAP
- DN bazowy
- hasła administratora
- hostname dla `phpLDAPadmin`
- porty HTTP i HTTPS
- flagę `LDAP_PHPLDAPADMIN_ENABLED`
- flagę `LDAP_LDAPS_ENABLED`
- port `LDAP_LDAPS_PORT`
- opcjonalnie:
  - `LDAP_TLS_CERT_FILE`
  - `LDAP_TLS_KEY_FILE`
  - `LDAP_TLS_CA_FILE`
  - `BACKUP_ROOT`
  - `BACKUP_KEEP_COUNT`

Jeżeli w docelowym repozytorium APT nie będzie pakietu `phpldapadmin`, bootstrap
pozostawi działający `slapd` i `nginx`, ale bez panelu WWW.

Dodaj certyfikat:

```bash
mkdir -p /etc/lxc-reverse-proxy-ldap/ssl
cp /ścieżka/do/tls.crt /etc/lxc-reverse-proxy-ldap/ssl/tls.crt
cp /ścieżka/do/tls.key /etc/lxc-reverse-proxy-ldap/ssl/tls.key
chmod 600 /etc/lxc-reverse-proxy-ldap/ssl/tls.key
```

Utwardź też pliki z sekretami i konfiguracją:

```bash
chmod 600 /etc/lxc-reverse-proxy-ldap/env
chmod 600 /root/lxc-reverse-proxy-ldap.secrets
```

Jeżeli włączasz `LDAPS`, użyj tych samych host-local plików w env:

```bash
LDAP_LDAPS_ENABLED=true
LDAP_LDAPS_PORT=636
LDAP_TLS_CERT_FILE=/etc/lxc-reverse-proxy-ldap/ssl/tls.crt
LDAP_TLS_KEY_FILE=/etc/lxc-reverse-proxy-ldap/ssl/tls.key
LDAP_TLS_CA_FILE=
```

Jeżeli potrzebujesz krótkiego miejsca roboczego na pliki wyeksportowane np. z
MikroTika, użyj `runtime/certs/` w repo tylko jako staging area. Docelowe pliki
używane przez `nginx` muszą zostać przeniesione poza repo do
`/etc/lxc-reverse-proxy-ldap/ssl/`.

## 5. Bootstrap i start

```bash
sudo ./scripts/bootstrap-host.sh
sudo ./scripts/start.sh
```

Jeżeli certyfikat podmieniasz już po bootstrapie, odśwież konfigurację `LDAPS`
bez pełnego reinstallowania hosta:

```bash
sudo ./scripts/setup-ldap-tls.sh
sudo systemctl restart slapd
```

## 6. Weryfikacja

```bash
systemctl status slapd nginx
. /etc/lxc-reverse-proxy-ldap/env
ldapsearch -x -D "$LDAP_ADMIN_DN" -W -b "$LDAP_BASE_DN"
openssl s_client -connect "${LDAP_HOSTNAME}:${LDAP_LDAPS_PORT}" -servername "${LDAP_HOSTNAME}" </dev/null
```

Lokalne vhosty i reverse proxy dla usług klienta powinny być utrzymywane poza
repo, bezpośrednio na hoście, np. w `/etc/nginx/conf.d/`.

Jeżeli chcesz wystawić portal startowy usług, użyj repozytoryjnego szablonu:

- `templates/service-index/index.html`

i opublikuj go lokalnie na LXC poza repo, np. jako:

- `/var/www/service-index/index.html`

## 7. Import przykładowych wpisów

Repo zawiera przykładowe LDIF-y:

- `config/ldap/examples/users.sample.ldif`
- `config/ldap/examples/groups.sample.ldif`

Przed importem dostosuj:

- DN do własnej domeny
- `uidNumber` i `gidNumber`
- `memberUid`
- `userPassword` na prawidłowe hashe SSHA

Przykład:

```bash
ldapadd -x -D "cn=admin,dc=<twoja>,dc=<domena>" -W -f config/ldap/examples/users.sample.ldif
ldapadd -x -D "cn=admin,dc=<twoja>,dc=<domena>" -W -f config/ldap/examples/groups.sample.ldif
```

## 8. DNS

Dodaj rekordy DNS wskazujące na adres LXC:

- `ldap.<twoja-domena>`
- `ldapadmin.<twoja-domena>`

## 9. Następne rozszerzenia

- certyfikaty z ACME
- dodatkowe upstreamy za `nginx`
- integracja SSSD/PAM na serwerach danych

## 10. Backup i restore

Mechanizm backupu i odtwarzania jest opisany w:

- `docs/backup.md`

Najprostsze użycie:

```bash
sudo ./scripts/backup-host.sh
sudo ./scripts/restore-host.sh /var/backups/lxc-reverse-proxy-ldap/backup-<hostname>-<timestamp>.tar.gz --force
```

## 11. Logi i rotacja

Skrypty:

- `scripts/setup-logging.sh`
- `scripts/apply-nginx-vhost-logging.sh`

Zakładany układ:

- `/var/log/nginx/services/*.access.log`
- `/var/log/nginx/services/*.error.log`
- `/var/log/lxc-reverse-proxy-ldap-backup.log`

Rotacja:

- osobna konfiguracja `logrotate` w `/etc/logrotate.d/lxc-reverse-proxy-ldap`
- domyślnie `daily`, `rotate 30`, `compress`

Wdrożenie:

```bash
sudo ./scripts/setup-logging.sh
sudo ./scripts/apply-nginx-vhost-logging.sh
```
