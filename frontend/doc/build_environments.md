# Flutter 构建环境配置

## 概述

TriTalk 支持三种构建环境：

| 环境      | ENV 值  | 用途         | 后端 URL                                          |
| --------- | ------- | ------------ | ------------------------------------------------- |
| **Local** | `local` | 本地开发调试 | `http://localhost:8787`                           |
| **Dev**   | `dev`   | 开发版本测试 | `https://tritalk-backend.tristart226.workers.dev` |
| **Prod**  | `prod`  | 正式发布版本 | `https://tritalk-backend.tristart226.workers.dev` |

## 构建命令

### 本地开发 (Local)

连接本地后端进行开发调试：

```bash
# 使用模拟器/真机运行 (默认环境)
flutter run

# 明确指定 local 环境
flutter run --dart-define=ENV=local
```

> 💡 如果需要在真机上调试，修改 `env_local.dart` 中的 `backendUrl` 为你的本机 IP 地址：
>
> ```dart
> static const String backendUrl = 'http://192.168.1.3:8787';
> ```

### 开发版本 (Dev)

连接远程开发后端，用于分发测试版本：

```bash
# 运行开发版
flutter run --dart-define=ENV=dev

# 构建 iOS 开发版
flutter build ios --dart-define=ENV=dev

# 构建 Android 开发版
flutter build apk --dart-define=ENV=dev
```

### 生产版本 (Prod)

正式发布版本：

```bash
# 构建 iOS 发布版
flutter build ios --dart-define=ENV=prod --release

# 构建 Android 发布版 (APK)
flutter build apk --dart-define=ENV=prod --release

# 构建 Android 发布版 (App Bundle)
flutter build appbundle --dart-define=ENV=prod --release
```

## VS Code 配置

项目已配置 `.vscode/launch.json`，可以直接使用：

1. 打开 VS Code 的 "Run and Debug" 面板 (⌘+Shift+D)
2. 在顶部下拉菜单中选择配置：
   - **Local (localhost backend)** - 本地开发
   - **Dev (remote dev backend)** - 开发版
   - **Prod (production config)** - 生产配置
3. 按 F5 或点击绿色运行按钮

## Xcode 配置

### xcconfig 文件

项目已配置好环境相关的 xcconfig 文件：

```
frontend/ios/Flutter/
├── Debug.xcconfig    # flutter run 默认使用
├── Dev.xcconfig      # Dev 版本 (ENV=dev)
├── Release.xcconfig  # Prod 版本 (ENV=prod)
└── Generated.xcconfig
```

| 配置文件           | DART_DEFINES (base64) | 解码后     |
| ------------------ | --------------------- | ---------- |
| `Release.xcconfig` | `RU5WPXByb2Q=`        | `ENV=prod` |
| `Dev.xcconfig`     | `RU5WPWRldg==`        | `ENV=dev`  |

### 方式一：使用 Flutter 命令 + Xcode Archive (推荐)

```bash
# 1. 使用 Flutter 构建并注入环境变量
flutter build ios --dart-define=ENV=dev

# 2. 打开 Xcode
open ios/Runner.xcworkspace

# 3. 在 Xcode 中选择 Product → Archive
```

### 方式二：配置 Xcode Scheme (可选)

如果需要完全在 Xcode 中切换环境，按以下步骤配置：

#### 步骤 1: 创建 Dev Build Configuration

1. 打开 Xcode：`open ios/Runner.xcworkspace`
2. 点击左侧项目导航器中的 **Runner** (蓝色图标)
3. 选择 **PROJECT** 下的 **Runner** (不是 TARGETS)
4. 点击 **Info** 标签
5. 在 **Configurations** 部分，点击 **+** 按钮
6. 选择 **Duplicate "Release" Configuration**
7. 命名为 **Dev**

#### 步骤 2: 关联 Dev.xcconfig

在刚创建的 **Dev** 配置下，将 Runner 项目的配置文件改为 `Dev`：

| Configuration | Runner (Project) |
| ------------- | ---------------- |
| Debug         | Debug.xcconfig   |
| Release       | Release.xcconfig |
| **Dev**       | **Dev.xcconfig** |

#### 步骤 3: 创建 Dev Scheme

1. 点击 Xcode 顶部的 **Scheme 选择器** (通常显示 "Runner")
2. 选择 **Manage Schemes...**
3. 选中 **Runner** scheme，点击 **齿轮图标** → **Duplicate**
4. 命名为 **Runner-Dev**
5. 在新 scheme 中配置：
   - **Run** → Build Configuration: **Dev**
   - **Archive** → Build Configuration: **Dev**

#### 使用方法

配置完成后，在 Xcode 顶部切换 Scheme 即可选择不同环境：

| Xcode Scheme   | Archive 环境  |
| -------------- | ------------- |
| **Runner**     | `prod` (生产) |
| **Runner-Dev** | `dev` (开发)  |

## 代码中使用环境配置

```dart
import 'package:frontend/core/env/env.dart';
import 'package:frontend/core/env/env_config.dart';

// 获取当前环境
print('当前环境: ${Env.name}'); // local, dev, or prod

// 获取配置值
final backendUrl = Env.backendUrl;
final supabaseUrl = Env.supabaseUrl;

// 检查环境类型
if (EnvConfig.isLocal) {
  // 本地开发特有逻辑
}

if (EnvConfig.isProd) {
  // 生产环境特有逻辑
}
```

## 文件结构

### Dart 环境配置

```
frontend/lib/core/env/
├── env.dart           # 主入口，统一获取配置
├── env_config.dart    # 环境类型定义和检测
├── env_local.dart     # 本地开发配置
├── env_dev.dart       # 开发环境配置
└── env_prod.dart      # 生产环境配置
```

### iOS xcconfig 配置

```
frontend/ios/Flutter/
├── Debug.xcconfig     # Debug 构建配置
├── Dev.xcconfig       # Dev 构建配置 (ENV=dev)
├── Release.xcconfig   # Release 构建配置 (ENV=prod)
└── Generated.xcconfig # Flutter 自动生成
```

## CI/CD 集成

在 CI/CD 流程中使用：

```yaml
# GitHub Actions 示例
- name: Build iOS Production
  run: flutter build ios --dart-define=ENV=prod --release

- name: Build Android Production
  run: flutter build appbundle --dart-define=ENV=prod --release
```

## 注意事项

1. **默认环境**：如果不指定 `--dart-define=ENV`，默认使用 `local` 环境
2. **Tree Shaking**：编译时会移除未使用的环境配置代码
3. **安全性**：敏感配置（如 API Keys）建议通过 CI/CD 环境变量注入，不要硬编码在代码中
