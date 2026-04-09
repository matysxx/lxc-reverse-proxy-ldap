# Nextcloud i LDAP

## Cel

Nextcloud ma używać tego LXC jako centralnego katalogu użytkowników i grup.

## Parametry połączenia

Przykładowe wartości do konfiguracji aplikacji LDAP w Nextcloud:

- host: `ldap.home.arpa`
- port: `389`
- bind DN: `cn=admin,dc=home,dc=arpa`
- base DN: `dc=home,dc=arpa`
- user base DN: `ou=people,dc=home,dc=arpa`
- group base DN: `ou=groups,dc=home,dc=arpa`

## Zalecenia

- dla Nextcloud utwórz osobne konto bind zamiast używać administratora LDAP
- grupy używaj do mapowania uprawnień i widoczności zasobów
- po wdrożeniu przejdź na `LDAPS` albo `StartTLS`
- ogranicz dostęp do LDAP tylko do hostów, które go potrzebują

## Struktura katalogu

Minimalna struktura startowa:

- `dc=home,dc=arpa`
- `ou=people,dc=home,dc=arpa`
- `ou=groups,dc=home,dc=arpa`

## Dalsze rozszerzenia

- osobny OU dla kont technicznych
- osobne konto tylko do odczytu dla Nextcloud
- polityka haseł i rotacji kont
