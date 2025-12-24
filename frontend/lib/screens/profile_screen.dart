import 'package:flutter/material.dart';
import 'vocab_screen.dart';
import 'history_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        children: [
          const UserAccountsDrawerHeader(
            accountName: Text('User'),
            accountEmail: Text('user@example.com'),
            currentAccountPicture: CircleAvatar(
              child: Icon(Icons.person, size: 40),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.book, color: Colors.amber),
            title: const Text('Vocabulary Notebook'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VocabScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.history, color: Colors.blue),
            title: const Text('Chat History'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.star_border, color: Colors.purple),
            title: const Text('Upgrade to Pro'),
            subtitle: const Text('Get unlimited chats and advanced feedback'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to Paywall
              ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text('Paywall coming in Module 5')),
              );
            },
          ),
        ],
      ),
    );
  }
}
