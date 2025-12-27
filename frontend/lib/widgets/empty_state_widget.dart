import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final String imagePath;
  final double imageSize;

  const EmptyStateWidget({
    Key? key,
    required this.message,
    required this.imagePath,
    this.imageSize = 200,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: const Alignment(0, -0.2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            imagePath,
            width: imageSize,
            height: imageSize,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
