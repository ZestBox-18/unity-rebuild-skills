---
name: apk-to-unity-rebuild
description: Use when you need to reverse engineer an Android APK file and create a Unity project from its assets. Automatically installs AssetRipper and processes APK locally.
---

# APK to Unity Rebuild

## Overview

This skill reverse engineers Android APK files and creates Unity projects from extracted assets. It automatically downloads and configures AssetRipper for your platform, then processes APK files locally on your machine.

**Key Features:**
- ✅ Automatic AssetRipper installation
- ✅ Cross-platform support (Windows, macOS, Linux)
- ✅ Local processing (no server required)
- ✅ Generates ready-to-use Unity project
- ✅ Includes both raw export and structured project

## When to Use

Use this skill when:
- You need to extract Unity assets from an Android APK
- You want to reverse engineer a Unity-based game/app
- You need to analyze or modify assets from a Unity APK
- You want to recreate a Unity project from an APK

## Quick Start

### Installation

```bash
# Clone or download the skill
git clone https://github.com/ZestBox-18/unity-rebuild-skills.git
cd unity-rebuild-skills

# Install AssetRipper (automatic platform detection)
./install.sh
```

### Usage

```bash
# Process an APK file
./process_apk.sh /path/to/game.apk

# Or specify output directory
./process_apk.sh /path/to/game.apk ./my_output
```

## Supported Platforms

| Platform | Architecture | Status |
|----------|--------------|--------|
| Windows | x64 | ✅ Supported |
| Windows | ARM64 | ✅ Supported |
| macOS | x64 (Intel) | ✅ Supported |
| macOS | ARM64 (Apple Silicon) | ✅ Supported |
| Linux | x64 | ✅ Supported |
| Linux | ARM64 | ✅ Supported |

## Workflow

```
1. Install Skill
   ↓
2. Run install.sh
   - Detects your OS and architecture
   - Downloads appropriate AssetRipper version
   - Configures environment
   ↓
3. Process APK
   - Starts AssetRipper in headless mode
   - Loads and analyzes APK
   - Exports Unity project structure
   ↓
4. Create Unity Project
   - Builds proper project structure
   - Copies Assets folder
   - Generates ProjectSettings
   - Creates Packages manifest
   ↓
5. Package Results
   - raw_export.zip (AssetRipper output)
   - unity_project.zip (Ready to use)
```

## Output

The skill generates two ZIP files:

### 1. raw_export_TIMESTAMP.zip
AssetRipper's raw export containing:
- `ExportedProject/` - Original Unity project structure
- `AuxiliaryFiles/` - Metadata and supporting files

### 2. unity_project_TIMESTAMP.zip
Ready-to-use Unity project containing:
- `Assets/` - All game assets (scripts, textures, models, etc.)
- `ProjectSettings/` - Project configuration
- `Packages/manifest.json` - Package dependencies

## Opening the Unity Project

1. Extract `unity_project_TIMESTAMP.zip`
2. Open Unity Hub
3. Click "Add" → Select extracted folder
4. Open project in Unity Editor
5. Wait for asset import to complete

## Requirements

### Automatic Installation
The skill automatically installs these if needed:
- AssetRipper (downloaded from GitHub releases)

### System Requirements
- **wget** or **curl** (for downloading)
- **unzip** (for extracting)
- **zip** (for packaging)
- ~500MB free space (for AssetRipper)

### Check Requirements
```bash
# Linux/macOS
which wget curl unzip zip

# Install if missing (Ubuntu/Debian)
sudo apt-get install wget curl unzip zip

# Install if missing (macOS with Homebrew)
brew install wget curl unzip zip
```

## Configuration

### Environment Variables
```bash
# Change AssetRipper port (default: 5000)
export ASSRIPPER_PORT=8080

# Run with custom port
ASSRIPPER_PORT=8080 ./process_apk.sh game.apk
```

### AssetRipper Location
AssetRipper is installed in:
```
unity-rebuild-skills/
└── .assetripper/
    ├── AssetRipper.GUI.Free
    ├── libcapstone.so
    └── ...
```

## Troubleshooting

### AssetRipper Won't Start
```bash
# Check if port is in use
lsof -i :5000

# Kill existing process
pkill -f AssetRipper

# Try different port
ASSRIPPER_PORT=8080 ./process_apk.sh game.apk
```

### Empty Assets Folder
Possible causes:
- APK is not a Unity application
- APK uses unsupported Unity version
- Assets are encrypted or obfuscated
- APK uses IL2CPP (scripts compiled)

### Unity Project Won't Open
Solutions:
- Check Unity version compatibility
- Install missing packages via Package Manager
- Review Unity Editor logs
- Try opening with different Unity version

### Installation Fails
```bash
# Manual download
wget https://github.com/AssetRipper/AssetRipper/releases/latest/download/AssetRipper_linux_x64.zip

# Extract manually
unzip AssetRipper_linux_x64.zip -d .assetripper/
```

## AssetRipper Limitations

- Cannot extract IL2CPP compiled scripts (most mobile games)
- Some shaders may not convert properly
- Streaming assets may need manual handling
- Mono_behaviour references might be broken
- Some asset types may not be fully supported

## Legal

### AssetRipper License
AssetRipper is licensed under **GNU General Public License v3.0**.

**Important Disclaimers:**
- Using or distributing output from AssetRipper may violate copyright laws
- You are responsible for ensuring legal compliance
- This tool is not affiliated with Unity Technologies
- "Unity" is a trademark of Unity Technologies

### Usage Guidelines
- ✅ Use on APKs you own
- ✅ Use for educational purposes
- ✅ Use with permission from owner
- ❌ Don't redistribute extracted assets without rights
- ❌ Don't use for commercial purposes without license

## Examples

### Basic Usage
```bash
./process_apk.sh ~/Downloads/game.apk
```

### Custom Output
```bash
./process_apk.sh game.apk ./extracted_game
```

### Batch Processing
```bash
for apk in *.apk; do
    ./process_apk.sh "$apk" "./output/${apk%.apk}"
done
```

## Files Structure

```
unity-rebuild-skills/
├── SKILL.md                    # This documentation
├── README.md                   # Quick start guide
├── install.sh                  # AssetRipper installer
├── process_apk.sh              # Main processing script
├── .assetripper/               # AssetRipper installation
│   ├── AssetRipper.GUI.Free
│   └── ...
└── templates/
    └── ProjectSettings/
        └── ProjectSettings.asset
```

## Technical Details

### AssetRipper Integration
- Uses AssetRipper's headless mode
- Communicates via HTTP API
- Endpoints used:
  - `POST /Commands/LoadFile` - Load APK
  - `POST /Commands/ExportUnityProject` - Export

### Unity Project Structure
The generated project follows Unity's standard structure:
- Proper folder hierarchy
- Valid ProjectSettings
- Package manifest with common dependencies
- Ready for Unity Hub import

## Credits

- **AssetRipper**: https://github.com/AssetRipper/AssetRipper
- **AssetRipper Docs**: https://assetripper.github.io/AssetRipper/
- **Unity Technologies**: https://unity.com/

## Support

For issues or questions:
1. Check Troubleshooting section
2. Review AssetRipper documentation
3. Open issue on GitHub repository
