FROM from_image

COPY --chown=skpr:skpr etc /etc

# Allow errors to be displayed for non production PHP images.
RUN sed -i '/error_page 500/s/^/#/' /etc/nginx/conf.d/location/10-error-page.conf
