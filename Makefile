.PHONY: images test

VERSION = 1.0.0
SERVICE = jenca-library
HUBACCOUNT = jenca

ROOT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

images: build

# build the docker images
# the dev version includes development node modules
devimage:
	docker rmi $(HUBACCOUNT)/$(SERVICE):$(VERSION)-dev || true
	docker build -f Dockerfile.dev -t $(HUBACCOUNT)/$(SERVICE):latest-dev .
	docker tag $(HUBACCOUNT)/$(SERVICE):latest-dev $(HUBACCOUNT)/$(SERVICE):$(VERSION)-dev
	@docker run -ti --rm \
		--entrypoint "bash" \
		-v $(PWD)/src/api:/srv/app \
		$(HUBACCOUNT)/$(SERVICE):$(VERSION) -c "cd /srv/app && npm install"

prodimage:
	docker rmi $(HUBACCOUNT)/$(SERVICE):$(VERSION) || true
	mkdir -p $(ROOT_DIR)/dist
	docker build -f Dockerfile -t $(HUBACCOUNT)/$(SERVICE):latest .
	docker tag $(HUBACCOUNT)/$(SERVICE):latest $(HUBACCOUNT)/$(SERVICE):$(VERSION)

test:
	docker run -ti --rm \
		$(HUBACCOUNT)/$(SERVICE):$(VERSION)-dev test

build.dist:
	docker run -ti --rm \
	  -v $(ROOT_DIR)/src:/app/src \
	  -v $(ROOT_DIR)/dist:/app/dist \
		$(HUBACCOUNT)/$(SERVICE):$(VERSION)-dev release

build: devimage build.dist prodimage