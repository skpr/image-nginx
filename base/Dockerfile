FROM alpine:3.23 AS ssl
RUN apk --update --no-cache add openssl
RUN mkdir /ssl && \
    openssl req -x509 -nodes -days 3650 \
      -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 \
      -subj "/CN=localhost" \
      -keyout /ssl/tls.key \
      -out /ssl/tls.crt && \
    chmod 600 /ssl/tls.key

FROM alpine:3.23
RUN adduser -D -u 1000 skpr
RUN apk --update --no-cache add util-linux ca-certificates nginx nginx-mod-http-headers-more

COPY --chown=skpr:skpr etc /etc

# Default self-signed certificate for HTTPS.
# The Skpr Platform mounts the real certificate over the top of these.
COPY --from=ssl --chown=skpr:skpr /ssl /etc/nginx/ssl

# We need to create and chown these directory for
# readonly and non-root execution.
RUN mkdir -p /run/nginx /var/tmp/nginx
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
EXPOSE 8443

STOPSIGNAL SIGTERM

USER skpr

CMD ["nginx"]
