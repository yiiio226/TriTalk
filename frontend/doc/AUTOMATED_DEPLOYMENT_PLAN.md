# 统一自动化部署方案 (Android & iOS)

本文档详细介绍了如何使用 **Fastlane** 来实现 **TriTalk** 的自动化部署，包括 **Google Play Store (内部测试)** 和 **Apple TestFlight**。

## 1. 方案概述

我们的目标是使用单一命令完成两个平台的构建和上传。我们将使用移动端自动化的行业标准工具——[Fastlane](https://fastlane.tools/)。

## 2. 前置准备

### 2.1 工具安装

- **Ruby**: macOS 预装了 Ruby，但建议使用 `rbenv` 或 `rvm` 管理版本。
- **Fastlane**: 通过 Homebrew 或 RubyGems 安装。
  ```bash
  brew install fastlane
  ```

### 2.2 凭据配置

**Android (Google Play Console):**

1.  进入 **Google Play Console** > **Setup** > **API access**。
2.  创建一个 **Service Account (服务账号)**，并授予 "Release Manager"（发布经理）权限。
3.  下载 JSON 格式的密钥文件（例如 `pc-api.json`）。
4.  安全保存此文件（**切勿**提交到 Git 代码库）。

**iOS (App Store Connect):**

1.  进入 **App Store Connect** > **Users and Access** > **Keys**。
2.  创建一个新的 **App Store Connect API Key** (角色选择: App Manager)。
3.  下载 `.p8` 格式的密钥文件。
4.  记录 `Key ID` 和 `Issuer ID`。

---

## 3. 架构设计

我们将在原生目录（`android/` 和 `ios/`）中维护各自的 Fastlane 配置，并在根目录 `frontend/` 下创建一个主脚本进行协调。

```text
frontend/
├── android/
│   ├── fastlane/
│   │   ├── Fastfile       # Android 部署逻辑
│   │   └── Appfile        # Android 包名及 JSON 密钥路径
│   └── pc-api.json        # Google Play JSON 密钥 (已加入 .gitignore)
├── ios/
│   ├── fastlane/
│   │   ├── Fastfile       # iOS 部署逻辑
│   │   └── Appfile        # iOS Bundle ID 及 Apple ID
│   └── AuthKey.p8         # Apple API 密钥 (已加入 .gitignore)
└── scripts/
    └── deploy.sh          # 统一部署脚本
```

---

## 4. 配置详情

### 4.1 Android 配置 (`android/fastlane/Fastfile`)

此任务（Lane）将构建 App Bundle (AAB) 并上传到 **内部测试 (Internal Testing)** 轨道。

```ruby
default_platform(:android)

platform :android do
  desc "部署到 Google Play 内部测试"
  lane :deploy_internal do
    # 1. 构建 AAB (Release 模式)
    # 注意：可以复用您现有的 Flutter 构建命令，或直接通过 Fastlane 驱动 Gradle
    gradle(
      task: "bundle",
      build_type: "Release",
      flavor: "Global", # 如果使用了 flavor
      properties: {
        "android.injected.version.name" => ENV["VERSION_NAME"],
        "android.injected.version.code" => ENV["VERSION_CODE"]
      }
    )

    # 2. 上传到 Google Play
    upload_to_play_store(
      track: 'internal',
      json_key: './pc-api.json',
      skip_upload_metadata: true,
      skip_upload_images: true,
      skip_upload_screenshots: true
    )
  end
end
```

### 4.2 iOS 配置 (`ios/fastlane/Fastfile`)

此任务将构建 IPA 文件并上传到 **TestFlight**。

```ruby
default_platform(:ios)

platform :ios do
  desc "部署到 TestFlight"
  lane :deploy_testflight do
    # 0. 配置 API Key
    api_key = app_store_connect_api_key(
      key_id: "YOUR_KEY_ID",
      issuer_id: "YOUR_ISSUER_ID",
      key_filepath: "./AuthKey.p8"
    )

    # 1. 增加构建版本号 (可选，Flutter 端通常已经管理好了)
    # increment_build_number(build_number: ENV["VERSION_CODE"])

    # 2. 构建 iOS App (Gym)
    build_app(
      scheme: "Runner",
      workspace: "Runner.xcworkspace",
      export_method: "app-store", # TestFlight 同样使用 app-store 导出
      include_bitcode: true
    )

    # 3. 上传到 TestFlight (Pilot)
    upload_to_testflight(
      api_key: api_key,
      skip_waiting_for_build_processing: true # 不等待 Apple 后台处理
    )
  end
end
```

---

## 5. 统一控制脚本 (`scripts/deploy.sh`)

创建一个脚本来顺序或并行执行双端任务。

```bash
#!/bin/bash
set -e

# 如果需要，从环境变量或 pubspec.yaml 加载版本号
# source ../assets/env/.env.prod

echo "🦄 正在启动统一自动化发布..."

# 1. 部署 Android
echo "🤖 正在部署 Android..."
cd android
fastlane deploy_internal
cd ..

# 2. 部署 iOS
echo "🍎 正在部署 iOS..."
cd ios
fastlane deploy_testflight
cd ..

echo "✅ 所有平台部署任务已成功完成！"
```

## 6. 实施步骤

1.  **安装 Fastlane**: 执行 `brew install fastlane`。
2.  **初始化 Android**:
    ```bash
    cd android
    fastlane init
    ```
    (按照提示操作，输入包名并提供 JSON 密钥文件路径)。
3.  **初始化 iOS**:
    ```bash
    cd ios
    fastlane init
    ```
    (选择 "TestFlight" 选项)。
4.  **填入配置**: 将本文档第 4 节中的代码复制到生成的 `Fastfile` 中。
5.  **测试**: 分别在 `android/` 和 `ios/` 目录下运行 `fastlane deploy_internal` 和 `fastlane deploy_testflight` 进行验证。

## 7. 版本号同步（高级）

为了保持双端版本一致，建议在 Shell 脚本中（类似于您在 `build-global.sh` 中所做的）从 `pubspec.yaml` 提取版本号，并将其作为环境变量（`VERSION_NAME`, `VERSION_CODE`）传递给 Fastlane。Fastlane 会读取这些变量并在编译前设置对应的构建版本。
