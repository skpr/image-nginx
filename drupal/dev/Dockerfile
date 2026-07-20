FROM from_image

# Leave the Drupal cache headers visible for dev images. These empty overrides
# replace the production fastcgi_hide_header directives (shell-free so they work
# on the no-shell hardened base image).
COPY --chown=skpr:skpr etc /etc
