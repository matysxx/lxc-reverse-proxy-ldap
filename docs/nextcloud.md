# Nextcloud i LDAP

## Cel

Nextcloud ma używać tego LXC jako centralnego katalogu użytkowników i grup.

## Parametry połączenia

Przykładowe wartości do konfiguracji aplikacji LDAP w Nextcloud:

- host: `ldap.<twoja-domena>`
- port: `389`
- bind DN: `cn=admin,dc=<twoja>,dc=<domena>`
- base DN: `dc=<twoja>,dc=<domena>`
- user base DN: `ou=people,dc=<twoja>,dc=<domena>`
- group base DN: `ou=groups,dc=<twoja>,dc=<domena>`

## Zalecenia

- dla Nextcloud utwórz osobne konto bind zamiast używać administratora LDAP
- grupy używaj do mapowania uprawnień i widoczności zasobów
- dla `OpenLDAP` z `posixGroup` ustaw mapowanie grup po `memberUid`, nie po
  `memberOf`
- po wdrożeniu możesz przejść na `LDAPS`, ale Nextcloud musi ufać CA, która
  podpisała certyfikat LDAP
- ogranicz dostęp do LDAP tylko do hostów, które go potrzebują

## Struktura katalogu

Minimalna struktura startowa:

- `dc=<twoja>,dc=<domena>`
- `ou=people,dc=<twoja>,dc=<domena>`
- `ou=groups,dc=<twoja>,dc=<domena>`

## Dalsze rozszerzenia

- osobny OU dla kont technicznych
- osobne konto tylko do odczytu dla Nextcloud
- polityka haseł i rotacji kont
- zaufanie dla lokalnego CA w kontenerze/aplikacji Nextcloud przed przejściem na
  `LDAPS`
