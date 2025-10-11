#!/bin/bash
# Turbifier Installation Script for Linux/macOS
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

REPO="yq-app/turbifier"
INSTALL_DIR="/usr/local/bin"
BINARY_NAME="turbifier"

echo -e "${CYAN}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
echo -e "${CYAN}┃      Turbifier Installer         ┃${NC}"
echo -e "${CYAN}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
echo ""

# Get latest release version
echo -e "${YELLOW}→ Fetching latest release...${NC}"
VERSION=$(curl -s "https://api.github.com/repos/${REPO}/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

if [ -z "$VERSION" ]; then
    echo -e "${RED}✗ Failed to fetch latest version${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Latest version: ${VERSION}${NC}"
echo ""

# Detect OS and architecture
OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"

case "$ARCH" in
    x86_64) ARCH="amd64" ;;
    aarch64|arm64) ARCH="arm64" ;;
    *)
        echo -e "${RED}✗ Unsupported architecture: $ARCH${NC}"
        exit 1
        ;;
esac

echo -e "${CYAN}Detected:${NC} ${OS}/${ARCH}"

# Construct binary name
BINARY="${BINARY_NAME}-${OS}-${ARCH}"
URL="https://github.com/${REPO}/releases/download/${VERSION}/${BINARY}"

echo ""
echo -e "${YELLOW}→ Downloading ${BINARY}...${NC}"

# Download binary
if command -v curl &> /dev/null; then
    HTTP_CODE=$(curl -fsSL -w "%{http_code}" "$URL" -o "/tmp/${BINARY_NAME}")
    if [ "$HTTP_CODE" != "200" ]; then
        echo -e "${RED}✗ Download failed (HTTP $HTTP_CODE)${NC}"
        echo -e "${RED}  URL: ${URL}${NC}"
        echo -e "${RED}  The binary for your platform may not exist in this release${NC}"
        exit 1
    fi
elif command -v wget &> /dev/null; then
    wget -q --server-response "$URL" -O "/tmp/${BINARY_NAME}" 2>&1 | grep -q "HTTP/.* 200" || {
        echo -e "${RED}✗ Download failed${NC}"
        echo -e "${RED}  URL: ${URL}${NC}"
        echo -e "${RED}  The binary for your platform may not exist in this release${NC}"
        exit 1
    }
else
    echo -e "${RED}✗ Neither curl nor wget found${NC}"
    exit 1
fi

# Verify download
if [ ! -s "/tmp/${BINARY_NAME}" ]; then
    echo -e "${RED}✗ Downloaded file is empty or doesn't exist${NC}"
    exit 1
fi

# Check if it's an HTML error page (GitHub returns 404 as HTML)
if file "/tmp/${BINARY_NAME}" | grep -q "HTML"; then
    echo -e "${RED}✗ Download failed - binary not found in release${NC}"
    echo -e "${RED}  URL: ${URL}${NC}"
    echo -e "${RED}  This platform may not be supported in this release${NC}"
    rm "/tmp/${BINARY_NAME}"
    exit 1
fi

echo -e "${GREEN}✓ Download complete${NC}"

# Make executable
chmod +x "/tmp/${BINARY_NAME}"

# Install
echo ""
echo -e "${YELLOW}→ Installing to ${INSTALL_DIR}...${NC}"

if [ -w "$INSTALL_DIR" ]; then
    mv "/tmp/${BINARY_NAME}" "${INSTALL_DIR}/${BINARY_NAME}"
else
    echo -e "${YELLOW}  Requesting sudo access...${NC}"
    sudo mv "/tmp/${BINARY_NAME}" "${INSTALL_DIR}/${BINARY_NAME}"
fi

echo -e "${GREEN}✓ Installation complete${NC}"
echo ""
echo -e "${CYAN}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
echo -e "${CYAN}┃   Installation Successful! ✓     ┃${NC}"
echo -e "${CYAN}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
echo ""
echo -e "${GREEN}${BINARY_NAME}${NC} is now installed at ${INSTALL_DIR}/${BINARY_NAME}"
echo ""
echo -e "${CYAN}Quick Start:${NC}"
echo -e "  1. ${GREEN}${BINARY_NAME} init${NC}           - Create configuration"
echo -e "  2. ${GREEN}${BINARY_NAME} login <token>${NC}  - Authenticate"
echo -e "  3. ${GREEN}${BINARY_NAME} start${NC}          - Start verification"
echo ""
echo -e "${CYAN}Need help?${NC} Run: ${GREEN}${BINARY_NAME} --help${NC}"
echo ""
