# syntax=docker/dockerfile:1

# ---------------------------------------------------------------------------
# Statically compiled nginx, shipped in a scratch image.
#
# The build stage is Alpine (musl) rather than Debian (glibc) on purpose:
# a glibc binary linked with -static still dlopen()s libnss_* at runtime for
# getaddrinfo() and getpwnam(). That silently breaks the moment nginx has to
# resolve an upstream hostname inside a scratch image. musl resolves DNS and
# users in-process, so a musl static binary is genuinely self-contained.
#
# The third-party headers-more module is compiled in statically because the
# skpr config relies on more_clear_headers (Server, X-Drupal-Cache, ...).
# ---------------------------------------------------------------------------

ARG ALPINE_VERSION=3.23
ARG NGINX_VERSION=1.30.1
ARG OPENSSL_VERSION=3.5.7
ARG PCRE2_VERSION=10.47
ARG ZLIB_VERSION=1.3.1
ARG HEADERS_MORE_VERSION=0.37

# Non-root uid/gid used by the final image. Kept at 1000/"skpr" so the whole
# downstream chain (COPY --chown=skpr:skpr ..., USER skpr) keeps working.
ARG NGINX_UID=1000
ARG NGINX_GID=1000


# ---------------------------------------------------------------------------
# Stage 1: build
# ---------------------------------------------------------------------------
FROM alpine:${ALPINE_VERSION} AS build

ARG NGINX_VERSION
ARG OPENSSL_VERSION
ARG PCRE2_VERSION
ARG ZLIB_VERSION
ARG HEADERS_MORE_VERSION
ARG NGINX_UID
ARG NGINX_GID

RUN apk add --no-cache \
        build-base \
        ca-certificates \
        curl \
        linux-headers \
        perl \
    && update-ca-certificates

# The user must exist at build time too, otherwise `nginx -t` below fails with
# getpwnam("skpr") when run as root.
RUN addgroup -g ${NGINX_GID} -S skpr \
    && adduser -u ${NGINX_UID} -G skpr -H -D -s /sbin/nologin skpr

WORKDIR /usr/src

# Sources are compiled into nginx rather than linked from Alpine packages, so
# the versions are yours to control. To pin by hash, swap these for
# `ADD --checksum=sha256:...` lines once you have verified each tarball.
RUN set -eux; \
    curl -fsSL "https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" | tar -xz; \
    curl -fsSL "https://github.com/PCRE2Project/pcre2/releases/download/pcre2-${PCRE2_VERSION}/pcre2-${PCRE2_VERSION}.tar.gz" | tar -xz; \
    curl -fsSL "https://github.com/madler/zlib/releases/download/v${ZLIB_VERSION}/zlib-${ZLIB_VERSION}.tar.gz" | tar -xz; \
    curl -fsSL "https://github.com/openssl/openssl/releases/download/openssl-${OPENSSL_VERSION}/openssl-${OPENSSL_VERSION}.tar.gz" | tar -xz; \
    curl -fsSL "https://github.com/openresty/headers-more-nginx-module/archive/refs/tags/v${HEADERS_MORE_VERSION}.tar.gz" | tar -xz

WORKDIR /usr/src/nginx-${NGINX_VERSION}

# Temp/pid/lock paths are baked in to match the writable directories created in
# the rootfs below (and the historical Alpine layout). Log paths are baked in
# as /dev/stdout and /dev/stderr: nginx opens the compile-time error log
# *before* it parses nginx.conf, so a path that does not exist in scratch would
# kill the process at startup. The container runtime always provides
# /dev/std{out,err}, even in scratch.
RUN set -eux; \
    ./configure \
        --prefix=/etc/nginx \
        --sbin-path=/usr/sbin/nginx \
        --modules-path=/usr/lib/nginx/modules \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=/dev/stderr \
        --http-log-path=/dev/stdout \
        --pid-path=/run/nginx/nginx.pid \
        --lock-path=/run/nginx/nginx.lock \
        --http-client-body-temp-path=/var/lib/nginx/tmp/client_body \
        --http-proxy-temp-path=/var/lib/nginx/tmp/proxy \
        --http-fastcgi-temp-path=/var/lib/nginx/tmp/fastcgi \
        --http-uwsgi-temp-path=/var/lib/nginx/tmp/uwsgi \
        --http-scgi-temp-path=/var/lib/nginx/tmp/scgi \
        --user=skpr \
        --group=skpr \
        --with-pcre=../pcre2-${PCRE2_VERSION} \
        --with-pcre-jit \
        --with-zlib=../zlib-${ZLIB_VERSION} \
        --with-openssl=../openssl-${OPENSSL_VERSION} \
        --with-openssl-opt="no-shared no-module no-tests no-docs" \
        --with-http_ssl_module \
        --with-http_v2_module \
        --with-http_realip_module \
        --with-http_gzip_static_module \
        --with-http_gunzip_module \
        --with-http_stub_status_module \
        --with-http_sub_module \
        --with-http_auth_request_module \
        --with-threads \
        --with-file-aio \
        --with-cc-opt="-O2 -fstack-protector-strong" \
        --with-ld-opt="-static" \
        --add-module=../headers-more-nginx-module-${HEADERS_MORE_VERSION}; \
    make -j"$(nproc)"; \
    make install

# Fail the build loudly if anything crept in dynamically. A static binary has
# no PT_INTERP program header.
RUN set -eux; \
    if readelf -l /usr/sbin/nginx | grep -q INTERP; then \
        echo "ERROR: nginx is dynamically linked, it will not run in scratch"; \
        readelf -d /usr/sbin/nginx; \
        exit 1; \
    fi; \
    nginx -V

# Overlay the skpr nginx config on top of the files `make install` laid down
# (mime.types, fastcgi_params, ...). The include of /etc/nginx/modules/*.conf
# in nginx.conf is now a no-op (headers-more is compiled in), so an empty
# directory is enough to keep that glob happy.
COPY etc /etc

# nginx creates its *_temp paths at startup, but with a plain mkdir() rather
# than mkdir -p, so the parents have to exist first or `nginx -t` fails with
# ENOENT.
RUN set -eux; \
    mkdir -p /etc/nginx/modules /run/nginx /var/lib/nginx/tmp; \
    nginx -t

# ---------------------------------------------------------------------------
# Assemble the final filesystem by hand. scratch has no mkdir, no shell and no
# /etc/passwd, so every directory and file the runtime touches has to be
# materialised here with the right ownership.
# ---------------------------------------------------------------------------
RUN set -eux; \
    install -d -m 0755 \
        /rootfs/etc/ssl/certs \
        /rootfs/usr/sbin; \
    install -d -m 1777 /rootfs/tmp; \
    install -d -m 0755 -o ${NGINX_UID} -g ${NGINX_GID} \
        /rootfs/run/nginx \
        /rootfs/var/tmp/nginx \
        /rootfs/var/lib/nginx \
        /rootfs/var/lib/nginx/tmp \
        /rootfs/var/lib/nginx/tmp/client_body \
        /rootfs/var/lib/nginx/tmp/proxy \
        /rootfs/var/lib/nginx/tmp/fastcgi \
        /rootfs/var/lib/nginx/tmp/uwsgi \
        /rootfs/var/lib/nginx/tmp/scgi; \
    printf '%s\n' \
        'root:x:0:0:root:/root:/sbin/nologin' \
        "skpr:x:${NGINX_UID}:${NGINX_GID}:skpr:/nonexistent:/sbin/nologin" \
        > /rootfs/etc/passwd; \
    printf '%s\n' \
        'root:x:0:' \
        "skpr:x:${NGINX_GID}:" \
        > /rootfs/etc/group; \
    cp /usr/sbin/nginx /rootfs/usr/sbin/nginx; \
    cp -a /etc/nginx /rootfs/etc/nginx; \
    chown -R ${NGINX_UID}:${NGINX_GID} /rootfs/etc/nginx; \
    cp /etc/ssl/certs/ca-certificates.crt /rootfs/etc/ssl/certs/ca-certificates.crt


# ---------------------------------------------------------------------------
# Stage 2: runtime
# ---------------------------------------------------------------------------
FROM scratch

ARG NGINX_UID
ARG NGINX_GID

COPY --from=build /rootfs/ /

# Declared writable so the image runs with a read-only root filesystem and a
# non-root user. These inherit the skpr ownership set on the rootfs above.
VOLUME /run/nginx
VOLUME /var/tmp/nginx
VOLUME /var/lib/nginx/tmp

# Unprivileged, so ports below 1024 are not bindable. See the nginx config.
USER ${NGINX_UID}:${NGINX_GID}
EXPOSE 8080

# nginx.conf sets `daemon off;`, so the binary stays in the foreground.
STOPSIGNAL SIGTERM

ENTRYPOINT ["/usr/sbin/nginx"]
