Error Pages
===========

These pages are static pages which are returned with a non 200 event occurs.

The pages include:

* Overview of the error
* The request ID for tracing
* Dark mode (because Rikki is awesome)

These pages are overridable during build time and can be customized to align with your site's design.

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
