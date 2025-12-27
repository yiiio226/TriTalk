import 'package:flutter/material.dart';
import '../services/vocab_service.dart';
import '../widgets/empty_state_widget.dart';

class VocabScreen extends StatelessWidget {
  const VocabScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Using AnimatedBuilder to listen to ChangeNotifier for MVP simplicity
    return Scaffold(
      appBar: AppBar(title: const Text('Vocabulary')),
      body: AnimatedBuilder(
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
    );
  }
}
