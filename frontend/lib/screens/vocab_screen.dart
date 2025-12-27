import 'package:flutter/material.dart';
import '../services/vocab_service.dart';
import '../widgets/empty_state_widget.dart';

class VocabScreen extends StatelessWidget {
  const VocabScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Using AnimatedBuilder to listen to ChangeNotifier for MVP simplicity
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Custom Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Vocabulary',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Content
            Expanded(
              child: AnimatedBuilder(
                animation: VocabService(),
                builder: (context, child) {
                  final service = VocabService();
                  if (service.isLoading && service.items.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  final items = service.items;
                  if (items.isEmpty) {
                    return const EmptyStateWidget(
                      message: 'No vocabulary saved yet',
                      imagePath: 'assets/empty_state_pear.png',
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        leading: const Icon(Icons.bookmark, color: Colors.amber),
                        title: Text(item.phrase),
                        subtitle: Text(item.translation),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            VocabService().remove(item.phrase);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
