# LDAPS

## Cel

Repo wspiera uruchomienie `LDAPS` bez przechowywania aktywnych certyfikatów w
Git.

## Host-local pliki

Materiał certyfikatu trzymaj wyłącznie poza repo:

- `/etc/lxc-reverse-proxy-ldap/ssl/tls.crt`
- `/etc/lxc-reverse-proxy-ldap/ssl/tls.key`

Opcjonalny plik CA:

- `/etc/lxc-reverse-proxy-ldap/ssl/ca.crt`

## Zmienne env

W `/etc/lxc-reverse-proxy-ldap/env` ustaw:

```bash
LDAP_LDAPS_ENABLED=true
LDAP_LDAPS_PORT=636
LDAP_TLS_CERT_FILE=/etc/lxc-reverse-proxy-ldap/ssl/tls.crt
LDAP_TLS_KEY_FILE=/etc/lxc-reverse-proxy-ldap/ssl/tls.key
LDAP_TLS_CA_FILE=
```

## Wdrożenie

Po bootstrapie albo po wymianie certyfikatu:

```bash
sudo ./scripts/check-env.sh
sudo ./scripts/setup-ldap-tls.sh
sudo systemctl restart slapd
```

## Weryfikacja

Port:

```bash
ss -tlnp | grep ':636'
```

Handshake:

```bash
openssl s_client -connect ldap.<twoja-domena>:636 -servername ldap.<twoja-domena> </dev/null
```

Test `ldapsearch`:

```bash
LDAPTLS_REQCERT=never ldapsearch -x -H ldaps://ldap.<twoja-domena>:636 \
  -D "cn=admin,dc=<twoja>,dc=<domena>" -W -b "dc=<twoja>,dc=<domena>"
```

`LDAPTLS_REQCERT=never` używaj tylko do testu diagnostycznego. Produkcyjnie
klient powinien ufać CA, która podpisała certyfikat LDAP.
