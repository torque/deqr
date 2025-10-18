DOCKER_REGISTRY := ghcr.io
DOCKER_PROJECT := torque/deqr
REGISTRY_PREFIX := $(DOCKER_REGISTRY)/$(DOCKER_PROJECT)
IMAGE_BASENAME := $(REGISTRY_PREFIX)/linux-build

.PHONY: all
all:
	@echo Build and push images containing multi-python linux build environments.
	@echo
	@echo Usage:
	@echo "    make <libc>@<arch> "#" build an individual image e.g. for local testing"
	@echo "    make push-<libc>@<arch> "#" build and push an individual image"
	@echo "    make push "#" build all images"
	@echo "    make push "#" build and push all images"
	@echo
	@echo Available libc:
	@echo "    - glibc"
	@echo "    - musl"
	@echo
	@echo Available arch:
	@echo "    - aarch64"
	@echo "    - x86_64"

.PHONY: glibc@aarch64
glibc@aarch64:
	@echo ">> Pulling base image for $@"
	@docker pull quay.io/pypa/manylinux_2_28_aarch64:latest
	@echo ">> Building build image for $@"
	@docker build \
		--progress=plain \
		-f "manylinux.Dockerfile" \
		--build-arg "ARCHITECTURE=2_28_aarch64" \
		-t "$(IMAGE_BASENAME):manylinux_2_28_aarch64" ../..
	@echo ">> Tagged $(IMAGE_BASENAME):manylinux_2_28_aarch64"

.PHONY: push-glibc@aarch64
push-glibc@aarch64: glibc@aarch64
	@echo ">> Pushing $(IMAGE_BASENAME):manylinux_2_28_aarch64"
	@docker push $(IMAGE_BASENAME):manylinux_2_28_aarch64
	@echo ">> Pushed $(IMAGE_BASENAME):manylinux_2_28_aarch64"

.PHONY: glibc@x86_64
glibc@x86_64:
	@echo ">> Pulling base image for $@"
	@docker pull quay.io/pypa/manylinux_2_28_x86_64:latest
	@echo ">> Building build image for $@"
	@docker build \
		--progress=plain \
		-f "manylinux.Dockerfile" \
		--build-arg "ARCHITECTURE=2_28_x86_64" \
		-t "$(IMAGE_BASENAME):manylinux_2_28_x86_64" ../..
	@echo ">> Tagged $(IMAGE_BASENAME):manylinux_2_28_x86_64"

.PHONY: push-glibc@x86_64
push-glibc@x86_64: glibc@x86_64
	@echo ">> Pushing $(IMAGE_BASENAME):manylinux_2_28_x86_64"
	@docker push $(IMAGE_BASENAME):manylinux_2_28_x86_64
	@echo ">> Pushed $(IMAGE_BASENAME):manylinux_2_28_x86_64"

.PHONY: musl@aarch64
musl@aarch64:
	@echo ">> Pulling base image for $@"
	@docker pull quay.io/pypa/musllinux_1_2_aarch64:latest
	@echo ">> Building build image for $@"
	@docker build \
		--progress=plain \
		-f "musllinux.Dockerfile" \
		--build-arg "ARCHITECTURE=1_2_aarch64" \
		-t "$(IMAGE_BASENAME):musllinux_1_2_aarch64" ../..
	@echo ">> Tagged $(IMAGE_BASENAME):musllinux_1_2_aarch64"

.PHONY: push-musl@aarch64
push-musl@aarch64: musl@aarch64
	@echo ">> Pushing $(IMAGE_BASENAME):musllinux_1_2_aarch64"
	@docker push $(IMAGE_BASENAME):musllinux_1_2_aarch64
	@echo ">> Pushed $(IMAGE_BASENAME):musllinux_1_2_aarch64"

.PHONY: musl@x86_64
musl@x86_64:
	@echo ">> Pulling base image for $@"
	@docker pull quay.io/pypa/musllinux_1_2_x86_64:latest
	@echo ">> Building build image for $@"
	@docker build \
		--progress=plain \
		-f "musllinux.Dockerfile" \
		--build-arg "ARCHITECTURE=1_2_x86_64" \
		-t "$(IMAGE_BASENAME):musllinux_1_2_x86_64" ../..
	@echo ">> Tagged $(IMAGE_BASENAME):musllinux_1_2_x86_64"

.PHONY: push-musl@x86_64
push-musl@x86_64: musl@x86_64
	@echo ">> Pushing $(IMAGE_BASENAME):musllinux_1_2_x86_64"
	@docker push $(IMAGE_BASENAME):musllinux_1_2_x86_64
	@echo ">> Pushed $(IMAGE_BASENAME):musllinux_1_2_x86_64"

.PHONY: build
build: glibc@aarch64 glibc@x86_64 musl@aarch64 musl@x86_64
.PHONY: push
push: push-glibc@aarch64 push-glibc@x86_64 push-musl@aarch64 push-musl@x86_64
