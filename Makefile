# Turbifier Makefile

# Variables
BINARY_NAME=turbifier
RELEASE_BINARY=release
VERSION?=v1.0.0
BUILD_DIR=dist
MAIN_PKG=./cmd/turbifier
RELEASE_PKG=./cmd/release

# Go parameters
GOCMD=go
GOBUILD=$(GOCMD) build
GOCLEAN=$(GOCMD) clean
GOTEST=$(GOCMD) test
GOGET=$(GOCMD) get
GOMOD=$(GOCMD) mod
GOFMT=$(GOCMD) fmt

# Build flags
LDFLAGS=-ldflags "-X main.version=$(VERSION) -X main.buildDate=$(shell date -u +%Y-%m-%dT%H:%M:%SZ) -X main.gitCommit=$(shell git rev-parse --short HEAD) -s -w"

.PHONY: all build clean test coverage deps fmt lint run install help release

## all: Default target - build the project
all: clean deps build

## build: Build the binary for current platform
build:
	@echo "Building $(BINARY_NAME)..."
	$(GOBUILD) $(LDFLAGS) -o $(BINARY_NAME) $(MAIN_PKG)
	@echo "✓ Build complete: ./$(BINARY_NAME)"

## clean: Remove build artifacts
clean:
	@echo "Cleaning..."
	$(GOCLEAN)
	rm -rf $(BUILD_DIR)
	rm -f $(BINARY_NAME)
	rm -f $(RELEASE_BINARY)
	rm -f install.sh
	@echo "✓ Cleaned"

## test: Run tests
test:
	@echo "Running tests..."
	$(GOTEST) -v ./...

## coverage: Run tests with coverage
coverage:
	@echo "Running tests with coverage..."
	$(GOTEST) -v -coverprofile=coverage.out ./...
	$(GOCMD) tool cover -html=coverage.out -o coverage.html
	@echo "✓ Coverage report: coverage.html"

## deps: Install dependencies
deps:
	@echo "Installing dependencies..."
	$(GOMOD) download
	$(GOMOD) tidy
	@echo "✓ Dependencies installed"

## fmt: Format code
fmt:
	@echo "Formatting code..."
	$(GOFMT) ./...
	@echo "✓ Code formatted"

## lint: Run linter
lint:
	@echo "Running linter..."
	@if command -v golangci-lint >/dev/null 2>&1; then \
		golangci-lint run ./...; \
	else \
		echo "golangci-lint not installed. Install: go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest"; \
	fi

## run: Build and run
run: build
	./$(BINARY_NAME)

## install: Install binary to /usr/local/bin
install: build
	@echo "Installing to /usr/local/bin..."
	@if [ -w /usr/local/bin ]; then \
		mv $(BINARY_NAME) /usr/local/bin/; \
	else \
		sudo mv $(BINARY_NAME) /usr/local/bin/; \
	fi
	@echo "✓ Installed: /usr/local/bin/$(BINARY_NAME)"

## release: Build release tool and create release
release: build-release
	@echo "Creating release $(VERSION)..."
	./$(RELEASE_BINARY) $(VERSION)

## build-release: Build the release tool
build-release:
	@echo "Building release tool..."
	$(GOBUILD) -o $(RELEASE_BINARY) $(RELEASE_PKG)
	@echo "✓ Release tool built: ./$(RELEASE_BINARY)"

## build-all: Build for all platforms
build-all: clean
	@echo "Building for all platforms..."
	@mkdir -p $(BUILD_DIR)
	@echo "Building linux/amd64..."
	@GOOS=linux GOARCH=amd64 CGO_ENABLED=0 $(GOBUILD) $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)-linux-amd64 $(MAIN_PKG)
	@echo "Building linux/arm64..."
	@GOOS=linux GOARCH=arm64 CGO_ENABLED=0 $(GOBUILD) $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)-linux-arm64 $(MAIN_PKG)
	@echo "Building darwin/amd64..."
	@GOOS=darwin GOARCH=amd64 CGO_ENABLED=0 $(GOBUILD) $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)-darwin-amd64 $(MAIN_PKG)
	@echo "Building darwin/arm64..."
	@GOOS=darwin GOARCH=arm64 CGO_ENABLED=0 $(GOBUILD) $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)-darwin-arm64 $(MAIN_PKG)
	@echo "Building windows/amd64..."
	@GOOS=windows GOARCH=amd64 CGO_ENABLED=0 $(GOBUILD) $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)-windows-amd64.exe $(MAIN_PKG)
	@echo "Building windows/arm64..."
	@GOOS=windows GOARCH=arm64 CGO_ENABLED=0 $(GOBUILD) $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)-windows-arm64.exe $(MAIN_PKG)
	@echo "✓ All builds complete in $(BUILD_DIR)/"
	@ls -lh $(BUILD_DIR)/

## docker-build: Build Docker image
docker-build:
	@echo "Building Docker image..."
	docker build -t $(BINARY_NAME):$(VERSION) .
	@echo "✓ Docker image built: $(BINARY_NAME):$(VERSION)"

## setup: Setup development environment
setup:
	@echo "Setting up development environment..."
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo "✓ Created .env from template"; \
	else \
		echo "✓ .env already exists"; \
	fi
	@if [ ! -f config.toml ]; then \
		./$(BINARY_NAME) init 2>/dev/null || echo "Run 'make build' first, then 'make setup'"; \
	fi
	@if [ ! -f emails.txt ]; then \
		cp emails.txt.example emails.txt; \
		echo "✓ Created emails.txt from template"; \
	fi
	@echo "✓ Setup complete. Edit .env, config.toml, and emails.txt"

## help: Show this help message
help:
	@echo "Turbifier - Build Commands"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' | sed -e 's/^/ /'
	@echo ""
	@echo "Examples:"
	@echo "  make build              # Build for current platform"
	@echo "  make build-all          # Build for all platforms"
	@echo "  make test               # Run tests"
	@echo "  make install            # Install to /usr/local/bin"
	@echo "  make release VERSION=v1.0.0  # Create release"