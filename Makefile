BUILD_PATH := cmd/jocko/jocko
DOCKER_TAG := latest

all: test

vendor:
	@go mod vendor

vet:
	@go list ./... | grep -v vendor | xargs go vet

build: vendor
	@go build -o $(BUILD_PATH) cmd/jocko/main.go

release:
	@which goreleaser 2>/dev/null || go get -u github.com/goreleaser/goreleaser
	@goreleaser

clean:
	@rm -rf dist

build-docker:
	@docker build -t travisjeffery/jocko:$(DOCKER_TAG) .

tag-docker:
	@docker tag travisjeffery/jocko:$(DOCKER_TAG) $(DOCKER_ACC)/$(DOCKER_REPO):$(DOCKER_TAG)

push-docker: build-docker tag-docker
	@docker push $(DOCKER_ACC)/$(DOCKER_REPO):$(DOCKER_TAG)

generate:
	@go generate

test:
	@go test -v ./...

test-race:
	@go test -v -race -p=1 ./...

.PHONY: test-race test build-docker clean release build vendor vet all
