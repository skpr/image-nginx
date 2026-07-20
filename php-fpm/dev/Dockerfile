FROM from_image

# Allow errors to be displayed for non production PHP images. The dev copy of
# 10-error-page.conf disables the error_page 500 interception (shell-free so it
# works on the no-shell hardened base image).
COPY --chown=skpr:skpr etc /etc
