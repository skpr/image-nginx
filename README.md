# Skpr Nginx Images

Images for applications which require Nginx (Drupal, PHP etc).

## Documentation

* [Static Status Codes](/docs/static_status_codes.md)
* [robots.txt](/docs/robots.md)
* [Error Pages](/docs/error_pages.md)

## Streams

This image suite provides 2 streams for images:

* `stable` - Our production/stable upstream for projects. Use this by default.
* `latest` - Recently merged changes which will be merged into `stable` as part of a release.

## Images

Images are available in the following registries:

* `ghcr.io`
* `docker.io`

## Image List

Below is the list of PHP images we provide.

By default we recommend the following registry and stream:

```
REGISTRY=docker.io
STREAM=stable
```

```
REGISTRY/skpr/nginx:v2-STREAM
REGISTRY/skpr/nginx-php-fpm:v2-STREAM
REGISTRY/skpr/nginx-php-fpm:dev-v2-STREAM
REGISTRY/skpr/nginx-drupal:v2-STREAM
REGISTRY/skpr/nginx-drupal:dev-v2-STREAM
```

## Configuration Directory Structure.

Nginx config is broken down into sub-directories to allow custom additions and overrides.

The base directory structure is as follows:
```
conf.d/
├── header
│   ├── feature.conf
│   ├── hsts.conf
│   ├── referrer.conf
│   ├── server.conf
│   └── xss.conf
└── location
    ├── 00-well_known.conf
    ├── 10-block.conf
    ├── 10-favicon.conf
    ├── 10-readyz.conf
    ├── 10-robots.conf
    ├── 10-styleguide.conf
    └── 50-assets.conf
```

The PHP-FPM configuration is layered on top of this as follows:

```
conf.d/
├── fastcgi
│   ├── errors.conf
│   ├── params.conf
│   ├── pass.conf
│   └── timeout.conf
└── location
    ├── 20-fastcgi.conf
    └── 20-php.conf
```

And finally the Drupal-specific configuration is layered on top of this:

```
conf.d/
├── header
│   ├── x_drupal_cache.conf
│   ├── x_drupal_dynamic_cache.conf
│   └── x_generator.conf
└── location
    └── 20-drupal.conf
```

## Adding Custom Configuration

For example, if you wanted to add your own custom header configuration, create it using the standard
directory structure.

```
conf.d/
└── header
    └── custom.conf
```

and then copy it over in your Dockerfile:

```
FROM skpr/nginx-drupal:v2-latest
COPY conf.d /etc/nginx/conf.d
```

This adds any custom configuration in `conf.d/` to the correct location in the Nginx image.
