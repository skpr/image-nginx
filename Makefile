#!/usr/bin/make -f

build:
	docker buildx bake

test:
	$(eval IMAGE=skpr/php-drupal:dev-v3-latest)
	# Start a stack for testing.
	IMAGE=${IMAGE} docker-compose -f drupal/tests/docker-compose.yml up -d
	# Run tests.
	go run drupal/tests/test.go
	# Stop testing stack.
	IMAGE=${IMAGE} docker-compose -f drupal/tests/docker-compose.yml down

.PHONY: *
