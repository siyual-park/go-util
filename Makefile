PKG := "github.com/siyual-park/urlutil"
PKG_LIST := $(shell go list ${PKG}/...)

tag:
	@git tag `grep -P '^\tversion = ' echo.go|cut -f2 -d'"'`
	@git tag|grep -v ^v

.DEFAULT_GOAL := check
check: lint vet race ## Check project

init:
	@go install honnef.co/go/tools/cmd/staticcheck@latest

lint: ## Lint the files
	@staticcheck ${PKG_LIST}

vet: ## Vet the files
	@go vet ${PKG_LIST}

test: ## Run tests
	@go test -short ${PKG_LIST}

race: ## Run tests with data race detector
	@go test -race ${PKG_LIST}

coverage: ## Run tests with cover
	@go test -coverprofile coverage.out -covermode count ${PKG_LIST}
	@go tool cover -func=coverage.out | grep total

benchmark: ## Run benchmarks
	@go test -run="-" -bench=".*" -benchmem ${PKG_LIST}

run: ## Run application
	@go run main.go

help: ## Display this help screen
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

goversion ?= "1.18"
test_version: ## Run tests inside Docker with given version (defaults to 1.15 oldest supported). Example: make test_version goversion=1.16
	@docker run --rm -it -v $(shell pwd):/project golang:$(goversion) /bin/sh -c "cd /project && make init check"
