#!/bin/bash
# Compress results into ZIP archives
# Usage: source compress_results.sh <output_dir>

OUTPUT_DIR="$1"

if [ -z "$OUTPUT_DIR" ]; then
    echo "[ERROR] Usage: source compress_results.sh <output_dir>"
    return 1
fi

echo "[INFO] Compressing results..."

# Compress raw AssetRipper export
if [ -d "$OUTPUT_DIR/assetripper_export" ]; then
    echo "[INFO] Creating raw_export.zip..."
    cd "$OUTPUT_DIR"
    zip -rq raw_export.zip assetripper_export
    RAW_SIZE=$(du -sh raw_export.zip | cut -f1)
    echo "[INFO] raw_export.zip created ($RAW_SIZE)"
fi

# Compress Unity project
if [ -d "$OUTPUT_DIR/UnityProject" ]; then
    echo "[INFO] Creating unity_project.zip..."
    cd "$OUTPUT_DIR"
    zip -rq unity_project.zip UnityProject
    UNITY_SIZE=$(du -sh unity_project.zip | cut -f1)
    echo "[INFO] unity_project.zip created ($UNITY_SIZE)"
fi

# Create summary
echo ""
echo "========================================="
echo "COMPRESSION SUMMARY"
echo "========================================="
echo "Output directory: $OUTPUT_DIR"
if [ -f "$OUTPUT_DIR/raw_export.zip" ]; then
    echo "  - raw_export.zip: $RAW_SIZE"
fi
if [ -f "$OUTPUT_DIR/unity_project.zip" ]; then
    echo "  - unity_project.zip: $UNITY_SIZE"
fi
echo "========================================="
