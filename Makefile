GIT_REVISION ?= $(shell git rev-parse --short HEAD)
GIT_TAG ?= $(shell git describe --tags $$(git rev-list --tags --max-count=1))

GOOS ?= $(shell go env GOOS)
GOARCH ?= $(shell go env GOARCH)
GOPATH ?= $(shell go env GOPATH)
GOBUILD ?= GOOS=$(GOOS) GOARCH=$(GOARCH) CGO_ENABLED=0 go build
GOFILES ?= $(shell find . -name "*.go")
GOLANGCI_LINT_VERSION ?= 1.45.2
LDFLAGS ?= '-s -w \
	-X "github.com/ks6088ts/barcoder/internal.Revision=$(GIT_REVISION)" \
	-X "github.com/ks6088ts/barcoder/internal.Version=$(GIT_TAG)" \
'
CSV_FILE ?= data/code_list.csv
GENERATED_DIR ?= ./generated

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
test-run: test-run-code2img ## run test

.PHONY: test-run-code2img
test-run-code2img: ## run test for code2img command (todo: binary comparison)
	rm -rf generated/images && mkdir -p generated/images
	for type in code128 code39 code93 datamatrix qr ; do \
			./dist/barcoder code2img --width 250 --height 200 --type $$type --output generated/images/$$type-test.png --code test ; \
	done
	./dist/barcoder code2img --width 250 --height 200 --type codabar   --output generated/images/codabar-A123456789D.png --code A123456789D
	./dist/barcoder code2img --width 250 --height 200 --type ean       --output generated/images/ean-4581171967072.png   --code 4581171967072
	./dist/barcoder code2img --width 250 --height 200 --type twooffive --output generated/images/twooffive-1234.png      --code 1234

.PHONY: ci-test
ci-test: install-deps-dev lint test build test-run ## run ci tests

.PHONY: docker-build
docker-build: ## build Docker image
	docker build -t ks6088ts/barcoder:$(GIT_TAG) .

.PHONY: docker-terminal
docker-terminal: ## run container on terminal
	docker run --rm -it \
		--volume $(PWD)/generated:/root/generated \
		ks6088ts/barcoder:$(GIT_TAG) sh

.PHONY: generate-image
generate-image: ## generate image files
	rm -rf $(GENERATED_DIR)
	mkdir -p $(GENERATED_DIR)
	cat $(CSV_FILE) | xargs -I {} -P3 ./dist/barcoder code2img \
		--height 100 \
		--width 500 \
		--type code128 \
		--output $(GENERATED_DIR)/{}.png \
		--code {}

.PHONY: generate-markdown
generate-markdown: ## generate markdown file
	@cd generated && ls *.png | xargs -I {} echo "{} <img src='./{}' width='100%'>"

.PHONY: generate
generate: generate-image ## generate
	@make generate-markdown > "$(GENERATED_DIR)/sheet.md"
