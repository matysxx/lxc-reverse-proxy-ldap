# lxc-reverse-proxy-ldap

Schemat repozytorium do uruchomienia jednego kontenera LXC w Proxmox z Debianem
13, w którym usługi działają natywnie w systemie:

- `OpenLDAP` jako centralny katalog użytkowników i grup
- `nginx` jako reverse proxy dla panelu LDAP
- opcjonalny `phpLDAPadmin`

Repo nie używa `docker compose`. To celowe: dla LXC prostsze i bezpieczniejsze
jest utrzymanie usług bez zagnieżdżania kontenerów.

## Decyzja bazowa

Rekomendowany system dla kontenera:

- `Debian 13`

Ten wariant jest wystarczający dla `slapd`, `nginx` i integracji z Nextcloud.

## Układ repo

- `.env.dist` - przykładowe zmienne środowiskowe
- `scripts/bootstrap-host.sh` - instalacja pakietów i pierwsza konfiguracja
- `scripts/check-env.sh` - walidacja lokalnej konfiguracji
- `scripts/backup-host.sh` - backup rotacyjny LDAP i host-local config
- `scripts/restore-host.sh` - przywracanie z archiwum backupu
- `scripts/render-config.sh` - renderowanie plików z szablonów
- `scripts/start.sh` - przeładowanie i start usług
- `scripts/stop.sh` - zatrzymanie usług
- `config/ldap/` - szablony LDAP i LDIF
- `config/nginx/` - konfiguracja reverse proxy
- `docs/` - opis architektury, wdrożenia i integracji
- `docs/backup.md` - procedura backupu i odtwarzania
- `proxmox/` - notatki dla LXC w Proxmox
- `templates/service-index/` - szablon statycznej strony startowej usług
- `runtime/certs/` - miejsce na tymczasowe paczki certyfikatów do importu

## Architektura

Rola tego LXC:

- utrzymywanie katalogu LDAP dla logowania i grup
- wystawienie panelu administracyjnego przez HTTPS
- dostarczenie źródła użytkowników dla Nextcloud

Poza tym LXC:

- nie jest serwerem danych
- nie pełni roli hosta kontenerów aplikacyjnych
- nie trzyma udziałów plikowych z innych serwerów

## Szybki start

1. Przygotuj host-local konfigurację:

   ```bash
   install -d -m 0755 /etc/lxc-reverse-proxy-ldap/ssl
   cp .env.dist /etc/lxc-reverse-proxy-ldap/env
   ```

2. Uzupełnij `/etc/lxc-reverse-proxy-ldap/env`.
3. Dodaj certyfikat do `/etc/lxc-reverse-proxy-ldap/ssl/`.
4. Na świeżym Debianie 13 uruchom:

   ```bash
   sudo ./scripts/bootstrap-host.sh
   ```

5. Uruchom lub przeładuj usługi:

   ```bash
   sudo ./scripts/start.sh
   ```

6. Zweryfikuj:

   ```bash
   systemctl status slapd nginx
   . /etc/lxc-reverse-proxy-ldap/env
   ldapsearch -x -D "$LDAP_ADMIN_DN" -W -b "$LDAP_BASE_DN"
   ```

## Host-Local Configuration

Aktywna konfiguracja wdrożeniowa nie powinna żyć w repo.

Docelowy układ na hoście:

- `/etc/lxc-reverse-proxy-ldap/env` - aktywne zmienne środowiskowe
- `/etc/lxc-reverse-proxy-ldap/ssl/tls.crt`
- `/etc/lxc-reverse-proxy-ldap/ssl/tls.key`
- `/etc/nginx/conf.d/*.conf` - lokalne vhosty i reverse proxy dla usług klienta
- `/root/lxc-reverse-proxy-ldap.secrets` - lokalne sekrety operatorskie

Repo w `/opt/lxc-reverse-proxy-ldap` ma pozostać czyste gitowo i zawierać tylko:

- skrypty
- szablony
- dokumentację
- przykładowe pliki startowe

Jeżeli `/etc/lxc-reverse-proxy-ldap/env` istnieje, skrypty używają go zamiast
repozytoryjnego `.env`.

Katalog `runtime/certs/` w repo może służyć wyłącznie jako miejsce robocze do
odłożenia wyeksportowanych plików przed ręcznym przeniesieniem na host.
Aktywne certyfikaty używane przez `nginx` nadal powinny leżeć wyłącznie w:

- `/etc/lxc-reverse-proxy-ldap/ssl/tls.crt`
- `/etc/lxc-reverse-proxy-ldap/ssl/tls.key`

Szablon portalu usług znajduje się w:

- `templates/service-index/index.html`

Aktywną stronę indeksową publikuj lokalnie na LXC poza repo, np. jako:

- `/var/www/service-index/index.html`

## Usługi

### OpenLDAP

- działa jako `slapd`
- przechowuje użytkowników, grupy i strukturę OU
- stanowi źródło logowania dla Nextcloud
- powinien być regularnie eksportowany przez `slapcat`

### nginx

- nasłuchuje na `80` i `443`
- wystawia panel LDAP pod wskazanym hostname
- może później obsłużyć także inne narzędzia administracyjne
- może też wystawiać statyczny portal usług z szablonu repo

### phpLDAPadmin

- jest opcjonalny
- działa lokalnie przez `apache2`
- domyślnie ma być osiągalny wyłącznie przez `nginx`
- jeżeli pakiet nie będzie dostępny w repo APT, LDAP działa dalej bez panelu WWW

## Plik `.env`

Najważniejsze zmienne:

- `LDAP_ORGANISATION`
- `LDAP_DOMAIN`
- `LDAP_BASE_DN`
- `LDAP_ADMIN_DN`
- `LDAP_ADMIN_PASSWORD`
- `LDAP_USERS_OU`
- `LDAP_GROUPS_OU`
- `LDAP_HOSTNAME`
- `LDAP_PHPLDAPADMIN_HOSTNAME`
- `LDAP_PHPLDAPADMIN_ENABLED`
- `PROXY_HTTP_PORT`
- `PROXY_HTTPS_PORT`

W modelu host-local plik powinien leżeć jako:

- `/etc/lxc-reverse-proxy-ldap/env`

## Przykładowe wpisy LDAP

W repo są przykładowe pliki startowe:

- `config/ldap/base.ldif.template`
- `config/ldap/examples/users.sample.ldif`
- `config/ldap/examples/groups.sample.ldif`

Po dostosowaniu DN, `uidNumber`, `gidNumber` i hashy haseł można je importować
np. tak:

```bash
ldapadd -x -D "$LDAP_ADMIN_DN" -W -f config/ldap/examples/users.sample.ldif
ldapadd -x -D "$LDAP_ADMIN_DN" -W -f config/ldap/examples/groups.sample.ldif
```

## Dalsze kroki

- ograniczyć dostęp do panelu LDAP po sieci lub ACL
- dopisać integrację PAM/SSSD na serwerach danych
- dopisać instrukcję spięcia z Nextcloud na produkcji
- dodać host-local vhost dla portalu usług
