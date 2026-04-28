# APK 转 Unity 项目重构工具

逆向工程 Android APK 文件，使用 AssetRipper 提取资源并创建 Unity 项目。支持跨平台自动安装，在本地即可完成处理。

## 快速开始

```bash
# 1. 克隆仓库
git clone https://github.com/ZestBox-18/unity-rebuild-skills.git
cd unity-rebuild-skills

# 2. 安装 AssetRipper（自动检测系统）
./install.sh

# 3. 处理 APK 文件
./process_apk.sh /path/to/game.apk
```

## 输出结果

处理后会生成两个 ZIP 文件：
- `raw_export_时间戳.zip` - AssetRipper 原始导出
- `unity_project_时间戳.zip` - 可直接使用的 Unity 项目

## 使用步骤

1. 解压 `unity_project_时间戳.zip`
2. 打开 Unity Hub
3. 点击"添加" → 选择解压后的文件夹
4. 在 Unity Editor 中打开项目

## 支持平台

✅ Windows x64/ARM64
✅ macOS Intel/Apple Silicon
✅ Linux x64/ARM64

## 系统要求

- wget 或 curl
- unzip
- zip

大多数系统已预装这些工具。如果没有：

```bash
# Ubuntu/Debian
sudo apt-get install wget curl unzip zip

# macOS (使用 Homebrew)
brew install wget curl unzip zip
```

## 使用示例

### 基本用法
```bash
./process_apk.sh ~/Downloads/game.apk
```

### 指定输出目录
```bash
./process_apk.sh game.apk ./my_output
```

### 批量处理
```bash
for apk in *.apk; do
    ./process_apk.sh "$apk" "./output/${apk%.apk}"
done
```

## 工作原理

```
APK 文件
  ↓
1. 启动 AssetRipper（无头模式）
  ↓
2. 加载并分析 APK
  ↓
3. 导出 Unity 项目结构
  ↓
4. 创建标准 Unity 项目
  ↓
5. 复制 Assets 资源文件
  ↓
6. 压缩结果文件
  ↓
输出：两个 ZIP 文件
```

## 提取的资源类型

AssetRipper 可以提取以下 Unity 资源：

- 🎨 **纹理** (Texture2D, Sprite, Cubemap)
- 🎭 **模型** (Mesh, Material)
- 🎬 **动画** (AnimationClip, AnimatorController, Avatar)
- 🎵 **音频** (AudioClip)
- 📝 **脚本** (Scripts)
- 🎮 **场景** (Scene)
- 🔧 **着色器** (Shader)
- 📦 **游戏对象** (GameObject)

## 常见问题

### AssetRipper 启动失败
```bash
# 检查端口是否被占用
lsof -i :5000

# 结束现有进程
pkill -f AssetRipper

# 使用其他端口
ASSRIPPER_PORT=8080 ./process_apk.sh game.apk
```

### Assets 文件夹为空
可能的原因：
- APK 不是 Unity 应用
- APK 使用了不支持的 Unity 版本
- 资源已加密或混淆
- APK 使用了 IL2CPP（脚本已编译）

### Unity 项目无法打开
解决方法：
- 检查 Unity 版本兼容性
- 通过 Package Manager 安装缺失的包
- 查看 Unity Editor 日志
- 尝试用不同 Unity 版本打开

## AssetRipper 的限制

- ❌ 无法提取 IL2CPP 编译的脚本（大多数手游）
- ⚠️ 部分着色器可能转换不正确
- ⚠️ StreamingAssets 可能需要手动处理
- ⚠️ Mono_behaviour 引用可能会断开
- ⚠️ 部分资源类型可能不完全支持

## 法律声明

### AssetRipper 许可证
AssetRipper 使用 **GNU General Public License v3.0** 许可证。

**重要声明：**
- 使用或分发 AssetRipper 的输出可能违反你所在司法管辖区的版权法
- 你有责任确保不违反任何法律
- 本软件与 Unity Technologies 无关联
- "Unity" 是 Unity Technologies 的注册商标

### 使用准则
- ✅ 用于你自己拥有的 APK
- ✅ 用于教育目的
- ✅ 在获得所有者许可后使用
- ❌ 未经授权不得分发提取的资源
- ❌ 未经许可不得用于商业目的

## 项目结构

```
unity-rebuild-skills/
├── install.sh              # AssetRipper 安装脚本
├── process_apk.sh          # 主处理脚本
├── SKILL.md               # 完整文档（英文）
├── README.md              # 快速开始（英文）
├── README_CN.md           # 快速开始（中文）
├── .assetripper/          # AssetRipper 安装目录（自动创建）
└── templates/
    └── ProjectSettings/
        └── ProjectSettings.asset
```

## 技术细节

### AssetRipper 集成
- 使用 AssetRipper 的无头模式（headless mode）
- 通过 HTTP API 通信
- 使用的端点：
  - `POST /LoadFile` - 加载 APK
  - `POST /Export/UnityProject` - 导出项目

### Unity 项目结构
生成的项目遵循 Unity 标准结构：
- 正确的文件夹层次
- 有效的 ProjectSettings
- 包含常用依赖的 Package manifest
- 可直接导入 Unity Hub

## 致谢

- **AssetRipper**: https://github.com/AssetRipper/AssetRipper
- **AssetRipper 文档**: https://assetripper.github.io/AssetRipper/
- **Unity Technologies**: https://unity.com/

## 支持

如有问题或疑问：
1. 查看常见问题部分
2. 阅读 AssetRipper 文档
3. 在 GitHub 仓库提交 Issue

---

**[English](README.md)** | 中文
