# 场景图标迁移方案 (本地资源 -> Cloudflare R2)

当前 `standard_scenes` 的图标直接使用了打包在 App 内部的本地资源路径 (`https://pub-a8095655217d4956a5672905a708a218.r2.dev/tritalk/dev/assets/scenes/...`)。为了减小安装包体积并支持云端动态更新，计划将这些图标迁移至 Cloudflare R2 对象存储。

## 1. 架构设计 (Architecture)

### 1.1 存储与访问

- **存储服务**: Cloudflare R2
- **Bucket 名称**: `tritalk-assets` (建议)
- **访问域名**: 需配置自定义域名 (例如 `https://assets.tritalk.com`) 或通过 Worker 代理访问。
- **目录结构**:
  - 例如: `https://pub-a8095655217d4956a5672905a708a218.r2.dev/tritalk/dev/assets/scenes/`

### 1.2 数据存储规范 (Database)

数据库 (`standard_scenes` 和 `custom_scenarios`) 中的 `icon_path` 字段将存储 **相对路径** 或 **完整URL**。
**推荐方案**: 存储 **相对路径** (例如 `scenes/map_3d.png`)。

- **优点**: 域名变更时无需刷库；前端可灵活配置 CDN 前缀。

## 2. 迁移实施步骤 (Implementation Steps)

### 步骤 1: 资源上传 (用户已经手动执行)

请将 `frontend/https://pub-a8095655217d4956a5672905a708a218.r2.dev/tritalk/dev/assets/scenes/` 目录下的所有 `.png` 文件上传至 R2 Bucket 的 `https://pub-a8095655217d4956a5672905a708a218.r2.dev/tritalk/dev/assets/scenes/` 文件夹中。

**文件列表 (13个):**

- `coffee_3d.png`
- `plane_3d.png`
- `wallet_3d.png`
- `taxi_3d.png`
- `supermarket_3d.png`
- `map_3d.png`
- `handshake_3d.png`
- `hotel_3d.png`
- `food_3d.png`
- `interview_3d.png`
- `meeting_3d.png`
- `movie_3d.png`
- `doctor_3d.png`

### 步骤 2: 数据库数据迁移 (SQL) ✅ 已完成

迁移文件已创建: `backend/supabase/migrations/20260121000000_migrate_icons_to_r2.sql`

**执行迁移**: 需要通过 Supabase CLI 或 Dashboard 执行此迁移脚本。

迁移文件内容如下：

```sql
-- Migration: Migrate icon_path from local assets to R2 relative paths
-- Target: Replace 'assets/images/scenes/xxx.png' with 'scenes/xxx.png'

-- 1. 更新标准场景库 (Standard Scenes)
UPDATE standard_scenes
SET icon_path = REGEXP_REPLACE(icon_path, '^assets/images/', '')
WHERE icon_path LIKE 'assets/images/%';

-- 2. 更新用户已克隆的场景 (Custom Scenarios)
-- 同样处理，确保用户现有的场景也能用上新图标
UPDATE custom_scenarios
SET icon_path = REGEXP_REPLACE(icon_path, '^assets/images/', '')
WHERE icon_path LIKE 'assets/images/%'
  AND source_type = 'standard'; -- 只更新来自官方的场景，防止误伤用户自定义上传(如果有)
```

### 步骤 3: 前端代码改造 (Frontend Refactor) ✅ 已完成

#### 3.1 引入依赖 (已完成)

在 `pubspec.yaml` 中添加 `cached_network_image` 以支持网络图片缓存。 (done)

```yaml
dependencies:
  cached_network_image: ^3.4.1
```

#### 3.2 配置 Base URL (Environment Configuration)

使用现有的环境配置系统 (`Env`, `EnvDev`, `EnvLocal`, `EnvProd`) 来管理资源的基础路径。

1.  **修改 `frontend/lib/core/env/env_local.dart`, `env_dev.dart`, `env_prod.dart`**:
    添加 `sceneAssetsBaseUrl` 常量。

    ```dart
    // env_dev.dart
    static const String sceneAssetsBaseUrl = 'https://pub-a8095655217d4956a5672905a708a218.r2.dev/tritalk/dev/assets/';

    // env_prod.dart
    // TODO: 生产环境建议绑定自定义域名 (如 https://assets.tritalk.com/)
    // 目前暂时与 Dev 保持一致
    static const String sceneAssetsBaseUrl = 'https://pub-a8095655217d4956a5672905a708a218.r2.dev/tritalk/dev/assets/';

    // env_local.dart
    // 本地开发可以使用 Dev 环境的资源，或者本地 mock 服务
    static const String sceneAssetsBaseUrl = 'https://pub-a8095655217d4956a5672905a708a218.r2.dev/tritalk/dev/assets/';
    ```

2.  **修改 `frontend/lib/core/env/env.dart`**:
    在 `Env` 类中暴露该 getter。

    ```dart
    // lib/core/env/env.dart
    static String get sceneAssetsBaseUrl {
      switch (EnvConfig.current) {
        case Environment.local:
          return EnvLocal.sceneAssetsBaseUrl;
        case Environment.dev:
          return EnvDev.sceneAssetsBaseUrl;
        case Environment.prod:
          return EnvProd.sceneAssetsBaseUrl;
      }
    }
    ```

#### 3.3 修改 UI 组件 (Widget)

创建一个统一的图标加载组件，用于处理路径逻辑。

```dart
// lib/features/scenes/presentation/widgets/scene_icon_image.dart (新建)

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/env/env.dart';

class SceneIconImage extends StatelessWidget {
  final String path;
  final String? emoji;
  final double? width;
  final double? height;

  /// 设计考量 (Design Considerations):
  /// 1. 支持响应式尺寸: 接收外部传入的 width/height (如 60 或 80)，确保与 SceneCard 现有的逻辑完全一致。
  /// 2. 无缝切换体验: 使用 Emoji 作为 Placeholder 时，通过 `FittedBox` 强制将其缩放至与 Image 相同的尺寸。
  ///    这意味着：
  ///    - 在 Grid 模式下 (size 80)，Emoji 和 Image 都会填充 80x80 的空间。
  ///    - 在 List 模式下 (size 60)，Emoji 和 Image 都会填充 60x60 的空间。
  ///    这消除了 "加载中 -> 加载完成" 或 "图片加载失败" 时的布局跳动或视觉不一致。
  const SceneIconImage({
    super.key,
    required this.path,
    this.emoji,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (path.isEmpty) {
      return _buildEmojiFallback();
    }

    // 兼容旧数据的本地路径 (如果还没跑数据库迁移)
    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        width: width,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _buildEmojiFallback(),
      );
    }

    // 处理网络图片
    // 拼接完整 URL: https://assets.tritalk.com/scenes/xxx.png
    final imageUrl = path.startsWith('http')
        ? path
        : '${Env.sceneAssetsBaseUrl}$path';

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: BoxFit.contain,
      // 使用 emoji 作为加载占位符，体验更平滑
      placeholder: (context, url) => _buildEmojiFallback(isPlaceholder: true),
      errorWidget: (context, url, error) => _buildEmojiFallback(),
    );
  }

  Widget _buildEmojiFallback({bool isPlaceholder = false}) {
    if (emoji != null && emoji!.isNotEmpty) {
      // 保持与旧 SceneCard 类似的大小策略。
      // 使用 FittedBox 确保 emoji 适应容器大小 (width/height)，避免溢出。
      return SizedBox(
        width: width,
        height: height,
        child: FittedBox(
          fit: BoxFit.contain,
          child: Text(
            emoji!,
            // 之前的实现使用 fixed fontSize: 60，这里通过 FittedBox 自动缩放
            // 也可以保留 style: const TextStyle(fontSize: 60)
            style: const TextStyle(fontSize: 60),
          ),
        ),
      );
    }

    // 如果没有 emoji 且不是占位符模式（即加载失败），显示错误图标
    if (!isPlaceholder) {
      return SizedBox(
        width: width,
        height: height,
        child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
      );
    }

    // 默认 loading (无emoji时的 fallback)
    return SizedBox(
        width: width,
        height: height,
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
    );
  }
}
```

#### 3.4 替换调用点

在展示场景列表的地方（如 `SceneCard`），将 `Image.asset(scene.iconPath)` 替换为:

```dart
SceneIconImage(
  path: scene.iconPath,
  emoji: scene.emoji, // 传递 emoji
  width: ...
  height: ...
)
```

## 3. 验证 (Verification)

1. 确认 R2 Bucket 权限设置为公开读取 (Public Access)。
2. 运行 App，确认图标能正常加载且无明显延迟（得益于缓存）。
3. 检查数据库中 `custom_scenarios` 表的 `icon_path` 是否已更新。
