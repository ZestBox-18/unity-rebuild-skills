# APK 转 Unity 重构工具

**[English](README.md)** | 中文

---

逆向工程 Android APK 文件，从提取的资源创建 Unity 项目。在本地自动安装 AssetRipper 并运行。

## 快速开始

```bash
# 1. 克隆仓库
git clone https://github.com/ZestBox-18/unity-rebuild-skills.git
cd unity-rebuild-skills

# 2. 安装 AssetRipper（自动检测平台）
./install.sh

# 3. 处理 APK
./process_apk.sh /path/to/game.apk
```

## 输出

生成两个 ZIP 文件：
- `raw_export_TIMESTAMP.zip` - AssetRipper 原始导出
- `unity_project_TIMESTAMP.zip` - 可直接使用的 Unity 项目

## 下一步

1. 解压 `unity_project_TIMESTAMP.zip`
2. 打开 Unity Hub
3. 添加解压后的文件夹
4. 在 Unity Editor 中打开

## 支持平台

✅ Windows (x64, ARM64)
✅ macOS (Intel, Apple Silicon)
✅ Linux (x64, ARM64)

## 系统要求

- wget 或 curl
- unzip
- zip

大多数系统已预装。如果没有：

```bash
# Ubuntu/Debian
sudo apt-get install wget curl unzip zip

# macOS (使用 Homebrew)
brew install wget curl unzip zip
```

## 法律声明

AssetRipper 使用 GPL-3.0 许可证。仅用于你拥有或有权分析的 APK。

**完整文档见 [SKILL.md](SKILL.md)。**
