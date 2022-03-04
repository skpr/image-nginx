#!/usr/bin/make -f

REGISTRY_BASE=skpr/nginx
REGISTRY_PHP_FPM=skpr/nginx-php-fpm
REGISTRY_DRUPAL=skpr/nginx-drupal

VERSION_TAG=v2-latest
ARCH=amd64

build:
	# Building Base
	docker build -t ${REGISTRY_BASE}:${VERSION_TAG}-${ARCH} base
	docker run -it --rm --hostname=php-fpm --read-only ${REGISTRY_BASE}:${VERSION_TAG}-${ARCH} nginx -t

	# Building PHP-FPM
	docker build --build-arg FROM_IMAGE=${REGISTRY_BASE}:${VERSION_TAG}-${ARCH} -t ${REGISTRY_PHP_FPM}:${VERSION_TAG}-${ARCH} php-fpm
	docker run -it --rm --hostname=php-fpm --read-only ${REGISTRY_PHP_FPM}:${VERSION_TAG}-${ARCH} nginx -t

	# Building PHP-FPM (Dev)
	docker build --build-arg FROM_IMAGE=${REGISTRY_PHP_FPM}:${VERSION_TAG}-${ARCH} -t ${REGISTRY_PHP_FPM}:dev-${VERSION_TAG}-${ARCH} php-fpm/dev
	docker run -it --rm --hostname=php-fpm --read-only ${REGISTRY_PHP_FPM}:dev-${VERSION_TAG}-${ARCH} nginx -t

	# Building Drupal
	docker build --build-arg FROM_IMAGE=${REGISTRY_PHP_FPM}:${VERSION_TAG}-${ARCH} -t ${REGISTRY_DRUPAL}:${VERSION_TAG}-${ARCH} php-fpm
	docker run -it --rm --hostname=php-fpm --read-only ${REGISTRY_DRUPAL}:${VERSION_TAG}-${ARCH} nginx -t

	# Building Drupal (Dev)
	docker build --build-arg FROM_IMAGE=${REGISTRY_DRUPAL}:${VERSION_TAG}-${ARCH} -t ${REGISTRY_DRUPAL}:dev-${VERSION_TAG}-${ARCH} php-fpm/dev
	docker run -it --rm --hostname=php-fpm --read-only ${REGISTRY_DRUPAL}:dev-${VERSION_TAG}-${ARCH} nginx -t

push:
	docker push ${REGISTRY}:${VERSION_TAG}-${ARCH}
	docker push ${REGISTRY_PHP_FPM}:${VERSION_TAG}-${ARCH}
	docker push ${REGISTRY_PHP_FPM}:dev-${VERSION_TAG}-${ARCH}
	docker push ${REGISTRY_DRUPAL}:${VERSION_TAG}-${ARCH}
	docker push ${REGISTRY_DRUPAL}:dev-${VERSION_TAG}-${ARCH}

manifest:
	$(eval IMAGE=${REGISTRY}:${VERSION_TAG})
	docker manifest create ${IMAGE} --amend ${IMAGE}-arm64 --amend ${IMAGE}-amd64
	docker manifest push ${IMAGE}

	$(eval IMAGE=${REGISTRY_PHP_FPM}:${VERSION_TAG})
	docker manifest create ${IMAGE} --amend ${IMAGE}-arm64 --amend ${IMAGE}-amd64
	docker manifest push ${IMAGE}

	$(eval IMAGE=${REGISTRY_PHP_FPM}:dev-${VERSION_TAG})
	docker manifest create ${IMAGE} --amend ${IMAGE}-arm64 --amend ${IMAGE}-amd64
	docker manifest push ${IMAGE}

	$(eval IMAGE=${REGISTRY_DRUPAL}:dev-${VERSION_TAG})
	docker manifest create ${IMAGE} --amend ${IMAGE}-arm64 --amend ${IMAGE}-amd64
	docker manifest push ${IMAGE}

	$(eval IMAGE=${REGISTRY_DRUPAL}:dev-${VERSION_TAG})
	docker manifest create ${IMAGE} --amend ${IMAGE}-arm64 --amend ${IMAGE}-amd64
	docker manifest push ${IMAGE}

.PHONY: *
