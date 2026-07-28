# syntax=docker/dockerfile:1

# The runtime image is scratch (no shell), so the dev tweaks that used to run
# as `RUN sed ...` are applied in an Alpine builder stage against a copy of the
# parent rootfs, then layered back over the scratch image.
FROM alpine:3.23 AS build

COPY --from=from_image / /rootfs
COPY etc /rootfs/etc

RUN set -eux; \
    chown -R 1000:1000 /rootfs/etc/nginx; \
    # Allow errors to be displayed for non production PHP images.
    sed -i '/error_page 500/s/^/#/' /rootfs/etc/nginx/conf.d/location/10-error-page.conf

FROM from_image

COPY --from=build /rootfs/etc/nginx /etc/nginx
