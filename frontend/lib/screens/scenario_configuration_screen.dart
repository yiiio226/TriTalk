import 'package:flutter/material.dart';
import '../models/scene.dart';
import 'chat_screen.dart';

class ScenarioConfigurationScreen extends StatefulWidget {
  final Scene scene;

  const ScenarioConfigurationScreen({super.key, required this.scene});

  @override
  State<ScenarioConfigurationScreen> createState() => _ScenarioConfigurationScreenState();
}

class _ScenarioConfigurationScreenState extends State<ScenarioConfigurationScreen> {
  String _selectedSpeed = 'Normal'; // Slow, Normal
  String _selectedPersonality = 'Gentle'; // Gentle, Strict, Humorous

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Back to scenarios', style: TextStyle(color: Colors.black, fontSize: 16)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Configure your practice session',
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            
            // Speed Section
            _buildSectionTitle('AI Speaking Speed', Icons.volume_up_outlined),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildSelectionCard('Slow', '🐢', _selectedSpeed == 'Slow', () => setState(() => _selectedSpeed = 'Slow'))),
                const SizedBox(width: 16),
                Expanded(child: _buildSelectionCard('Normal', '🚶', _selectedSpeed == 'Normal', () => setState(() => _selectedSpeed = 'Normal'))),
              ],
            ),
            const SizedBox(height: 32),

            // Personality Section
            _buildSectionTitle('AI Personality', Icons.sentiment_satisfied_outlined),
            const SizedBox(height: 16),
            _buildPersonalityCard('Gentle', 'Patient and encouraging', Icons.sentiment_satisfied, _selectedPersonality == 'Gentle', () => setState(() => _selectedPersonality = 'Gentle')),
            const SizedBox(height: 12),
            _buildPersonalityCard('Strict', 'Direct and challenging', Icons.flash_on, _selectedPersonality == 'Strict', () => setState(() => _selectedPersonality = 'Strict')),
            const SizedBox(height: 12),
            _buildPersonalityCard('Humorous', 'Fun and lighthearted', Icons.sentiment_very_satisfied, _selectedPersonality == 'Humorous', () => setState(() => _selectedPersonality = 'Humorous')),

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
                  backgroundColor: const Color(0xFF007AFF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Start Practice', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF1A1A1A)),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
      ],
    );
  }

  Widget _buildSelectionCard(String title, String emoji, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF2F8FF) : Colors.white,
          border: Border.all(color: isSelected ? const Color(0xFF007AFF) : Colors.grey.shade300, width: isSelected ? 2 : 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: isSelected ? const Color(0xFF007AFF) : Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalityCard(String title, String subtitle, IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF2F8FF) : Colors.white,
          border: Border.all(color: isSelected ? const Color(0xFF007AFF) : Colors.grey.shade300, width: isSelected ? 2 : 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black87),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
