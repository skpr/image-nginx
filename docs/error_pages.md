Error Pages
===========

These images display static error pages that include the request ID for debugging.

You can customize these error pages to align with your site's design.

## Configuration Files

This feature implements the following confiugration files:

```
/etc/nginx/conf.d/location/10-error-page.conf  # Maps errors to pages.
/etc/nginx/conf.d/location/10-error-pages.conf # The core configuration for adding the request ID.
```

## HTML Files

The HTML files are stored in this location and overridden for customisation.

```
/etc/nginx/error-pages
```
