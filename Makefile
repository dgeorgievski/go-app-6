
TAG ?= dev
NAME := go-app-6
GITHUB_ORG=dgeorgievski
GITHUB_REPO=github.com/$(GITHUB_ORG)/$(NAME)
DOCKER_REPOSITORY:=dgeorgievski
DOCKER_IMAGE_NAME:=$(DOCKER_REPOSITORY)/$(NAME)
GIT_COMMIT:=$(shell git rev-list --abbrev-commit -1 HEAD)
VERSION:=$(shell grep 'var VERSION' pkg/version/version.go | awk '{ print $$4 }' | tr -d '"')
EXTRA_RUN_ARGS?=
UNIX_DATE=$(shell date +%s%M)

# docker push registry.gitlab.casa-systems.com/dimitar.georgievski/5g-metrics
run:
	go run main.go  $(EXTRA_RUN_ARGS)

.PHONY: test
test:
	go test ./... -coverprofile cover.out

build:
	@rm -fr bin/* && \
	go build \
	-ldflags "-s -w  \
		-X $(GITHUB_REPO)/pkg/version.VERSION=$(TAG) \
		-X $(GITHUB_REPO)/pkg/version.COMMIT=$(GIT_COMMIT) \
		-X $(GITHUB_REPO)/pkg/version.DATE=$(UNIX_DATE)" \
	-o ./bin/${NAME}

	@echo "Build availalbe at ./bin/${NAME}"

tidy:
	go mod tidy

fmt:
	gofmt -l -s -w ./

docker-build:
	docker build \
	--build-arg VERSION="$(VERSION)" \
	--build-arg COMMIT="$(GIT_COMMIT)" \
	--build-arg BUILD_UNIX_TIME="$(UNIX_DATE)" \
	-f docker/Dockerfile \
	 -t $(DOCKER_IMAGE_NAME):$(VERSION) .

docker-test:
	@echo "Coming soon"

docker-push:
	# docker push $(DOCKER_IMAGE_NAME):$(VERSION)
	@echo "Coming soon"

kind-docker-upload: docker-build
	 kind --name hello load docker-image $(DOCKER_IMAGE_NAME):$(VERSION)

version-set:
	# @next="$(TAG)" && \
	# current="$(VERSION)" && \
	# /usr/bin/sed -i "s/$$current/$$next/g" pkg/version/version.go && \
	# /usr/bin/sed -i "s/hello:$$current/hello:$$next/g" deploy/manifests/deployment.yaml && \
	# echo "Version $$next set in code and manifests"
	@echo "Coming soon"
	
version-get:
	@echo "Current version $(VERSION)"

tag:
	git tag $(VERSION)
	git push origin $(VERSION)

get-env:
	@echo "TAG: $(TAG)"
	@echo "NAME: $(NAME)" 
	@echo "DOCKER_REPOSITORY: $(DOCKER_REPOSITORY)" 
	@echo "DOCKER_IMAGE_NAME: $(DOCKER_IMAGE_NAME)"
	@echo "GIT_COMMIT: $(GIT_COMMIT)"
	@echo "VERSION: $(VERSION)"
	@echo "EXTRA_RUN_ARGS: $(EXTRA_RUN_ARGS)"

