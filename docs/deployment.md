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

## 4. Konfiguracja

Ustaw w `/etc/lxc-reverse-proxy-ldap/env`:

- domenę LDAP
- DN bazowy
- hasła administratora
- hostname dla `phpLDAPadmin`
- porty HTTP i HTTPS
- flagę `LDAP_PHPLDAPADMIN_ENABLED`

Jeżeli w docelowym repozytorium APT nie będzie pakietu `phpldapadmin`, bootstrap
pozostawi działający `slapd` i `nginx`, ale bez panelu WWW.

Dodaj certyfikat:

```bash
mkdir -p /etc/lxc-reverse-proxy-ldap/ssl
cp /ścieżka/do/tls.crt /etc/lxc-reverse-proxy-ldap/ssl/tls.crt
cp /ścieżka/do/tls.key /etc/lxc-reverse-proxy-ldap/ssl/tls.key
chmod 600 /etc/lxc-reverse-proxy-ldap/ssl/tls.key
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

## 6. Weryfikacja

```bash
systemctl status slapd nginx
. /etc/lxc-reverse-proxy-ldap/env
ldapsearch -x -D "$LDAP_ADMIN_DN" -W -b "$LDAP_BASE_DN"
```

Lokalne vhosty i reverse proxy dla usług klienta powinny być utrzymywane poza
repo, bezpośrednio na hoście, np. w `/etc/nginx/conf.d/`.

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
ldapadd -x -D "cn=admin,dc=home,dc=arpa" -W -f config/ldap/examples/users.sample.ldif
ldapadd -x -D "cn=admin,dc=home,dc=arpa" -W -f config/ldap/examples/groups.sample.ldif
```

## 8. DNS

Dodaj rekordy DNS wskazujące na adres LXC:

- `ldap.home.arpa`
- `ldapadmin.home.arpa`

## 9. Następne rozszerzenia

- backup LDAP przez `slapcat`
- certyfikaty z ACME
- dodatkowe upstreamy za `nginx`
- integracja SSSD/PAM na serwerach danych
