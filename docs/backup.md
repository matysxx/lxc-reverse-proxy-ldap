# Backup i Restore

## Zakres

Mechanizm obejmuje:

- eksport konfiguracji LDAP `cn=config`
- eksport danych LDAP
- host-local konfigurację z `/etc/lxc-reverse-proxy-ldap`
- host-local vhosty `nginx` z `/etc/nginx/conf.d`
- wybrane pliki pomocnicze:
  - `/etc/default/slapd`
  - `/etc/phpldapadmin/config_local.php`
  - `/etc/phpldapadmin/apache.conf`
  - `/etc/apache2/ports.conf`
  - `/var/www/service-index`
  - `/root/lxc-reverse-proxy-ldap.secrets`

## Backup rotacyjny

Skrypt:

- `scripts/backup-host.sh`

Domyślne parametry:

- `BACKUP_ROOT=/var/backups/lxc-reverse-proxy-ldap`
- `BACKUP_KEEP_COUNT=14`

Możesz je nadpisać przez host-local:

- `/etc/lxc-reverse-proxy-ldap/env`

Przykład ręcznego uruchomienia:

```bash
sudo ./scripts/backup-host.sh
```

Wynik:

- archiwum `backup-<hostname>-<timestamp>.tar.gz`
- automatyczne usunięcie najstarszych archiwów ponad `BACKUP_KEEP_COUNT`
- czytelne logi startu, końca i rotacji na standardowym wyjściu

## Lokalna kopia prywatna

Po wykonaniu backupu na LXC można pobrać najnowsze archiwum do lokalnego
katalogu roboczego:

```text
runtime/host-local-backups/<hostname>/
```

Ten katalog jest objęty regułą `runtime/*` w `.gitignore`, więc lokalne kopie
backupów nie są przeznaczone do GitHub.

Zasady:

- backupy host-local mogą zawierać prywatne adresy, certyfikaty, sekrety,
  vhosty i aktywne indeksy usług
- nie wolno ich dodawać do Git
- dokumentacja w Git opisuje wyłącznie procedurę i ścieżkę lokalną
- po pobraniu backupu warto sprawdzić ignorowanie przez Git:

```bash
git check-ignore -v runtime/host-local-backups/<hostname>/backup-example.tar.gz
```

## Restore

Skrypt:

- `scripts/restore-host.sh`

Przykład:

```bash
sudo ./scripts/restore-host.sh /var/backups/lxc-reverse-proxy-ldap/backup-ldap01-20260410T120000Z.tar.gz --force
```

Weryfikacja archiwum bez zmian w systemie:

```bash
sudo ./scripts/restore-host.sh /var/backups/lxc-reverse-proxy-ldap/backup-ldap01-20260410T120000Z.tar.gz --verify-only
```

Restore wykonuje:

- snapshot rollback bieżącej konfiguracji do `pre-restore-<timestamp>.tar.gz`
- zatrzymanie `nginx`, `apache2` i `slapd`
- przywrócenie host-local plików
- odtworzenie LDAP przez `slapadd`
- start usług po restore

## Ostrożność

- restore jest operacją destrukcyjną dla bieżącej bazy LDAP
- przed użyciem upewnij się, że wskazujesz właściwe archiwum
- skrypt wymaga `--force`, żeby wykonać właściwy restore
- `--verify-only` pozwala sprawdzić strukturę archiwum bez zmian w systemie

## Harmonogram

Najprościej dodać do `root` crona:

```cron
35 2 * * * /opt/lxc-reverse-proxy-ldap/scripts/backup-host.sh >> /var/log/lxc-reverse-proxy-ldap-backup.log 2>&1
```
