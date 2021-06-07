DOCKER_REGISTRY := docker.pkg.github.com
DOCKER_PROJECT := torque/deqr

PYTHON_VERSIONS := 3.8 3.9
REGISTRY_PREFIX := $(DOCKER_REGISTRY)/$(DOCKER_PROJECT)
BUILD_ENV_PREFIX := $(REGISTRY_PREFIX)/build-env
GET_BUILD_ENV_TAG = $(addprefix $(BUILD_ENV_PREFIX)@,$(1))
GET_PYTHON_VERSION = $(lastword $(subst @, ,$(1)))
FIX_TAG_FOR_DOCKER = $(subst @,:,$(1))

BUILD_ENV_IMAGES := $(call GET_BUILD_ENV_TAG, $(PYTHON_VERSIONS))
ALL_IMAGES := $(BUILD_ENV_IMAGES)

.PHONY: all push python build-env $(ALL_IMAGES)

all: build-env

push: PUSHCOMMAND = docker push $(1);
push: $(ALL_IMAGES)
	$(foreach image,$(ALL_IMAGES),$(call PUSHCOMMAND,$(call FIX_TAG_FOR_DOCKER,$(image))))

build-env: $(BUILD_ENV_IMAGES)

$(BUILD_ENV_IMAGES): SOURCE_TAG = $(call GET_PYTHON_VERSION,$@)-alpine
$(BUILD_ENV_IMAGES):
	docker pull python:$(SOURCE_TAG)
	docker build \
		-f "build-env.Dockerfile" \
		--build-arg "PYTHON_VERSION=$(SOURCE_TAG)" \
		-t "$(call FIX_TAG_FOR_DOCKER,$@)" ../..
