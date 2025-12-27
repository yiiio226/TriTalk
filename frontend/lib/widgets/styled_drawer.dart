import 'package:flutter/material.dart';

class StyledDrawer extends StatelessWidget {
  final Widget child;
  final double? height;
  final EdgeInsetsGeometry padding;

  const StyledDrawer({
    Key? key,
    required this.child,
    this.height,
    this.padding = const EdgeInsets.all(24.0),
  }) : super(key: key);

  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final viewInsetsBottom = mediaQuery.viewInsets.bottom;
    
    // Ensure drawer doesn't go too high when keyboard is open
    // Max height is 90% of screen - keyboard height
    final maxHeight = (screenHeight * 0.9) - viewInsetsBottom;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: maxHeight,
      ),
      child: SizedBox(
        height: height != null && height! > maxHeight ? maxHeight : height,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
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
      ),
    );
  }
}
