#!/usr/bin/make -f

REGISTRY_BASE=skpr/nginx
REGISTRY_PHP_FPM=skpr/nginx-php-fpm
REGISTRY_DRUPAL=skpr/nginx-drupal

VERSION_TAG=v2-latest
ARCH=amd64

build:
	# Building Base
	$(eval IMAGE=${REGISTRY_BASE}:${VERSION_TAG}-${ARCH})
	docker build -t ${IMAGE} base
	docker run -it --rm --hostname=php-fpm --read-only ${IMAGE} nginx -t

	# Building PHP-FPM
	$(eval IMAGE=${REGISTRY_PHP_FPM}:${VERSION_TAG}-${ARCH})
	docker build --build-arg FROM_IMAGE=${REGISTRY_BASE}:${VERSION_TAG}-${ARCH} -t ${IMAGE} php-fpm
	docker run -it --rm --hostname=php-fpm --read-only ${IMAGE} nginx -t

	# Building PHP-FPM (Dev)
	$(eval IMAGE=${REGISTRY_PHP_FPM}:dev-${VERSION_TAG}-${ARCH})
	docker build --build-arg FROM_IMAGE=${REGISTRY_PHP_FPM}:${VERSION_TAG}-${ARCH} -t ${IMAGE} php-fpm/dev
	docker run -it --rm --hostname=php-fpm --read-only ${IMAGE} nginx -t

	# Building Drupal
	$(eval IMAGE=${REGISTRY_DRUPAL}:${VERSION_TAG}-${ARCH})
	docker build --build-arg FROM_IMAGE=${REGISTRY_PHP_FPM}:${VERSION_TAG}-${ARCH} -t ${IMAGE} drupal
	docker run -it --rm --hostname=php-fpm --read-only ${IMAGE} nginx -t

	# Building Drupal (Dev)
	$(eval IMAGE=${REGISTRY_DRUPAL}:dev-${VERSION_TAG}-${ARCH})
	docker build --build-arg FROM_IMAGE=${REGISTRY_DRUPAL}:${VERSION_TAG}-${ARCH} -t ${IMAGE} php-fpm/dev
	docker run -it --rm --hostname=php-fpm --read-only ${IMAGE} nginx -t

push:
	docker push ${REGISTRY_BASE}:${VERSION_TAG}-${ARCH}
	docker push ${REGISTRY_PHP_FPM}:${VERSION_TAG}-${ARCH}
	docker push ${REGISTRY_PHP_FPM}:dev-${VERSION_TAG}-${ARCH}
	docker push ${REGISTRY_DRUPAL}:${VERSION_TAG}-${ARCH}
	docker push ${REGISTRY_DRUPAL}:dev-${VERSION_TAG}-${ARCH}

manifest:
	$(eval IMAGE=${REGISTRY_BASE}:${VERSION_TAG})
	docker manifest create ${IMAGE} --amend ${IMAGE}-arm64 --amend ${IMAGE}-amd64
	docker manifest push ${IMAGE}

	$(eval IMAGE=${REGISTRY_PHP_FPM}:${VERSION_TAG})
	docker manifest create ${IMAGE} --amend ${IMAGE}-arm64 --amend ${IMAGE}-amd64
	docker manifest push ${IMAGE}

	$(eval IMAGE=${REGISTRY_DRUPAL}:${VERSION_TAG})
	docker manifest create ${IMAGE} --amend ${IMAGE}-arm64 --amend ${IMAGE}-amd64
	docker manifest push ${IMAGE}

	$(eval IMAGE=${REGISTRY_PHP_FPM}:dev-${VERSION_TAG})
	docker manifest create ${IMAGE} --amend ${IMAGE}-arm64 --amend ${IMAGE}-amd64
	docker manifest push ${IMAGE}

	$(eval IMAGE=${REGISTRY_DRUPAL}:dev-${VERSION_TAG})
	docker manifest create ${IMAGE} --amend ${IMAGE}-arm64 --amend ${IMAGE}-amd64
	docker manifest push ${IMAGE}

.PHONY: *
