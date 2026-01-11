import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../design/app_design_system.dart';
import '../services/revenue_cat_service.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: AppColors.lightTextPrimary),
        title: Text(
          'Upgrade to Pro',
          style: AppTypography.headline4.copyWith(
            color: AppColors.lightTextPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Premium Illustration
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/premium_illustration.png'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Text(
                      'Unlock Full Potential',
                      style: AppTypography.headline1.copyWith(
                        color: AppColors.lightTextPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Get unlimited conversations, advanced grammar analysis, and access to all premium scenarios.',
                      textAlign: TextAlign.center,
                      style: AppTypography.body1.copyWith(
                        color: AppColors.lightTextSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Feature List
                    _buildFeatureItem('Unlimited Messages'),
                    _buildFeatureItem('Advanced Grammar Feedback'),
                    _buildFeatureItem('Premium Scenarios'),
                    _buildFeatureItem('No Ads'),
                  ],
                ),
              ),
            ),
            
            // Bottom Action Area
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        RevenueCatService().mockPurchase();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Welcome to Pro!')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.lg - 6),
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                      ),
                      child: Text(
                        'Start 7-Day Free Trial',
                        style: AppTypography.button.copyWith(
                          fontSize: 18,
                          color: AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                       RevenueCatService().mockRestore();
                       Navigator.pop(context);
                       ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Purchases Restored')),
                       );
                    },
                    child: Text(
                      'Restore Purchases',
                      style: AppTypography.body2.copyWith(
                        fontSize: 15,
                        color: AppColors.lightTextSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.checkmark_alt_circle_fill,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 16),
          Text(
            text,
            style: AppTypography.body1.copyWith(
              color: AppColors.lightTextPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
