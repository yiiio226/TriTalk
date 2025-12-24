import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock history data
    final List<Map<String, dynamic>> mockHistory = [
      {
        'title': 'Rent an Apartment',
        'date': 'Yesterday',
        'preview': 'Would it be possible to check in early?',
      },
      {
        'title': 'Ordering Coffee',
        'date': '2 days ago',
        'preview': 'I would like a large latte with oat milk.',
      },
      {
        'title': 'Work Email',
        'date': 'Last Week',
        'preview': 'I am writing to inform you that...',
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Chat History')),
      body: ListView.separated(
        itemCount: mockHistory.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final item = mockHistory[index];
          return ListTile(
            title: Text(item['title']),
            subtitle: Text(item['preview'], maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: Text(item['date'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
            onTap: () {
               // Mock navigation to past chat
               ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text('Opening past chat... (Mock)')),
               );
            },
          );
        },
      ),
    );
  }
}
