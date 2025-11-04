.PHONY: build run test test-coverage lint fmt vet clean help

BINARY_NAME=api
BUILD_DIR=bin

help: ## Display this help message
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

build: ## Build the application
	@echo "Building..."
	@mkdir -p $(BUILD_DIR)
	go build -o $(BUILD_DIR)/$(BINARY_NAME) cmd/api/main.go
	@echo "✓ Build complete: $(BUILD_DIR)/$(BINARY_NAME)"

run: ## Run the application
	go run cmd/api/main.go

test: ## Run all tests
	go test -v ./...

test-coverage: ## Run tests with coverage report
	go test -cover ./...
	go test -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out -o coverage.html
	@echo "Coverage report generated: coverage.html"

lint: ## Run linter
	@which golangci-lint > /dev/null || (echo "golangci-lint not installed. Install from https://golangci-lint.run/usage/install/" && exit 1)
	golangci-lint run ./...

fmt: ## Format code
	go fmt ./...

vet: ## Run go vet
	go vet ./...

tidy: ## Tidy go modules
	go mod tidy

clean: ## Clean build artifacts
	@echo "Cleaning..."
	@rm -rf $(BUILD_DIR)
	@rm -f coverage.out coverage.html
	@echo "✓ Clean complete"

verify: fmt vet test ## Run format, vet, and tests
	@echo "✓ All checks passed"

docker-build: ## Build Docker image
	docker build -t golang-app:latest .

docker-run: ## Run Docker container
	docker run -p 8080:8080 -e ENVIRONMENT=production golang-app:latest

