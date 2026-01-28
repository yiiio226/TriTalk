import 'package:flutter/material.dart';
import 'package:frontend/features/scenes/domain/models/scene.dart';
import 'package:frontend/core/design/app_design_system.dart';
import 'package:frontend/core/widgets/bouncing_button.dart';
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
  final String _selectedSpeed = 'Normal'; // Slow, Normal
  String _selectedPersonality = 'Gentle'; // Gentle, Strict, Humorous
  late String _aiRole;
  late String _userRole;

  @override
  void initState() {
    super.initState();
    _aiRole = widget.scene.aiRole;
    _userRole = widget.scene.userRole;
  }

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
                  BouncingButton(
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Configure your practice session',
                        style: TextStyle(fontSize: 16, color: AppColors.lightTextSecondary),
                      ),
                      const SizedBox(height: 24),

                      // Role Display Section
                      _buildRoleDisplaySection(),
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
              const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            // Fixed Bottom Button
            Container(
              color: AppColors.lightBackground,
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: 56,
                  child: BouncingButton(
                    onTap: () {
                      // Create updated scene with modified roles and personality
                      final updatedScene = Scene(
                        id: widget.scene.id,
                        title: widget.scene.title,
                        description: widget.scene.description,
                        emoji: widget.scene.emoji,
                        aiRole: _aiRole,
                        userRole: _userRole,
                        initialMessage: widget.scene.initialMessage,
                        category: widget.scene.category,
                        difficulty: widget.scene.difficulty,
                        goal: widget.scene.goal,
                        iconPath: widget.scene.iconPath,
                        color: widget.scene.color,
                        personality:
                            _selectedPersonality, // Pass selected personality
                      );
                      
                      // Navigate to ChatScreen with updated scene
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(scene: updatedScene),
                        ),
                      );
                    },
                    scaleFactor: 0.98,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Start Practice',
                        style: AppTypography.button.copyWith(
                          fontSize: 18,
                          color: AppColors.darkTextPrimary,
                        ),
                      ),
                    ),
                  ),
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
    return BouncingButton(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary : AppColors.dn900,
          border: Border.all(
            color: isSelected ? AppColors.lightDivider : AppColors.lightDivider,
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
    return BouncingButton(
      onTap: onTap,
      scaleFactor: 0.98,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary : AppColors.dn900,
          border: Border.all(
            color: isSelected ? AppColors.lightDivider : AppColors.lightDivider,
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

  Widget _buildRoleDisplaySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section title with Switch button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Role Assignment',
                  style: AppTypography.subtitle1.copyWith(
                    color: AppColors.lightTextSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            BouncingButton(
              onTap: _swapRoles,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.swap_horiz_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Switch',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildRoleCard(
          'AI Role',
          _aiRole,
          Icons.smart_toy_outlined,
          AppColors.primary,
        ),
        const SizedBox(height: 12),
        _buildRoleCard(
          'Your Role',
          _userRole,
          Icons.person_outline,
          AppColors.secondary,
        ),
      ],
    );
  }

  Widget _buildRoleCard(String label, String role, IconData icon, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.lightDivider),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.lightTextSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  role,
                  style: AppTypography.body1.copyWith(
                    color: AppColors.lightTextPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _swapRoles() {
    setState(() {
      final temp = _aiRole;
      _aiRole = _userRole;
      _userRole = temp;
    });
  }
}
