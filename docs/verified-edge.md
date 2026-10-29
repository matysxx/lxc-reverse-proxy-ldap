# Preparing a verified HTTPS edge

Use `templates/nginx/verified-edge.conf.example` and
`templates/nginx/verified-edge-route.conf.example` for an application with a
single HTTPS edge that routes Web and API traffic internally. Render private
values only into ignored runtime files and host-local configuration.

Initially set ROUTING_FILE to a file containing:

```nginx
location / {
    default_type text/plain;
    add_header Retry-After 3600 always;
    return 503 "Service preparation in progress.\n";
}
```

Publish portal cards with a preparation status. Keep the candidate route outside
nginx's active include tree. Do not enable it until the edge owner confirms
HTTPS readiness, the SAN/SNI name, a public CA chain and its fingerprint, and
the complete list of internal administrative endpoints to deny. Never transfer
the central proxy's private key to the edge.

The template blocks the documentation and healthcheck prefixes. Application
versions can expose other administrative endpoints: review the list with the
edge owner before activation. Request size 64m and 3600s timeouts are starting
values to confirm with that owner, not vendor sizing guarantees.

This pattern assumes clients connect directly to the central proxy. It overwrites
forwarding headers with the peer address. If another trusted proxy precedes it,
review real_ip rules and source access controls before use. Replace the internal
access placeholder with the approved networks. Do not enable HTTP/2 merely by
copying older templates when wildcard-certificate coalescing has caused issues.

Before activation, check DNS, the source address selected by `ip route get`,
firewall readiness with its owner, and TLS using the agreed CA and DNS name.
Verify the chain, hostname, dates and fingerprints. Switch the routing include
only after these checks. Run `nginx -t` before reloading. Then verify frontend
TLS, Web, full API path/query forwarding, sanitized headers and a real WebSocket
handshake without production writes. A failed or absent edge is expected during
preparation and must not trigger an insecure HTTP fallback.

Keep copies of the original indexes and vhost before deployment outside Git.
Rollback routing by restoring the maintenance include, validating configuration
and reloading. Restore the saved indexes if the portal change is rolled back.
