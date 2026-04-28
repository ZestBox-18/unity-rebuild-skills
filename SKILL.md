---
name: apk-to-unity-rebuild
description: Use when you need to reverse engineer an Android APK file and create a Unity project from its assets. Converts APK to Unity project structure with AssetRipper.
---

# APK to Unity Rebuild

## Overview

This skill reverse engineers Android APK files and creates Unity projects from extracted assets using AssetRipper. It provides both the raw extracted content and a properly structured Unity project ready to be opened in Unity Editor.

## When to Use

Use this skill when:
- You need to extract Unity assets from an Android APK file
- You want to reverse engineer a Unity-based Android game or app
- You need to analyze or modify assets from a Unity APK
- You want to recreate a Unity project from an APK

## Prerequisites

### Server Requirements
- Linux server with SSH access
- AssetRipper Linux x64 (automatically downloaded if not present)
- wget, unzip, curl installed

### AssetRipper
- Version: 1.3.14 or later
- License: GPL-3.0 (see Legal section)
- Supports Unity versions: 3.5.0 to 6000.5.X

## Workflow

1. Input: APK File
2. Start AssetRipper Headless Service
3. Load APK via HTTP API
4. Export Unity Project
5. Create Base Unity Project Structure
6. Copy Assets to New Project
7. Compress Results
8. Output: ZIP files

## Input Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| apk_path | string | Yes | Path to the APK file on the server |
| output_dir | string | No | Output directory (default: ~/apk_output) |
| unity_version | string | No | Target Unity version (default: auto-detect) |

## Output

The skill produces two compressed archives:

1. **raw_export.zip** - AssetRipper's raw export
   - ExportedProject/ - Original Unity project structure
   - AuxiliaryFiles/ - Supporting files and metadata

2. **unity_project.zip** - Ready-to-use Unity project
   - Assets/ - All game assets (scripts, textures, models, etc.)
   - ProjectSettings/ - Basic project configuration
   - Packages/ - Package manifest

## Usage Example

```bash
# On the server
./scripts/process_apk.sh /path/to/game.apk

# Or with custom output directory
./scripts/process_apk.sh /path/to/game.apk ~/my_output
```

## Implementation Details

### Step 1: AssetRipper Setup
- Checks if AssetRipper is installed
- Downloads AssetRipper Linux x64 if needed
- Starts AssetRipper in headless mode on random port

### Step 2: APK Processing
- Loads APK file via AssetRipper's HTTP API
- Waits for processing to complete
- Exports Unity project structure

### Step 3: Unity Project Creation
- Creates basic Unity project structure
- Copies Assets folder from AssetRipper export
- Generates essential ProjectSettings files
- Creates Packages/manifest.json

### Step 4: Packaging
- Compresses raw AssetRipper export
- Compresses new Unity project
- Returns both archives to user

## Project Structure

The generated Unity project has this structure:

```
UnityProject/
├── Assets/
│   ├── Scripts/
│   ├── Textures/
│   ├── Models/
│   ├── Scenes/
│   └── ...
├── ProjectSettings/
│   ├── ProjectSettings.asset
│   ├── EditorBuildSettings.asset
│   ├── InputManager.asset
│   └── ...
└── Packages/
    └── manifest.json
```

## Important Notes

### Opening the Project
1. Extract unity_project.zip
2. Open Unity Hub
3. Click "Add" and select the extracted folder
4. Open the project in Unity Editor
5. Wait for asset import to complete

### Potential Issues
- **Missing scripts**: Some scripts may be compiled/obfuscated
- **Missing assets**: Certain assets may not be extractable
- **Version mismatch**: Open with correct Unity version
- **Package errors**: May need to install required packages

### AssetRipper Limitations
- Cannot extract IL2CPP compiled scripts
- Some shaders may not convert properly
- Streaming assets may need manual handling

## Legal

### AssetRipper License
AssetRipper is licensed under GNU General Public License v3.0.

**Important Legal Disclaimers:**
- Using or distributing the output from AssetRipper may be against copyright legislation in your jurisdiction
- You are responsible for ensuring you're not breaking any laws
- This software is not sponsored by or affiliated with Unity Technologies
- "Unity" is a registered trademark of Unity Technologies

### Usage Guidelines
- Only use on APKs you own or have permission to analyze
- Do not redistribute extracted assets without proper rights
- Respect intellectual property and copyright laws

## Troubleshooting

### AssetRipper Won't Start
```bash
# Check if port is in use
lsof -i :5000

# Check AssetRipper logs
cat ~/AssetRipper/logs/latest.log
```

### Empty Assets Folder
- APK may not be a Unity application
- APK may use unsupported Unity version
- Assets may be encrypted or obfuscated

### Unity Project Won't Open
- Check Unity version compatibility
- Install missing packages via Package Manager
- Review Unity Editor logs for errors

## Files

- `scripts/process_apk.sh` - Main processing script
- `scripts/start_assetripper.sh` - AssetRipper launcher
- `scripts/create_unity_project.sh` - Unity project creator
- `scripts/compress_results.sh` - Result packaging
- `templates/ProjectSettings/` - Unity settings templates

## Credits

- AssetRipper: https://github.com/AssetRipper/AssetRipper
- AssetRipper Documentation: https://assetripper.github.io/AssetRipper/
