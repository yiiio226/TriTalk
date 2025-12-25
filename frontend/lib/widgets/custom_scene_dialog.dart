import 'package:flutter/material.dart';
import '../models/scene.dart';
import '../services/api_service.dart';
import 'top_toast.dart';
class CustomSceneDialog extends StatefulWidget {
  const CustomSceneDialog({Key? key}) : super(key: key);

  @override
  State<CustomSceneDialog> createState() => _CustomSceneDialogState();
}

class _CustomSceneDialogState extends State<CustomSceneDialog> {
  final TextEditingController _scenarioController = TextEditingController();
  String _selectedTone = 'Casual'; // Formal, Casual
  String _selectedLength = 'Brief'; // Brief, Detailed
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
        _selectedTone
      );

      final newScene = Scene(
        id: DateTime.now().toString(),
        title: generatedScene.title,
        description: generatedScene.description,
        aiRole: generatedScene.aiRole,
        userRole: generatedScene.userRole,
        category: 'Custom',
        difficulty: _selectedTone, 
        initialMessage: generatedScene.initialMessage,
        goal: generatedScene.goal,
        emoji: generatedScene.emoji,
        color: 0xFF9C27B0, // Purple for custom
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
      final polished = await ApiService().polishScenario(text);
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
      showTopToast(context, 'Failed to polish scenario: $errorMessage', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Create Your Own Scenario',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[50],
              ),
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  TextField(
                    controller: _scenarioController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText:
                          'Example: I need to return a defective product, but the store clerk is being difficult...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.fromLTRB(16, 16, 40, 16),
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
                              color: Colors.black.withOpacity(0.1),
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
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                                ),
                              )
                            : const Icon(
                                Icons.auto_awesome,
                                size: 18,
                                color: Colors.blue,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _generateScene,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Generate Scenario',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionChip(String label, String groupValue, Function(String) onSelect) {
    final isSelected = label == groupValue;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) onSelect(label);
      },
    );
  }
}
