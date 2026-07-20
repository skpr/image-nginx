FROM cgr.dev/chainguard/wolfi-base:latest
RUN adduser -D -u 1000 skpr
# nginx-mainline is the only nginx package Wolfi provides. It pulls in
# nginx-config (mime.types, fastcgi_params etc.) as a runtime dependency.
RUN apk --no-cache add util-linux ca-certificates-bundle nginx-mainline

COPY --chown=skpr:skpr etc /etc

# We need to create and chown these directories for
# readonly and non-root execution. Wolfi's nginx uses a prefix of
# /var/lib/nginx and does not pre-create the temp/log sub-directories.
RUN mkdir -p /run/nginx \
             /var/tmp/nginx \
             /var/log/nginx \
             /var/lib/nginx/tmp \
             /var/lib/nginx/logs \
             /usr/lib/nginx/modules
RUN ln -sf /dev/stderr /var/log/nginx/error.log
RUN chown -R skpr:skpr /var/lib/nginx \
                       /var/log/nginx \
                       /var/tmp/nginx \
                       /var/lib/nginx/tmp \
                       /var/lib/nginx/logs \
                       /usr/lib/nginx/modules \
                       /run/nginx

# Declaring these here means they inherit the "chown"
# directive from above.
VOLUME /run/nginx
VOLUME /var/tmp/nginx
VOLUME /var/lib/nginx/tmp

EXPOSE 8080

STOPSIGNAL SIGTERM

USER skpr

CMD ["nginx"]
