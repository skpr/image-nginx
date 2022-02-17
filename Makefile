#!/usr/bin/make -f

REGISTRY=skpr/nginx
VERSION_TAG=v2-latest
ARCH=amd64

build:
	docker build -t ${REGISTRY}:${VERSION_TAG}-${ARCH} .
	docker run -it --rm --hostname=php-fpm --read-only ${REGISTRY}:${VERSION_TAG}-${ARCH} nginx -t
	docker build --build-arg VERSION_TAG=${VERSION_TAG} -t ${REGISTRY}:${VERSION_TAG}-dev-${ARCH} dev
	docker run -it --rm --hostname=php-fpm --read-only ${REGISTRY}:${VERSION_TAG}-dev-${ARCH} nginx -t

push:
	docker push ${REGISTRY}:${VERSION_TAG}-${ARCH}
	docker push ${REGISTRY}:${VERSION_TAG}-dev-${ARCH}

manifest:
	$(eval IMAGE=${REGISTRY}:${VERSION_TAG})
	docker manifest create ${IMAGE} --amend ${IMAGE}-arm64 --amend ${IMAGE}-amd64
	docker manifest push ${IMAGE}

.PHONY: *
