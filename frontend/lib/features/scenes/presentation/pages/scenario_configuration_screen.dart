import 'package:flutter/material.dart';
import 'package:frontend/features/scenes/domain/models/scene.dart';
import 'package:frontend/core/design/app_design_system.dart';
import '../../../chat/presentation/pages/chat_screen.dart';

class ScenarioConfigurationScreen extends StatefulWidget {
  final Scene scene;

  const ScenarioConfigurationScreen({super.key, required this.scene});

  @override
  State<ScenarioConfigurationScreen> createState() =>
      _ScenarioConfigurationScreenState();
}

class _ScenarioConfigurationScreenState
    extends State<ScenarioConfigurationScreen> {
  String _selectedSpeed = 'Normal'; // Slow, Normal
  String _selectedPersonality = 'Gentle'; // Gentle, Strict, Humorous

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightSurface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Custom Header
            Container(
              color: AppColors.lightSurface,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.lightBackground,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.lightTextPrimary,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Back to scenarios',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightTextPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: Container(
                color: AppColors.lightBackground,
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Configure your practice session',
                      style: TextStyle(fontSize: 16, color: AppColors.lightTextSecondary),
                    ),
                    const SizedBox(height: 32),

            // Speed Section
            _buildSectionTitle('AI Speaking Speed', Icons.volume_up_outlined, AppColors.lightTextSecondary),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSelectionCard(
                    'Slow',
                    '🐢',
                    _selectedSpeed == 'Slow',
                    () => setState(() => _selectedSpeed = 'Slow'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSelectionCard(
                    'Normal',
                    '🚶',
                    _selectedSpeed == 'Normal',
                    () => setState(() => _selectedSpeed = 'Normal'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Personality Section
            _buildSectionTitle(
              'AI Personality',
              Icons.sentiment_satisfied_outlined,
              AppColors.lightTextSecondary,
            ),
            const SizedBox(height: 16),
            _buildPersonalityCard(
              'Gentle',
              'Patient and encouraging',
              Icons.sentiment_satisfied,
              _selectedPersonality == 'Gentle',
              () => setState(() => _selectedPersonality = 'Gentle'),
            ),
            const SizedBox(height: 12),
            _buildPersonalityCard(
              'Strict',
              'Direct and challenging',
              Icons.flash_on,
              _selectedPersonality == 'Strict',
              () => setState(() => _selectedPersonality = 'Strict'),
            ),
            const SizedBox(height: 12),
            _buildPersonalityCard(
              'Humorous',
              'Fun and lighthearted',
              Icons.sentiment_very_satisfied,
              _selectedPersonality == 'Humorous',
              () => setState(() => _selectedPersonality = 'Humorous'),
            ),

            const Spacer(),

            // Start Button
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to ChatScreen
                  // Note: Logic to pass personality/speed to ChatScreen would go here
                  // For now, we just pass the generated scene
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(scene: widget.scene),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: Text(
                  'Start Practice',
                  style: AppTypography.button.copyWith(
                    fontSize: 18,
                    color: AppColors.darkTextPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, [Color? color]) {
    final effectiveColor = color ?? AppColors.lightTextSecondary;
    return Row(
      children: [
        Icon(icon, color: effectiveColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTypography.subtitle1.copyWith(
            color: effectiveColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionCard(
    String title,
    String emoji,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.lightDivider,
            width: isSelected ? 1 : 1,
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppTypography.subtitle2.copyWith(
                color: AppColors.lightTextPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalityCard(
    String title,
    String subtitle,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.lightDivider,
            width: isSelected ? 1 : 1,
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.lightTextPrimary),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.subtitle2.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTypography.body2.copyWith(
                    color: AppColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
