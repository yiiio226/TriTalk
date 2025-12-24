import 'package:flutter/material.dart';

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

    // TODO: Call API to generate scene
    await Future.delayed(const Duration(seconds: 2)); // Mock delay

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    Navigator.of(context).pop(); // Close dialog for now
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Scene Generation Mock Success!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Create Custom Scene',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _scenarioController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Scenario Description',
                hintText: 'e.g., I want to return a defective product to a store...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('AI Persona Style', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildOptionChip('Casual', _selectedTone, (val) {
                    setState(() => _selectedTone = val);
                  }),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildOptionChip('Formal', _selectedTone, (val) {
                    setState(() => _selectedTone = val);
                  }),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildOptionChip('Brief', _selectedLength, (val) {
                    setState(() => _selectedLength = val);
                  }),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildOptionChip('Detailed', _selectedLength, (val) {
                    setState(() => _selectedLength = val);
                  }),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _generateScene,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Start Chat'),
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
