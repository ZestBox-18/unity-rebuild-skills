#!/bin/bash
# Process APK file and create Unity project
# Usage: ./process_apk.sh <apk_path> [output_dir]

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
SKILL_ROOT="$SCRIPT_DIR"
ASSRIPPER_DIR="$SKILL_ROOT/.assetripper"

# AssetRipper settings
ASSRIPPER_PORT=${ASSRIPPER_PORT:-5000}
ASSRIPPER_PID=""

# Cleanup function
cleanup() {
    if [ -n "$ASSRIPPER_PID" ] && kill -0 "$ASSRIPPER_PID" 2>/dev/null; then
        log_info "Stopping AssetRipper..."
        kill "$ASSRIPPER_PID" 2>/dev/null || true
    fi
}
trap cleanup EXIT

# Check arguments
if [ -z "$1" ]; then
    log_error "Usage: $0 <apk_path> [output_dir]"
    exit 1
fi

APK_PATH="$1"
OUTPUT_DIR="${2:-./output}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Validate APK file
if [ ! -f "$APK_PATH" ]; then
    log_error "APK file not found: $APK_PATH"
    exit 1
fi

# Get absolute paths
APK_PATH="$(cd "$(dirname "$APK_PATH")" && pwd)/$(basename "$APK_PATH")"
mkdir -p "$OUTPUT_DIR"
OUTPUT_DIR="$(cd "$OUTPUT_DIR" && pwd)"

log_info "========================================="
log_info "APK to Unity Rebuild"
log_info "========================================="
log_info "APK file: $APK_PATH"
log_info "Output directory: $OUTPUT_DIR"
log_info "========================================="

# Step 1: Check/Install AssetRipper
log_step "Step 1: Checking AssetRipper installation..."

if [ ! -d "$ASSRIPPER_DIR" ]; then
    log_warn "AssetRipper not found. Installing..."
    cd "$SKILL_ROOT" && ./install.sh
fi

# Find executable
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    ASSRIPPER_EXE="$ASSRIPPER_DIR/AssetRipper.GUI.Free.exe"
else
    ASSRIPPER_EXE="$ASSRIPPER_DIR/AssetRipper.GUI.Free"
fi

if [ ! -f "$ASSRIPPER_EXE" ]; then
    log_error "AssetRipper executable not found: $ASSRIPPER_EXE"
    log_error "Please run: ./install.sh"
    exit 1
fi

log_info "✓ AssetRipper found: $ASSRIPPER_EXE"

# Step 2: Start AssetRipper
log_step "Step 2: Starting AssetRipper in headless mode..."

# Check if already running
if pgrep -f "AssetRipper.GUI.Free" > /dev/null; then
    log_warn "AssetRipper is already running"
    ASSRIPPER_PORT=$(lsof -i -P 2>/dev/null | grep AssetRipper | grep LISTEN | head -1 | awk '{print $9}' | cut -d: -f2 || echo "5000")
else
    log_info "Starting AssetRipper on port $ASSRIPPER_PORT..."
    nohup "$ASSRIPPER_EXE" --headless --port "$ASSRIPPER_PORT" > /dev/null 2>&1 &
    ASSRIPPER_PID=$!

    # Wait for AssetRipper to start
    log_info "Waiting for AssetRipper to start..."
    for i in {1..30}; do
        if curl -s "http://localhost:$ASSRIPPER_PORT" > /dev/null 2>&1; then
            log_info "✓ AssetRipper is ready (port: $ASSRIPPER_PORT)"
            break
        fi
        if [ $i -eq 30 ]; then
            log_error "AssetRipper failed to start"
            exit 1
        fi
        sleep 1
    done
fi

# Step 3: Load APK
log_step "Step 3: Loading APK file..."
log_info "This may take a while depending on APK size..."

curl -s -X POST --data-urlencode "Path=$APK_PATH" \
    "http://localhost:$ASSRIPPER_PORT/LoadFile" || {
    log_error "Failed to load APK"
    exit 1
}

# Wait for processing
log_info "Processing APK..."
sleep 30

# Step 4: Export Unity project
log_step "Step 4: Exporting Unity project..."

EXPORT_DIR="$OUTPUT_DIR/assetripper_export_$TIMESTAMP"
mkdir -p "$EXPORT_DIR"

curl -s -X POST --data-urlencode "Path=$EXPORT_DIR" \
    "http://localhost:$ASSRIPPER_PORT/Export/UnityProject" || {
    log_error "Failed to export Unity project"
    exit 1
}

sleep 10

log_info "✓ Export completed: $EXPORT_DIR"

# Step 5: Create Unity project structure
log_step "Step 5: Creating Unity project structure..."

UNITY_PROJECT_DIR="$OUTPUT_DIR/UnityProject_$TIMESTAMP"
mkdir -p "$UNITY_PROJECT_DIR"/Assets
mkdir -p "$UNITY_PROJECT_DIR"/ProjectSettings
mkdir -p "$UNITY_PROJECT_DIR"/Packages

# Copy Assets
if [ -d "$EXPORT_DIR/ExportedProject/Assets" ]; then
    log_info "Copying Assets..."
    cp -r "$EXPORT_DIR"/ExportedProject/Assets/* "$UNITY_PROJECT_DIR"/Assets/ 2>/dev/null || true
    ASSETS_COUNT=$(find "$UNITY_PROJECT_DIR"/Assets -type f | wc -l)
    log_info "✓ Copied $ASSETS_COUNT asset files"
else
    log_warn "No Assets folder found in export"
fi

# Copy ProjectSettings
if [ -d "$EXPORT_DIR/ExportedProject/ProjectSettings" ]; then
    log_info "Copying ProjectSettings..."
    cp -r "$EXPORT_DIR"/ExportedProject/ProjectSettings/* "$UNITY_PROJECT_DIR"/ProjectSettings/ 2>/dev/null || true
fi

# Create default ProjectSettings if needed
if [ ! -f "$UNITY_PROJECT_DIR/ProjectSettings/ProjectSettings.asset" ]; then
    log_info "Creating default ProjectSettings..."
    cp "$SKILL_ROOT"/templates/ProjectSettings/* "$UNITY_PROJECT_DIR"/ProjectSettings/ 2>/dev/null || true
fi

# Create Packages/manifest.json
cat > "$UNITY_PROJECT_DIR/Packages/manifest.json" << 'EOF'
{
  "dependencies": {
    "com.unity.collab-proxy": "1.17.7",
    "com.unity.feature.development": "1.0.1",
    "com.unity.render-pipelines.universal": "12.1.7",
    "com.unity.textmeshpro": "3.0.6",
    "com.unity.timeline": "1.6.4",
    "com.unity.ugui": "1.0.0",
    "com.unity.visualscripting": "1.7.6"
  }
}
EOF

log_info "✓ Unity project created: $UNITY_PROJECT_DIR"

# Step 6: Compress results
log_step "Step 6: Compressing results..."

cd "$OUTPUT_DIR"

# Compress raw export
log_info "Creating raw_export_$TIMESTAMP.zip..."
zip -rq "raw_export_$TIMESTAMP.zip" "$(basename "$EXPORT_DIR")"
RAW_SIZE=$(du -sh "raw_export_$TIMESTAMP.zip" | cut -f1)
log_info "✓ raw_export_$TIMESTAMP.zip ($RAW_SIZE)"

# Compress Unity project
log_info "Creating unity_project_$TIMESTAMP.zip..."
zip -rq "unity_project_$TIMESTAMP.zip" "$(basename "$UNITY_PROJECT_DIR")"
UNITY_SIZE=$(du -sh "unity_project_$TIMESTAMP.zip" | cut -f1)
log_info "✓ unity_project_$TIMESTAMP.zip ($UNITY_SIZE)"

# Summary
echo ""
log_info "========================================="
log_info "PROCESS COMPLETED SUCCESSFULLY!"
log_info "========================================="
log_info "Output directory: $OUTPUT_DIR"
log_info ""
log_info "Generated files:"
log_info "  1. raw_export_$TIMESTAMP.zip ($RAW_SIZE)"
log_info "     - AssetRipper's raw export"
log_info "     - Contains: ExportedProject/, AuxiliaryFiles/"
log_info ""
log_info "  2. unity_project_$TIMESTAMP.zip ($UNITY_SIZE)"
log_info "     - Ready-to-use Unity project"
log_info "     - Open in Unity Hub"
log_info ""
log_info "Next steps:"
log_info "  1. Extract unity_project_$TIMESTAMP.zip"
log_info "  2. Open Unity Hub"
log_info "  3. Add the extracted folder as new project"
log_info "  4. Open in Unity Editor"
log_info "========================================="
