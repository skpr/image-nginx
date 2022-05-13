ARG FROM_IMAGE=skpr/nginx-fpm-drupal:v2-latest
FROM ${FROM_IMAGE}

RUN rm -f /etc/nginx/conf.d/header/x_drupal_cache.conf
RUN rm -f /etc/nginx/conf.d/header/x_drupal_dynamic_cache.conf
