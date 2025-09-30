variable "NODE_VERSION" {
  default = "22"
}

variable "STREAM" {
  default = "latest"
}

variable "VERSION" {
  default = "v3"
}

variable "PLATFORMS" {
  type    = list(string)
  default = [
    "linux/amd64",
    "linux/arm64",
  ]
}

variable "REGISTRIES" {
  default = ["docker.io", "ghcr.io"]
}

# Common target: Everything inherits from this
target "_common" {
  platforms = PLATFORMS
}

group "default" {
  targets = [
    "base",
    "php-fpm",
    "php-fpm-dev",
    "drupal",
    "drupal-dev",
  ]
}

target "base" {
  inherits = ["_common"]
  context = "base"

  tags = [
    for r in REGISTRIES :
    "${r}/skpr/php:${VERSION}-${STREAM}"
  ]
}

target "php-fpm" {
  inherits = ["_common"]
  context = "php-fpm"

  contexts = {
    from_image = "target:base"
  }

  tags = [
    for r in REGISTRIES :
    "${r}/skpr/php-fpm:${VERSION}-${STREAM}"
  ]
}

target "php-fpm-dev" {
  inherits = ["_common"]
  context = "php-fpm"

  contexts = {
    from_image = "target:php-fpm"
  }

  tags = [
    for r in REGISTRIES :
    "${r}/skpr/php-fpm:dev-${VERSION}-${STREAM}"
  ]
}

target "drupal" {
  inherits = ["_common"]
  context = "drupal"

  contexts = {
    from_image = "target:php-fpm"
  }

  tags = [
    for r in REGISTRIES :
    "${r}/skpr/php-drupal:${VERSION}-${STREAM}"
  ]
}

# We use this target to apply the same php-fpm dev config onto
# our Drupal image.
target "drupal-php-fpm-dev" {
  inherits = ["_common"]
  context = "php-fpm/dev"

  contexts = {
    from_image = "target:drupal"
  }

  # Only build the test target locally.
  output = ["type=cacheonly"]
}

target "drupal-dev" {
  inherits = ["_common"]
  context = "drupal/dev"

  contexts = {
    from_image = "target:drupal-php-fpm-dev"
  }

  tags = [
    for r in REGISTRIES :
    "${r}/skpr/php-drupal:dev-${VERSION}-${STREAM}"
  ]
}
