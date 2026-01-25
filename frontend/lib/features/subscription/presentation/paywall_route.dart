import 'package:flutter/material.dart';
import 'package:frontend/features/subscription/presentation/pages/paywall_screen.dart';

class PaywallRoute {
  static Future<void> show(BuildContext context, {String? reason}) {
    // We could pass the reason to the PaywallScreen if needed
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PaywallScreen(),
        fullscreenDialog: true,
      ),
    );
  }
}
