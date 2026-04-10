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

## Restore

Skrypt:

- `scripts/restore-host.sh`

Przykład:

```bash
sudo ./scripts/restore-host.sh /var/backups/lxc-reverse-proxy-ldap/backup-ldap01-20260410T120000Z.tar.gz --force
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
- skrypt wymaga `--force`, żeby ograniczyć przypadkowe użycie

## Harmonogram

Najprościej dodać do `root` crona:

```cron
35 2 * * * /opt/lxc-reverse-proxy-ldap/scripts/backup-host.sh >> /var/log/lxc-reverse-proxy-ldap-backup.log 2>&1
```
