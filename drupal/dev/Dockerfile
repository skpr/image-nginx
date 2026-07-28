# syntax=docker/dockerfile:1

# The runtime image is scratch (no shell). Removing files cannot be expressed
# as a COPY overlay, so the rootfs is rebuilt in an Alpine builder stage and
# re-emitted from scratch. Runtime metadata is re-declared because `FROM
# scratch` resets it.
FROM alpine:3.23 AS build

COPY --from=from_image / /rootfs

RUN rm -f \
    /rootfs/etc/nginx/conf.d/header/x_drupal_cache.conf \
    /rootfs/etc/nginx/conf.d/header/x_drupal_dynamic_cache.conf

FROM scratch

COPY --from=build /rootfs/ /

VOLUME /run/nginx
VOLUME /var/tmp/nginx
VOLUME /var/lib/nginx/tmp

USER 1000:1000
EXPOSE 8080
STOPSIGNAL SIGTERM

ENTRYPOINT ["/usr/sbin/nginx"]
