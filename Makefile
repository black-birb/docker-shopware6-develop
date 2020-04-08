VERSION := $(shell cat VERSION)
CONTAINER_NAME := $(shell basename $(shell pwd))
REGISTRY_SERVER := docker-registry.test.etribes.de:5000

.PHONY: build
.PHONY: login
.PHONY: push
.PHONY: default

default: build ;

build:
	docker build . -f Dockerfile -t ${REGISTRY_SERVER}/${CONTAINER_NAME}:${VERSION}

login:
	docker login ${REGISTRY_SERVER}

push: login build
	docker push ${REGISTRY_SERVER}/${CONTAINER_NAME}:${VERSION}
	docker tag ${REGISTRY_SERVER}/${CONTAINER_NAME}:${VERSION} ${REGISTRY_SERVER}/${CONTAINER_NAME}:latest
	docker push ${REGISTRY_SERVER}/${CONTAINER_NAME}:latest
