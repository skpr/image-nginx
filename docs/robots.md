Robots.txt
==========

This document outlines how robots.txt is managed for our Skpr image suite.

## Hardening

Developers often list the locations of hidden files or directories in robots.txt to prevent these locations from showing up in search engine results. However, the opposite effect is achieved when human users browse this file and read its contents.

Below is a list of steps to harden your application configuration:

* Remove sensitive paths from your applications `robots.txt` file.
* Leverage `X-Robots-Tag` tag to hide sensitive paths instead (see below).

## X-Robots-Tag

The X-Robots-Tag is an HTTP header sent from a web server that contains the directives for web crawlers such as Googlebot.

The following header is an alternative to the standard robots.txt approach and allows for development teams to obfuscate sensitives paths.

This configuration is managed using the `/etc/nginx/robots.conf` file.

The configuration below sets the `X-Robots-Tag` header for all pages under `/admin` path.

```
~*/admin/(.*) "noindex, nofollow";
```

## How do I opt out?

Clients can opt out of this header by adding the following to their Nginx Dockerfile build:

```
# Removes all X-Robots-Tag rules.
RUN echo "" > /etc/nginx/conf.d/header/robots.conf
```
