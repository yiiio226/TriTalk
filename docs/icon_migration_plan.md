# 场景图标迁移方案 (本地资源 -> Cloudflare R2)

当前 `standard_scenes` 的图标直接使用了打包在 App 内部的本地资源路径 (`assets/images/scenes/...`)。为了减小安装包体积并支持云端动态更新，计划将这些图标迁移至 Cloudflare R2 对象存储。

## 1. 架构设计 (Architecture)

### 1.1 存储与访问

- **存储服务**: Cloudflare R2
- **Bucket 名称**: `tritalk-assets` (建议)
- **访问域名**: 需配置自定义域名 (例如 `https://assets.tritalk.com`) 或通过 Worker 代理访问。
- **目录结构**: 建议放在 `scenes/` 目录下。
  - 例如: `https://assets.tritalk.com/scenes/map_3d.png`

### 1.2 数据存储规范 (Database)

数据库 (`standard_scenes` 和 `custom_scenarios`) 中的 `icon_path` 字段将存储 **相对路径** 或 **完整URL**。
**推荐方案**: 存储 **相对路径** (例如 `scenes/map_3d.png`)。

- **优点**: 域名变更时无需刷库；前端可灵活配置 CDN 前缀。

## 2. 迁移实施步骤 (Implementation Steps)

### 步骤 1: 资源上传 (用户手动执行)

请将 `frontend/assets/images/scenes/` 目录下的所有 `.png` 文件上传至 R2 Bucket 的 `scenes/` 文件夹中。

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

### 步骤 2: 数据库数据迁移 (SQL)

在 Supabase SQL Editor 中执行以下脚本，将现有的本地路径前缀替换为新的云端相对路径。

```sql
-- 1. 更新标准场景库 (Standard Scenes)
-- 将 'assets/images/scenes/xxx.png' 替换为 'scenes/xxx.png'
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

### 步骤 3: 前端代码改造 (Frontend Refactor)

#### 3.1 引入依赖

在 `pubspec.yaml` 中添加 `cached_network_image` 以支持网络图片缓存。

```yaml
dependencies:
  cached_network_image: ^3.3.0
```

#### 3.2 配置 Base URL

在全局配置或常量文件中定义资源根路径。

```dart
// lib/core/constants/app_constants.dart
class AppConstants {
  static const String sceneAssetsBaseUrl = 'https://assets.tritalk.com/';
  // dev 环境可能需要配置不同的 bucket 地址
}
```

#### 3.3 修改 UI 组件 (Widget)

创建一个统一的图标加载组件，用于处理路径逻辑。

```dart
// lib/core/presentation/widgets/app_icon_image.dart (新建)

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_constants.dart';

class AppIconImage extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;

  const AppIconImage({
    super.key,
    required this.path,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    // 兼容旧数据的本地路径 (如果还没跑数据库迁移)
    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        width: width,
        height: height,
        fit: BoxFit.contain,
      );
    }

    // 处理网络图片
    // 拼接完整 URL: https://assets.tritalk.com/scenes/xxx.png
    final imageUrl = path.startsWith('http')
        ? path
        : '${AppConstants.sceneAssetsBaseUrl}$path';

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: BoxFit.contain,
      placeholder: (context, url) => const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2)
        )
      ),
      errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.grey),
    );
  }
}
```

#### 3.4 替换调用点

在展示场景列表的地方（如 `SceneCard`），将 `Image.asset(scene.iconPath)` 替换为 `AppIconImage(path: scene.iconPath)`.

## 3. 验证 (Verification)

1. 确认 R2 Bucket 权限设置为公开读取 (Public Access)。
2. 运行 App，确认图标能正常加载且无明显延迟（得益于缓存）。
3. 检查数据库中 `custom_scenarios` 表的 `icon_path` 是否已更新。
