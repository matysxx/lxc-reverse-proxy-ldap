# Proxmox LXC Notes

## Rekomendacja

Pozostań przy `Debian 13`.

Powód:

- najprostsza ścieżka operacyjna
- brak potrzeby migracji już przygotowanego LXC
- pełna zgodność z zakładanym stosem repo
- brak potrzeby uruchamiania zagnieżdżonych kontenerów

## Minimalny checklist

- kontener ma dostęp do sieci LAN lub VLAN docelowego
- hostname LXC jest stały
- DNS kieruje nazwy usług na adres LXC
- storage LXC ma miejsce na dane LDAP i certyfikaty
- backup katalogu LDAP jest zaplanowany poza samym hostem

## Nazewnictwo

Przykład:

- CT ID: `230`
- hostname: `lxc-rproxy-ldap`
- repo w kontenerze: `/opt/lxc-reverse-proxy-ldap`
