import 'package:flutter/material.dart';

class StyledDrawer extends StatelessWidget {
  final Widget child;
  final double? height;
  final EdgeInsetsGeometry padding;

  const StyledDrawer({
    super.key,
    required this.child,
    this.height,
    this.padding = const EdgeInsets.all(24.0),
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final viewInsetsBottom = mediaQuery.viewInsets.bottom;
    
    // Ensure drawer doesn't go too high when keyboard is open
    // Max height is 90% of screen - keyboard height
    final maxHeight = (screenHeight * 0.9) - viewInsetsBottom;
    
    // Default height is 60% of screen
    final defaultHeight = screenHeight * 0.2;
    
    
    // Determine constraints
    // Min height: Provided height OR 60% of screen (capped at max)
    final minHeight = height ?? defaultHeight;
    final realMinHeight = minHeight > maxHeight ? maxHeight : minHeight;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: maxHeight, // Max 90%
        minHeight: realMinHeight, // Min 60% (unless keyboard makes screen tiny)
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
