import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_constants.dart';

class AppIconImage extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;

  const AppIconImage({super.key, required this.path, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    // Fallback for local assets (if legacy paths still exist or for testing)
    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        width: width,
        height: height,
        fit: BoxFit.contain,
      );
    }

    // Handle network images
    // If path is already a full URL, use it directly.
    // Otherwise, append it to the base URL.
    final imageUrl = path.startsWith('http')
        ? path
        : '${AppConstants.sceneAssetsBaseUrl}$path';

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: BoxFit.contain,
      placeholder: (context, url) => SizedBox(
        width: width ?? 20,
        height: height ?? 20,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      errorWidget: (context, url, error) => SizedBox(
        width: width,
        height: height,
        child: const Icon(Icons.broken_image, color: Colors.grey),
      ),
    );
  }
}
