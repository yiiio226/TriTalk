import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/env/env.dart';

/// A unified widget for displaying scene icons.
///
/// Supports:
/// - R2 network images (relative paths like 'scenes/map_3d.png')
/// - Legacy local assets (paths starting with 'assets/')
/// - Full URLs (paths starting with 'http')
/// - Emoji fallback when image is loading or fails to load
///
/// Design Considerations:
/// 1. 支持响应式尺寸: 接收外部传入的 width/height (如 60 或 80)，确保与 SceneCard 现有的逻辑完全一致。
/// 2. 无缝切换体验: 使用 Emoji 作为 Placeholder 时，通过 FittedBox 强制将其缩放至与 Image 相同的尺寸。
///    这意味着：
///    - 在 Grid 模式下 (size 80)，Emoji 和 Image 都会填充 80x80 的空间。
///    - 在 List 模式下 (size 60)，Emoji 和 Image 都会填充 60x60 的空间。
///    这消除了 "加载中 -> 加载完成" 或 "图片加载失败" 时的布局跳动或视觉不一致。
class SceneIconImage extends StatelessWidget {
  final String path;
  final String? emoji;
  final double? width;
  final double? height;

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
        child: const Center(
          child: Icon(Icons.broken_image, color: Colors.grey),
        ),
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
