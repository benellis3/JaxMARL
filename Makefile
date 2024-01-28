NVCC_RESULT := $(shell which nvcc 2> NULL; rm NULL)
NVCC_TEST := $(notdir $(NVCC_RESULT))
# ifeq ($(NVCC_TEST),nvcc)
# GPUS=--gpus all
# else
# GPUS=
# endif
WANDB_API_KEY := $(shell cat ${HOME}/.oxwhirl_wandb_api_key)

# Set flag for docker run command
BASE_FLAGS=--rm -e WANDB_API_KEY=$(WANDB_API_KEY) -v ${PWD}:/home/workdir --shm-size 20G
RUN_FLAGS=--gpus device=$(GPUS) $(BASE_FLAGS)

DOCKER_IMAGE_NAME = jaxmarl
IMAGE = $(DOCKER_IMAGE_NAME):latest
DOCKER_RUN=docker run $(RUN_FLAGS) $(IMAGE)
USE_CUDA = $(if $(GPUS),true,false)

# make file commands
build:
	DOCKER_BUILDKIT=1 docker build --build-arg USE_CUDA=$(USE_CUDA) --tag $(IMAGE) --progress=plain ${PWD}/.

run:
	$(DOCKER_RUN) /bin/bash -c "$(CMD)"

test:
	$(DOCKER_RUN) /bin/bash -c "pytest ./tests/"

