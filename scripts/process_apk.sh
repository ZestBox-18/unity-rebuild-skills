#!/bin/bash
# Main script to process APK and create Unity project
# Usage: ./process_apk.sh <apk_path> [output_dir]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Log function
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check arguments
if [ -z "$1" ]; then
    log_error "Usage: $0 <apk_path> [output_dir]"
    exit 1
fi

APK_PATH="$1"
OUTPUT_DIR="${2:-$HOME/apk_output}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Validate APK file
if [ ! -f "$APK_PATH" ]; then
    log_error "APK file not found: $APK_PATH"
    exit 1
fi

log_info "APK file: $APK_PATH"
log_info "Output directory: $OUTPUT_DIR"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Step 1: Start AssetRipper
log_info "Step 1: Starting AssetRipper..."
source "$SCRIPT_DIR/start_assetripper.sh"

# Wait for AssetRipper to be ready
sleep 5

# Step 2: Load and process APK
log_info "Step 2: Loading APK file..."
LOAD_RESPONSE=$(curl -s -X POST \
    -F "Path=$APK_PATH" \
    "http://localhost:$ASSRIPPER_PORT/Commands/LoadFile")

if [ -z "$LOAD_RESPONSE" ]; then
    log_warn "No response from AssetRipper, but this might be normal"
fi

# Wait for processing
log_info "Waiting for APK processing to complete..."
sleep 10

# Step 3: Export Unity project
log_info "Step 3: Exporting Unity project..."
EXPORT_DIR="$OUTPUT_DIR/assetripper_export"
mkdir -p "$EXPORT_DIR"

EXPORT_RESPONSE=$(curl -s -X POST \
    -F "Path=$EXPORT_DIR" \
    -F "CreateSubfolder=false" \
    "http://localhost:$ASSRIPPER_PORT/Commands/ExportUnityProject")

sleep 5

# Step 4: Create Unity project
log_info "Step 4: Creating Unity project structure..."
UNITY_PROJECT_DIR="$OUTPUT_DIR/UnityProject"
source "$SCRIPT_DIR/create_unity_project.sh" "$EXPORT_DIR" "$UNITY_PROJECT_DIR"

# Step 5: Compress results
log_info "Step 5: Compressing results..."
source "$SCRIPT_DIR/compress_results.sh" "$OUTPUT_DIR"

# Step 6: Cleanup
log_info "Step 6: Stopping AssetRipper..."
pkill -f "AssetRipper.GUI.Free"

log_info "Process completed successfully!"
log_info "Results:"
log_info "  - Raw export: $OUTPUT_DIR/raw_export.zip"
log_info "  - Unity project: $OUTPUT_DIR/unity_project.zip"
