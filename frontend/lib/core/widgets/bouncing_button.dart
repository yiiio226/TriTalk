import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A wrapper widget that provides a scaling "squish" animation and haptic feedback
/// on tap interactions.
///
/// This moves the app from "functional" to "delightful" by providing tactile
/// and visual confirmation of interactions.
class BouncingButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double scaleFactor;
  final Duration duration;
  final bool enableHaptic;
  final HitTestBehavior behavior;

  const BouncingButton({
    super.key,
    required this.child,
    required this.onTap,
    this.scaleFactor = 0.96, // Subtle scale down
    this.duration = const Duration(milliseconds: 100), // Snappy response
    this.enableHaptic = true,
    this.behavior = HitTestBehavior.opaque,
  });

  @override
  State<BouncingButton> createState() => _BouncingButtonState();
}

class _BouncingButtonState extends State<BouncingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      // Use a slightly longer reverse duration for a springy feel
      reverseDuration: Duration(
        milliseconds: (widget.duration.inMilliseconds * 1.5).round(),
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutQuad,
        reverseCurve: Curves.elasticOut, // Elastic bounce back
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.enableHaptic) {
      HapticFeedback.lightImpact();
    }
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    // Delay the reverse slightly to ensure the down animation is perceptible
    // even for very quick taps
    Future.delayed(const Duration(milliseconds: 30), () {
      if (mounted) {
        _controller.reverse();
      }
    });
    widget.onTap();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: widget.behavior,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
