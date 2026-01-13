import 'package:flutter/material.dart';
import 'dart:math';
import 'package:uuid/uuid.dart';
import 'package:frontend/features/scenes/domain/models/scene.dart';
import '../../../../core/data/api/api_service.dart';
import 'package:frontend/core/widgets/top_toast.dart';
import 'package:frontend/core/widgets/styled_drawer.dart';
import 'package:frontend/core/design/app_design_system.dart';


class CustomSceneDialog extends StatefulWidget {
  const CustomSceneDialog({super.key});

  @override
  State<CustomSceneDialog> createState() => _CustomSceneDialogState();
}

class _CustomSceneDialogState extends State<CustomSceneDialog> {
  final _uuid = const Uuid();
  final TextEditingController _scenarioController = TextEditingController();
  final String _selectedTone = 'Casual'; // Formal, Casual

  bool _isLoading = false;
  bool _isPolishing = false;

  @override
  void dispose() {
    _scenarioController.dispose();
    super.dispose();
  }

  void _generateScene() async {
    if (_scenarioController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    // Call API to generate scene
    try {
      final generatedScene = await ApiService().generateScene(
        _scenarioController.text.trim(),
        _selectedTone,
      );

      final newScene = Scene(
        id: _uuid.v4(),
        title: generatedScene.title,
        description: generatedScene.description,
        aiRole: generatedScene.aiRole,
        userRole: generatedScene.userRole,
        category: 'Custom',
        difficulty: _selectedTone,
        initialMessage: generatedScene.initialMessage,
        goal: generatedScene.goal,
        emoji: generatedScene.emoji,
        color: _generateRandomPastelColor(),
        iconPath: "",
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      Navigator.of(context).pop(newScene);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      showTopToast(context, 'Failed to generate scene: $e', isError: true);
    }
  }

  void _polishDescription() async {
    final text = _scenarioController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isPolishing = true;
    });

    try {
      final polished = await ApiService()
          .polishScenario(text)
          .timeout(const Duration(seconds: 30));
      if (!mounted) return;

      setState(() {
        _scenarioController.text = polished;
        _isPolishing = false;
      });
      showTopToast(context, 'Scenario polished successfully');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isPolishing = false;
      });
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      showTopToast(
        context,
        'Failed to polish scenario: $errorMessage',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StyledDrawer(
      height: MediaQuery.of(context).size.height * 0.60,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.minHeight),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: AppColors.primary),
                        const SizedBox(width: 8),
                        const Text(
                          'Create Your Own Scenario',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Describe a situation you want to practice. AI will create a roleplay scenario for you.',
                      style: TextStyle(color: AppColors.lightTextSecondary),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.lightDivider,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.lightBackground,
                        ),
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            TextField(
                              controller: _scenarioController,
                              maxLines: null,
                              minLines: null,
                              expands: true,
                              textAlignVertical: TextAlignVertical.top,
                              decoration: const InputDecoration(
                                hintText:
                                    'Example: I need to return a defective product, but the store clerk is being difficult...',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.fromLTRB(
                                  16,
                                  16,
                                  40,
                                  16,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: _isPolishing ? null : _polishDescription,
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.lightShadow,
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: _isPolishing
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  AppColors.primary,
                                                ),
                                          ),
                                        )
                                      : const Icon(
                                          Icons.auto_awesome,
                                          size: 18,
                                          color: AppColors.secondary,
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _generateScene,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              27,
                            ), // Rounded pill shape
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Generate Scenario',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  int _generateRandomPastelColor() {
    final random = Random();
    // Hue: 0-360
    final hue = random.nextDouble() * 360;
    // Saturation: 8% - 15% (Keeping it very subtle like the defaults)
    final saturation = 0.08 + random.nextDouble() * 0.07;
    // Value (Brightness): 95% - 100%
    final value = 0.95 + random.nextDouble() * 0.05;

    return HSVColor.fromAHSV(1.0, hue, saturation, value).toColor().toARGB32();
  }
}
