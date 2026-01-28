import 'package:flutter/material.dart';
import 'package:frontend/core/design/app_design_system.dart';
import 'package:frontend/features/subscription/domain/models/subscription_tier.dart';

class SubscriptionSuccessScreen extends StatefulWidget {
  final SubscriptionTier tier;

  const SubscriptionSuccessScreen({
    super.key,
    required this.tier,
  });

  @override
  State<SubscriptionSuccessScreen> createState() =>
      _SubscriptionSuccessScreenState();
}

class _SubscriptionSuccessScreenState extends State<SubscriptionSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.8, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _planName {
    switch (widget.tier) {
      case SubscriptionTier.plus:
        return 'TriTalk Plus';
      case SubscriptionTier.pro:
        return 'TriTalk Pro';
      default:
        return 'Premium';
    }
  }

  Color get _themeColor {
    return widget.tier == SubscriptionTier.pro
        ? AppColors.secondary
        : AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background confetti-like decorations (static but decorative)
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _themeColor.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _themeColor.withOpacity(0.1),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success Icon Animation
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: _themeColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.celebration_rounded,
                      size: 64,
                      color: _themeColor,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Text Content Animation
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          Text(
                            'Congratulations!',
                            style: AppTypography.headline1.copyWith(
                              color: AppColors.ln900,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'You are now a member of',
                            style: AppTypography.body1.copyWith(
                              color: AppColors.ln500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _planName,
                            style: AppTypography.headline2.copyWith(
                              color: _themeColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 48),

                          // Action Button
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              decoration: BoxDecoration(
                                color: _themeColor,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.full),
                                boxShadow: [
                                  BoxShadow(
                                    color: _themeColor.withOpacity(0.4),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Start Learning',
                                style: AppTypography.button.copyWith(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
