import 'dart:math';
import 'package:flutter/material.dart';

class FallingConfettiWidget extends StatefulWidget {
  final Widget child;

  const FallingConfettiWidget({
    super.key,
    required this.child,
  });

  @override
  State<FallingConfettiWidget> createState() => _FallingConfettiWidgetState();
}

class _FallingConfettiWidgetState extends State<FallingConfettiWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  final List<_ConfettiParticle> _particles = [];
  final Random _random = Random();

  // Asset paths for 3D confetti
  final List<String> _assets = [
    'assets/images/illustrations/confetti_star_3d.png',
    'assets/images/illustrations/confetti_ribbon_3d.png',
    'assets/images/illustrations/confetti_ball_3d.png',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10), // Long duration for continuous fall
    )..repeat();

    // Initialize particles
    for (int i = 0; i < 30; i++) {
      _particles.add(_createParticle(allowBelowScreen: true));
    }
  }

  _ConfettiParticle _createParticle({bool allowBelowScreen = false}) {
    return _ConfettiParticle(
      assetPath: _assets[_random.nextInt(_assets.length)],
      // Start randomly above the screen or spread out if initializing
      x: _random.nextDouble() * 1.0, // Full width
      y: allowBelowScreen 
          ? _random.nextDouble() * 1.5 - 1.0 // Initial spread: -1.0 to 0.5
          : -0.2 - _random.nextDouble() * 0.5, // Start above: -0.7 to -0.2
      size: 25 + _random.nextDouble() * 25, // Size 25-50
      speed: 0.002 + _random.nextDouble() * 0.003, // Vertical speed per tick
      rotationSpeed: (_random.nextDouble() - 0.5) * 0.1,
      angle: _random.nextDouble() * 2 * pi,
      wobbleSpeed: _random.nextDouble() * 0.05,
      wobbleOffset: _random.nextDouble() * 2 * pi,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // Overlay confetti particles
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final height = constraints.maxHeight;

                return Stack(
                  children: _particles.map((particle) {
                    // Update position
                    particle.y += particle.speed;
                    particle.angle += particle.rotationSpeed;
                    
                    // Simple wobble effect
                    double wobble = sin(_controller.value * 2 * pi * 5 + particle.wobbleOffset) * 0.005;
                    particle.x += wobble;

                    // Reset if fell off screen
                    if (particle.y > 1.1) {
                      final newParticle = _createParticle();
                      particle.y = newParticle.y;
                      particle.x = newParticle.x;
                      particle.speed = newParticle.speed; 
                      particle.assetPath = newParticle.assetPath;
                    }

                    return Positioned(
                      left: particle.x * width,
                      top: particle.y * height,
                      child: Transform.rotate(
                        angle: particle.angle,
                        child: Image.asset(
                          particle.assetPath,
                          width: particle.size,
                          height: particle.size,
                          fit: BoxFit.contain,
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _ConfettiParticle {
  String assetPath;
  double x;
  double y;
  double size;
  double speed;
  double rotationSpeed;
  double angle;
  double wobbleSpeed;
  double wobbleOffset;

  _ConfettiParticle({
    required this.assetPath,
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.rotationSpeed,
    required this.angle,
    required this.wobbleSpeed,
    required this.wobbleOffset,
  });
}
