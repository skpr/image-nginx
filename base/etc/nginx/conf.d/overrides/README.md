Overrides
=========

A directory for overriding default Nginx config.

## Examples

**Setting client_max_body_size**

```bash
$ cat /etc/nginx/conf.d/overrides/client_max_body_size.conf

client_max_body_size 150M;
```
