# APK to Unity Rebuild Skill

This skill reverse engineers Android APK files and creates Unity projects from extracted assets using AssetRipper.

## Quick Start

```bash
# On the server
cd ~/unity-rebuild-skills
./scripts/process_apk.sh /path/to/your/game.apk
```

## Output

Two ZIP files will be created:
- `raw_export.zip` - AssetRipper's raw export
- `unity_project.zip` - Ready-to-use Unity project

## Next Steps

1. Download the ZIP files from the server
2. Extract `unity_project.zip`
3. Open Unity Hub
4. Add the extracted folder as a new project
5. Open in Unity Editor

## Requirements

- Linux server with SSH access
- AssetRipper (auto-downloaded)
- wget, unzip, curl

## Legal

AssetRipper is licensed under GPL-3.0. Only use on APKs you own or have permission to analyze.

See SKILL.md for full documentation.
