#!/bin/bash
# Create Unity project structure and copy assets
# Usage: source create_unity_project.sh <export_dir> <unity_project_dir>

EXPORT_DIR="$1"
UNITY_PROJECT_DIR="$2"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

if [ -z "$EXPORT_DIR" ] || [ -z "$UNITY_PROJECT_DIR" ]; then
    echo "[ERROR] Usage: source create_unity_project.sh <export_dir> <unity_project_dir>"
    return 1
fi

echo "[INFO] Creating Unity project at: $UNITY_PROJECT_DIR"

# Create directory structure
mkdir -p "$UNITY_PROJECT_DIR"/Assets
mkdir -p "$UNITY_PROJECT_DIR"/ProjectSettings
mkdir -p "$UNITY_PROJECT_DIR"/Packages

# Copy Assets from AssetRipper export
if [ -d "$EXPORT_DIR/ExportedProject/Assets" ]; then
    echo "[INFO] Copying Assets..."
    cp -r "$EXPORT_DIR"/ExportedProject/Assets/* "$UNITY_PROJECT_DIR"/Assets/ 2>/dev/null || true
else
    echo "[WARN] No Assets folder found in export"
fi

# Copy ProjectSettings if available
if [ -d "$EXPORT_DIR/ExportedProject/ProjectSettings" ]; then
    echo "[INFO] Copying ProjectSettings..."
    cp -r "$EXPORT_DIR"/ExportedProject/ProjectSettings/* "$UNITY_PROJECT_DIR"/ProjectSettings/ 2>/dev/null || true
fi

# Create essential ProjectSettings files if not present
if [ ! -f "$UNITY_PROJECT_DIR/ProjectSettings/ProjectSettings.asset" ]; then
    echo "[INFO] Creating default ProjectSettings..."
    cp "$PROJECT_ROOT"/templates/ProjectSettings/* "$UNITY_PROJECT_DIR"/ProjectSettings/ 2>/dev/null || {
        # Create minimal ProjectSettings if templates don't exist
        cat > "$UNITY_PROJECT_DIR/ProjectSettings/ProjectSettings.asset" << 'EOF'
%YAML 1.1
%TAG !u! tag:unity3d.com,2011:
--- !u!129 &1
PlayerSettings:
  m_ObjectHideFlags: 0
  serializedVersion: 22
  productGUID: {fileID: 0}
  AndroidProfiler: 0
  AndroidFilterTouchesWhenObscured: 0
  AndroidEnableSustainedPerformanceMode: 0
  defaultScreenOrientation: 4
  targetDevice: 2
  useOnDemandResources: 0
  accelerometerFrequency: 60
  companyName: DefaultCompany
  productName: ExtractedProject
  defaultCursor: {fileID: 0}
  cursorHotspot: {x: 0, y: 0}
  m_SplashScreenBackgroundColor: {r: 0.13725491, g: 0.12156863, b: 0.1254902, a: 1}
EOF
    }
fi

# Create Packages/manifest.json
if [ ! -f "$UNITY_PROJECT_DIR/Packages/manifest.json" ]; then
    echo "[INFO] Creating Packages/manifest.json..."
    cat > "$UNITY_PROJECT_DIR/Packages/manifest.json" << 'EOF'
{
  "dependencies": {
    "com.unity.collab-proxy": "1.17.7",
    "com.unity.feature.development": "1.0.1",
    "com.unity.render-pipelines.universal": "12.1.7",
    "com.unity.textmeshpro": "3.0.6",
    "com.unity.timeline": "1.6.4",
    "com.unity.ugui": "1.0.0",
    "com.unity.visualscripting": "1.7.6",
    "com.unity.modules.ai": "1.0.0",
    "com.unity.modules.androidjni": "1.0.0",
    "com.unity.modules.animation": "1.0.0",
    "com.unity.modules.assetbundle": "1.0.0",
    "com.unity.modules.audio": "1.0.0",
    "com.unity.modules.cloth": "1.0.0",
    "com.unity.modules.director": "1.0.0",
    "com.unity.modules.imageconversion": "1.0.0",
    "com.unity.modules.imgui": "1.0.0",
    "com.unity.modules.jsonserialize": "1.0.0",
    "com.unity.modules.particlesystem": "1.0.0",
    "com.unity.modules.physics": "1.0.0",
    "com.unity.modules.physics2d": "1.0.0",
    "com.unity.modules.screencapture": "1.0.0",
    "com.unity.modules.terrain": "1.0.0",
    "com.unity.modules.terrainphysics": "1.0.0",
    "com.unity.modules.tilemap": "1.0.0",
    "com.unity.modules.ui": "1.0.0",
    "com.unity.modules.uielements": "1.0.0",
    "com.unity.modules.umbra": "1.0.0",
    "com.unity.modules.unityanalytics": "1.0.0",
    "com.unity.modules.unitywebrequest": "1.0.0",
    "com.unity.modules.unitywebrequestassetbundle": "1.0.0",
    "com.unity.modules.unitywebrequestaudio": "1.0.0",
    "com.unity.modules.unitywebrequesttexture": "1.0.0",
    "com.unity.modules.unitywebrequestwww": "1.0.0",
    "com.unity.modules.vehicles": "1.0.0",
    "com.unity.modules.video": "1.0.0",
    "com.unity.modules.vr": "1.0.0",
    "com.unity.modules.wind": "1.0.0",
    "com.unity.modules.xr": "1.0.0"
  }
}
EOF
fi

echo "[INFO] Unity project created successfully"
echo "[INFO] Total size: $(du -sh "$UNITY_PROJECT_DIR" | cut -f1)"
