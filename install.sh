#!/bin/bash
# Install AssetRipper for the current platform
# This script detects the OS and downloads the appropriate version

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$SCRIPT_DIR/.assetripper"

# Detect OS and Architecture
detect_platform() {
    OS="$(uname -s)"
    ARCH="$(uname -m)"
    
    case "$OS" in
        Linux*)   
            OS_NAME="linux"
            ;;
        Darwin*)  
            OS_NAME="mac"
            ;;
        MINGW*|MSYS*|CYGWIN*)
            OS_NAME="win"
            ;;
        *)
            log_error "Unsupported OS: $OS"
            exit 1
            ;;
    esac
    
    case "$ARCH" in
        x86_64|amd64)
            ARCH_NAME="x64"
            ;;
        arm64|aarch64)
            ARCH_NAME="arm64"
            ;;
        *)
            log_error "Unsupported architecture: $ARCH"
            exit 1
            ;;
    esac
    
    PLATFORM="${OS_NAME}_${ARCH_NAME}"
    log_info "Detected platform: $PLATFORM"
}

# Download AssetRipper
download_assetripper() {
    log_step "Downloading AssetRipper for $PLATFORM..."
    
    # Map platform to AssetRipper download URL
    case "$PLATFORM" in
        linux_x64)
            DOWNLOAD_URL="https://github.com/AssetRipper/AssetRipper/releases/latest/download/AssetRipper_linux_x64.zip"
            ;;
        linux_arm64)
            DOWNLOAD_URL="https://github.com/AssetRipper/AssetRipper/releases/latest/download/AssetRipper_linux_arm64.zip"
            ;;
        mac_x64)
            DOWNLOAD_URL="https://github.com/AssetRipper/AssetRipper/releases/latest/download/AssetRipper_mac_x64.zip"
            ;;
        mac_arm64)
            DOWNLOAD_URL="https://github.com/AssetRipper/AssetRipper/releases/latest/download/AssetRipper_mac_arm64.zip"
            ;;
        win_x64)
            DOWNLOAD_URL="https://github.com/AssetRipper/AssetRipper/releases/latest/download/AssetRipper_win_x64.zip"
            ;;
        win_arm64)
            DOWNLOAD_URL="https://github.com/AssetRipper/AssetRipper/releases/latest/download/AssetRipper_win_arm64.zip"
            ;;
        *)
            log_error "No download available for platform: $PLATFORM"
            exit 1
            ;;
    esac
    
    # Create install directory
    mkdir -p "$INSTALL_DIR"
    
    # Download
    TEMP_FILE="/tmp/AssetRipper_${PLATFORM}.zip"
    log_info "Downloading from: $DOWNLOAD_URL"
    
    if command -v wget &> /dev/null; then
        wget -O "$TEMP_FILE" "$DOWNLOAD_URL"
    elif command -v curl &> /dev/null; then
        curl -L -o "$TEMP_FILE" "$DOWNLOAD_URL"
    else
        log_error "Neither wget nor curl is available. Please install one of them."
        exit 1
    fi
    
    # Extract
    log_step "Extracting AssetRipper..."
    if command -v unzip &> /dev/null; then
        unzip -q "$TEMP_FILE" -d "$INSTALL_DIR"
    else
        log_error "unzip is not available. Please install unzip."
        exit 1
    fi
    
    # Cleanup
    rm "$TEMP_FILE"
    
    # Make executable (Unix-like systems)
    if [[ "$OS_NAME" != "win" ]]; then
        chmod +x "$INSTALL_DIR"/AssetRipper.GUI.Free 2>/dev/null || true
        chmod +x "$INSTALL_DIR"/AssetRipper.GUI.Free.exe 2>/dev/null || true
    fi
    
    log_info "AssetRipper installed successfully at: $INSTALL_DIR"
}

# Verify installation
verify_installation() {
    log_step "Verifying installation..."
    
    if [[ "$OS_NAME" == "win" ]]; then
        EXECUTABLE="$INSTALL_DIR/AssetRipper.GUI.Free.exe"
    else
        EXECUTABLE="$INSTALL_DIR/AssetRipper.GUI.Free"
    fi
    
    if [ -f "$EXECUTABLE" ]; then
        log_info "✓ AssetRipper executable found"
        log_info "  Location: $EXECUTABLE"
        
        # Get version
        if [[ "$OS_NAME" != "win" ]]; then
            VERSION=$("$EXECUTABLE" --version 2>&1 | head -1 || echo "Unknown")
            log_info "  Version: $VERSION"
        fi
    else
        log_error "✗ AssetRipper executable not found"
        exit 1
    fi
}

# Main
main() {
    log_info "Installing AssetRipper..."
    log_info "Install directory: $INSTALL_DIR"
    
    # Check if already installed
    if [ -d "$INSTALL_DIR" ]; then
        log_warn "AssetRipper is already installed at: $INSTALL_DIR"
        read -p "Reinstall? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Installation cancelled"
            exit 0
        fi
        rm -rf "$INSTALL_DIR"
    fi
    
    detect_platform
    download_assetripper
    verify_installation
    
    echo ""
    log_info "========================================="
    log_info "Installation completed successfully!"
    log_info "========================================="
    log_info "You can now use the skill to process APK files:"
    log_info "  ./scripts/process_apk.sh /path/to/game.apk"
}

main "$@"
