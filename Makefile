GOOS ?= $(shell go env GOOS)
GOARCH ?= $(shell go env GOARCH)
GOPATH ?= $(shell go env GOPATH)
GOBUILD ?= GOOS=$(GOOS) GOARCH=$(GOARCH) CGO_ENABLED=0 go build
GOFILES ?= $(shell find . -name "*.go")
GOLANGCI_LINT_VERSION ?= 1.45.2
LDFLAGS ?= '-s -w \
	-X "github.com/ks6088ts/barcoder/internal.Revision=$(shell git rev-parse --short HEAD)" \
	-X "github.com/ks6088ts/barcoder/internal.Version=$(shell git describe --tags $$(git rev-list --tags --max-count=1))" \
'

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
.DEFAULT_GOAL := help

.PHONY: install-deps-dev
install-deps-dev: ## install dependencies for development
	@# https://github.com/spf13/cobra-cli/blob/main/README.md
	which cobra-cli || go install github.com/spf13/cobra-cli@latest
	@# https://golangci-lint.run/usage/install/#linux-and-windows
	which golangci-lint || curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(GOPATH)/bin v$(GOLANGCI_LINT_VERSION)

.PHONY: format
format: ## format codes
	gofmt -s -w $(GOFILES)

.PHONY: lint
lint: ## lint
	golangci-lint run -v

.PHONY: test
test: ## run tests
	go test -cover -v ./...

.PHONY: build
build: ## build
	$(GOBUILD) -ldflags=$(LDFLAGS) -o dist/barcoder .

.PHONY: test-run
test-run: ## tests for running cli
	./dist/barcoder --help

.PHONY: ci-test
ci-test: install-deps-dev lint test build test-run ## run ci tests
