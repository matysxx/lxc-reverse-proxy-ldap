# Architektura

## Cel

Jeden kontener LXC w Proxmox ma zapewnić:

- centralny `reverse-proxy`
- usługę katalogową `OpenLDAP`
- prosty panel administracyjny LDAP za reverse proxy
- źródło użytkowników i grup dla `Nextcloud`

## Warstwy

### Proxmox

- host uruchamia kontener LXC
- standardowy LXC z Debianem 13
- `nesting` nie jest wymagany, bo usługi działają natywnie

### Debian 13 w LXC

- system bazowy
- `slapd`, `ldap-utils`, `nginx`
- opcjonalnie `apache2` i `phpldapadmin`
- repozytorium wdrożone np. do `/opt/lxc-reverse-proxy-ldap`

### OpenLDAP

- przechowuje konta użytkowników i grupy
- utrzymuje strukturę `ou=people` i `ou=groups`
- jest podstawowym katalogiem dla logowania i autoryzacji

### Reverse Proxy

- `nginx` przyjmuje ruch na `80/443`
- panel LDAP jest publikowany tylko przez `nginx`
- w razie potrzeby można dołączyć kolejne narzędzia administracyjne

### Nextcloud i serwery danych

- Nextcloud odpyta LDAP po kontach i grupach
- serwery danych pozostają oddzielnymi hostami
- ten LXC nie przechowuje plików użytkowników

## Przepływ ruchu

1. Administrator zarządza katalogiem przez `ldapmodify` lub opcjonalny panel.
2. Nextcloud łączy się z `OpenLDAP`.
3. Serwery danych mogą korzystać z tego samego katalogu do uwierzytelniania.

## Uwagi operacyjne

- LDAP nie powinien być wystawiany publicznie bez świadomej decyzji
- panel `phpLDAPadmin` powinien być ograniczony przynajmniej DNS-em i siecią
- hasła z `.env` powinny zostać zastąpione sekretami lub bezpiecznym vaultem
- katalog powinien być regularnie eksportowany przez `slapcat`
- host-local konfiguracja reverse proxy powinna być objęta tym samym backupem
- logi `nginx` warto rozdzielić per vhost dla szybszego audytu incydentów
