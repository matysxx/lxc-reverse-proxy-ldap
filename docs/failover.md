# Failover i Redundancja

## Cel

Ten dokument opisuje warianty wprowadzenia redundancji dla:

- `nginx` jako reverse proxy
- `OpenLDAP` jako katalogu użytkowników i grup

Nie jest to instrukcja wdrożeniowa. To materiał projektowy na wypadek
przyszłego rozszerzenia środowiska o mechanizmy failover.

## Zakres problemu

Redundancja `reverse proxy` i redundancja `LDAP` to dwa różne zagadnienia.

### Reverse Proxy

Cel:

- utrzymać publikację usług przy awarii głównego LXC

### LDAP

Cel:

- utrzymać logowanie i dostęp do katalogu użytkowników oraz grup

W praktyce:

- failover `nginx` jest relatywnie prosty
- failover `OpenLDAP` wymaga osobnego projektu danych i synchronizacji katalogu

## Warianty dla Reverse Proxy

### 1. DNS failover

Model:

- rekord DNS jest ręcznie lub automatycznie przepinany na zapasowy host

Plusy:

- prosty do zrozumienia
- nie wymaga wspólnego adresu IP

Minusy:

- zależy od cache DNS
- nie daje szybkiego i przewidywalnego przełączenia
- nie jest pełnym HA

Ocena:

- dopuszczalne jako rozwiązanie awaryjne
- niezalecane jako docelowy mechanizm failover

### 2. Active-passive z `keepalived` i `VRRP`

Model:

- dwa hosty w tej samej sieci L2
- oba mają gotową konfigurację `nginx`
- jeden host jest aktywny
- drugi przejmuje wirtualny adres IP (`VIP`) po awarii pierwszego

Plusy:

- szybkie przełączenie
- jeden adres IP i jedna nazwa DNS
- prosty model operacyjny

Minusy:

- wymaga drugiego hosta i synchronizacji konfiguracji host-local
- wymaga testów przejęcia VIP

Ocena:

- rekomendowany wariant dla lokalnego środowiska Vitrobud

### 3. Active-active

Model:

- oba hosty przyjmują ruch jednocześnie
- ruch jest rozkładany przez load balancer lub router

Plusy:

- lepsze wykorzystanie obu hostów

Minusy:

- większa złożoność
- wyższe ryzyko rozjazdu host-local konfiguracji
- dla obecnej skali środowiska zwykle niepotrzebne

Ocena:

- niezalecane jako pierwszy etap

## Warianty dla LDAP

### 1. Backup/restore active-passive

Model:

- główny serwer LDAP działa na hoście A
- host B ma przygotowany ten sam stack, ale normalnie nie przyjmuje ruchu
- backupy LDAP są regularnie kopiowane na host B
- przy awarii wykonywane jest przełączenie na host B i ewentualne odtworzenie

Plusy:

- prostszy model
- niski koszt wdrożenia
- dobrze pasuje do środowiska o umiarkowanej skali

Minusy:

- możliwa utrata ostatnich zmian między backupami
- nie daje pełnej ciągłości katalogu

Ocena:

- dobre rozwiązanie awaryjne
- nie jest pełnym HA

### 2. Replika LDAP `primary -> replica`

Model:

- host A jest głównym LDAP
- host B utrzymuje replikę katalogu, np. przez `syncrepl`
- w razie awarii hosta A ruch może zostać przełączony na host B

Plusy:

- dużo mniejszy RPO niż przy samym backupie
- szybsze przełączenie
- dobre połączenie prostoty i bezpieczeństwa

Minusy:

- wymaga poprawnego projektu replikacji
- wymaga testów spójności katalogu i certyfikatów `LDAPS`

Ocena:

- rekomendowany docelowy wariant dla LDAP, jeżeli środowisko ma dostać HA

### 3. Multi-master

Model:

- oba serwery przyjmują zapisy i synchronizują katalog dwukierunkowo

Plusy:

- teoretycznie najwyższa ciągłość pracy

Minusy:

- najwyższa złożoność
- ryzyko konfliktów i trudniejszego debugowania
- większe wymagania operacyjne dla `cn=config`, replikacji danych i polityki zmian

Ocena:

- niezalecane jako pierwszy etap

## Rekomendowana architektura etapowa

### Etap 1. Redundancja reverse proxy

Zakres:

- drugi LXC lub VM dla `nginx`
- ta sama wersja repo na obu hostach
- host-local vhosty synchronizowane poza Git
- `keepalived` i wspólny `VIP`

Cel:

- utrzymać publikację usług przy awarii głównego hosta reverse proxy

### Etap 2. Redundancja LDAP

Zakres:

- drugi host z `OpenLDAP`
- replikacja `primary -> replica`
- `LDAPS` i ten sam model zaufania do CA na obu hostach
- testy logowania z repliki

Cel:

- ograniczyć ryzyko utraty dostępności logowania i katalogu grup

### Etap 3. Decyzja o modelu adresowania LDAP

Możliwe warianty:

- aplikacje znają dwa adresy LDAP: primary i secondary
- albo `ldap.<domena>` wskazuje na `VIP`, który przełącza się między hostami

Ocena:

- `VIP` upraszcza konfigurację klientów
- dwa jawne adresy zmniejszają złożoność warstwy sieciowej

## Wymagania wspólne dla obu hostów

Na obu węzłach failover powinny być spójne:

- wersja repo
- wersja pakietów systemowych
- certyfikaty i zaufanie do CA
- host-local pliki `env`
- host-local vhosty `nginx`
- katalog backupów i procedury odtworzenia
- monitoring i logowanie

## Ryzyka

Najważniejsze ryzyka dla projektu HA:

- rozjazd host-local konfiguracji między hostami
- brak regularnych testów przełączenia
- brak odtworzenia certyfikatów i zaufania `LDAPS` na hoście zapasowym
- traktowanie backupu jako pełnego HA
- zbyt szybkie wejście w multi-master bez etapu repliki

## Minimalny sensowny wariant

Jeżeli celem jest praktyczny failover przy ograniczonej złożoności, minimalny
wariant wygląda tak:

- `nginx`: active-passive z `keepalived` i `VIP`
- `OpenLDAP`: primary + replica albo przynajmniej regularny backup gotowy do
  szybkiego odtworzenia
- jeden zestaw nazw DNS wskazujący na wspólny adres logiczny

## Co przygotować przed wdrożeniem

Przed rozpoczęciem właściwego projektu failover warto doprecyzować:

- docelowy drugi host: LXC czy VM
- model sieciowy i dostępność wspólnego `VIP`
- sposób synchronizacji host-local vhostów `nginx`
- sposób dystrybucji certyfikatów i CA
- oczekiwany `RTO`
- dopuszczalny `RPO`
- zakres usług, które naprawdę muszą przeżyć awarię bez ręcznej interwencji
