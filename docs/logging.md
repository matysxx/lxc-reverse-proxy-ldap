# Logi

## Zakres

Projekt zakłada trzy obszary logowania:

- `nginx` globalny i per vhost
- `apache2`
- `slapd` przez `journald`

## Docelowe ścieżki

- globalny `nginx`:
  - `/var/log/nginx/access.log`
  - `/var/log/nginx/error.log`
- per vhost `nginx`:
  - `/var/log/nginx/services/<nazwa>.access.log`
  - `/var/log/nginx/services/<nazwa>.error.log`
- backupy:
  - `/var/log/lxc-reverse-proxy-ldap-backup.log`

## Audyt

Przykłady:

```bash
tail -f /var/log/nginx/services/openpr.access.log
tail -f /var/log/nginx/services/openpr.error.log
journalctl -u slapd -f
journalctl -u nginx -u apache2 -u slapd --since "today"
```

## Rotacja

Konfiguracja:

- `/etc/logrotate.d/lxc-reverse-proxy-ldap`

Domyślnie:

- `daily`
- `rotate 30`
- `compress`
- `delaycompress`

## Wdrożenie

```bash
sudo ./scripts/setup-logging.sh
sudo ./scripts/apply-nginx-vhost-logging.sh
```
