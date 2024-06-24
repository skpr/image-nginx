Static Status Codes
===================

Static status codes is a feature for managing fast responses for known/static paths.

Examples include:

* Blocking paths (403)
* Returning a not found response for legacy paths (404).

## Configuration

This feature is configured using the `/etc/nginx/static_status_codes.conf` file.

The configuration below demonstrates how a path can be either return a blocked or not found response early.

```
/not-found 404;
/not-allowed 403;
```
