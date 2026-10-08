HTTPS
=====

This document outlines how HTTPS is configured for our Skpr image suite.

All images serve the same site over both HTTP (`8080`) and HTTPS (`8443`).

## Certificates

Nginx loads the certificate and key from the following paths (these match the keys of a Kubernetes `kubernetes.io/tls` secret):

```
/etc/nginx/ssl/tls.crt
/etc/nginx/ssl/tls.key
```

The Skpr Platform mounts the real certificate over the top of these files.

If no certificate is mounted, a self-signed certificate generated at build time is used. This is suitable for local development and for upstreams which do not validate certificates (eg. an AWS Application Load Balancer).

**Note:** The self-signed certificate is baked into a public image, so its private key is not a secret. It must not be relied on for anything other than encrypting traffic from upstreams which do not validate certificates.

## Example

```
docker run -v $(pwd)/ssl:/etc/nginx/ssl:ro \
           -p 8080:8080 -p 8443:8443 \
           skpr/nginx:v2-latest
```

Mounting either a directory at `/etc/nginx/ssl` or individual files at `/etc/nginx/ssl/tls.crt` and `/etc/nginx/ssl/tls.key` replaces the self-signed certificate.

The certificate and key must be readable by the `skpr` user (uid `1000`).
