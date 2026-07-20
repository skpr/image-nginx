# Build stage: the Docker Hardened "-dev" variant ships a shell + apk, which we
# need to create the skpr user, lay down our config and prepare the writable
# runtime directories. The results are copied into the minimal (shell-less)
# runtime image below.
FROM dhi.io/nginx:1.30-alpine3.23-dev AS build

USER root

# Create the skpr user (uid 1000) used for non-root, read-only execution.
RUN adduser -D -u 1000 skpr

# CA certificates for TLS to upstreams (parity with the previous image).
RUN apk --update --no-cache add ca-certificates

COPY --chown=skpr:skpr etc /etc

# Create and chown the directories nginx writes to at runtime so the image can
# run non-root against a read-only root filesystem. Paths match the nginx.conf
# pid / *_temp_path directives.
RUN mkdir -p /run/nginx /var/tmp/nginx /var/lib/nginx/tmp \
    && ln -sf /dev/stderr /var/log/nginx/error.log \
    && chown -R skpr:skpr /run/nginx \
                          /var/tmp/nginx \
                          /var/lib/nginx \
                          /var/log/nginx \
                          /etc/nginx

# Runtime stage: minimal Docker Hardened Image, no shell or package manager.
# Tag floats nginx 1.30.x patches + alpine 3.23 rebuilds (stable stream); switch
# to 1.31-alpine3.23 for the mainline stream. Keep both stages on the same tag.
FROM dhi.io/nginx:1.30-alpine3.23

# Carry over the skpr user so nginx runs as uid 1000 and downstream images can
# COPY --chown=skpr.
COPY --from=build /etc/passwd /etc/group /etc/

# CA certificates for TLS to upstreams.
COPY --from=build /etc/ssl/certs /etc/ssl/certs

# Config and the pre-chowned writable directories.
COPY --from=build --chown=1000:1000 /etc/nginx /etc/nginx
COPY --from=build --chown=1000:1000 /run/nginx /run/nginx
COPY --from=build --chown=1000:1000 /var/tmp/nginx /var/tmp/nginx
COPY --from=build --chown=1000:1000 /var/lib/nginx /var/lib/nginx
COPY --from=build --chown=1000:1000 /var/log/nginx /var/log/nginx

# Declaring these here means they inherit the "chown" directive from above.
VOLUME /run/nginx
VOLUME /var/tmp/nginx
VOLUME /var/lib/nginx/tmp

EXPOSE 8080

STOPSIGNAL SIGTERM

USER skpr

# The DHI runtime image sets ENTRYPOINT ["nginx"] and CMD ["-g", "daemon off;"].
# Reset both so our single "nginx" invocation runs with "daemon off;" from
# nginx.conf, matching the previous image and avoiding a duplicate directive.
ENTRYPOINT []
CMD ["nginx"]
