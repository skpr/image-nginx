# Skpr Nginx Images

Images for applications which require Nginx (Drupal, PHP etc).

## Documentation

* [Static Status Codes](/docs/static_status_codes.md)

## Streams

This image suite provides 2 streams for images:

* `latest` - A stable upstream.
* `edge` - Recently merged changes which will be merged into `latest` as part of a release.

## Images

**Latest**

```
docker.io/skpr/nginx:v2-latest
docker.io/skpr/nginx-php-fpm:v2-latest
docker.io/skpr/nginx-php-fpm:dev-v2-latest
docker.io/skpr/nginx-drupal:v2-latest
docker.io/skpr/nginx-drupal:dev-v2-latest
```

**Edge**

```
docker.io/skpr/nginx:v2-edge
docker.io/skpr/nginx-php-fpm:v2-edge
docker.io/skpr/nginx-php-fpm:dev-v2-edge
docker.io/skpr/nginx-drupal:v2-edge
docker.io/skpr/nginx-drupal:dev-v2-edge
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
