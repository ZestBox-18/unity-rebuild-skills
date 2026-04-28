# APK to Unity Rebuild Skill

Reverse engineer Android APK files and create Unity projects from extracted assets. Works locally on your machine with automatic AssetRipper installation.

## Quick Start

```bash
# 1. Clone the skill
git clone https://github.com/ZestBox-18/unity-rebuild-skills.git
cd unity-rebuild-skills

# 2. Install AssetRipper (auto-detects your platform)
./install.sh

# 3. Process an APK
./process_apk.sh /path/to/game.apk
```

## Output

Two ZIP files are generated:
- `raw_export_TIMESTAMP.zip` - AssetRipper's raw export
- `unity_project_TIMESTAMP.zip` - Ready-to-use Unity project

## Next Steps

1. Extract `unity_project_TIMESTAMP.zip`
2. Open Unity Hub
3. Add the extracted folder
4. Open in Unity Editor

## Supported Platforms

✅ Windows (x64, ARM64)
✅ macOS (Intel, Apple Silicon)
✅ Linux (x64, ARM64)

## Requirements

- wget or curl
- unzip
- zip

Most systems have these pre-installed. If not:

```bash
# Ubuntu/Debian
sudo apt-get install wget curl unzip zip

# macOS (with Homebrew)
brew install wget curl unzip zip
```

## Legal

AssetRipper is GPL-3.0 licensed. Only use on APKs you own or have permission to analyze.

**See [SKILL.md](SKILL.md) for full documentation.**
