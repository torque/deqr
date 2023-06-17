DOCKER_REGISTRY := ghcr.io
DOCKER_PROJECT := torque/deqr

ARCHITECTURES := 2_28_aarch64 2_28_x86_64
REGISTRY_PREFIX := $(DOCKER_REGISTRY)/$(DOCKER_PROJECT)
IMAGE_BASENAME := $(REGISTRY_PREFIX)/linux-build
GET_IMAGE_TAG = $(addprefix $(IMAGE_BASENAME)@,$(1))
GET_ARCHITECTURE = $(lastword $(subst @, ,$(1)))
FIX_TAG_FOR_DOCKER = $(subst @,:,$(1))

GET_PUSH_ARCHITECTURE = $(lastword $(subst -, ,$(1)))
GET_IMAGE_FOR_PUSH = $(addprefix $(IMAGE_BASENAME):,$(call GET_PUSH_ARCHITECTURE,$(1)))
PUSH_COMMAND = docker push $(1);

BUILD_ENV_IMAGES := $(call GET_IMAGE_TAG,$(ARCHITECTURES))
ALL_IMAGES := $(BUILD_ENV_IMAGES)

.SECONDEXPANSION:
.PHONY: all push $(addprefix push-,$(ARCHITECTURES)) $(ARCHITECTURES) $(ALL_IMAGES)

all: $(ALL_IMAGES)

push: $(ALL_IMAGES)
	$(foreach image,$(ALL_IMAGES),$(call PUSH_COMMAND,$(call FIX_TAG_FOR_DOCKER,$(image))))

$(addprefix push-,$(ARCHITECTURES)): $(call GET_PUSH_ARCHITECTURE,$$@)
	$(call PUSH_COMMAND,$(call GET_IMAGE_FOR_PUSH,$@))

$(ARCHITECTURES): $(call GET_IMAGE_TAG,$$@)

$(BUILD_ENV_IMAGES): IMG_ARCHITECTURE = $(call GET_ARCHITECTURE,$@)
$(BUILD_ENV_IMAGES):
	docker pull quay.io/pypa/manylinux_$(IMG_ARCHITECTURE):latest
	docker build \
		--progress=plain \
		-f "build-env.Dockerfile" \
		--build-arg "ARCHITECTURE=$(IMG_ARCHITECTURE)" \
		-t "$(call FIX_TAG_FOR_DOCKER,$@)" ../..
