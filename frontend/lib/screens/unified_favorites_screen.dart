import 'package:flutter/material.dart';
import '../widgets/vocab_list_widget.dart';
import '../widgets/grammar_list_widget.dart'; // Transformed from sentence_list_widget
import '../widgets/saved_sentence_list_widget.dart'; // For full sentences
import '../widgets/chat_history_list_widget.dart';

class UnifiedFavoritesScreen extends StatefulWidget {
  const UnifiedFavoritesScreen({Key? key}) : super(key: key);

  @override
  State<UnifiedFavoritesScreen> createState() => _UnifiedFavoritesScreenState();
}

class _UnifiedFavoritesScreenState extends State<UnifiedFavoritesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this); // Increased to 4
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Custom Header with Back Button
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
                    'Favorites',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Tab Bar
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.black,
                  indicatorWeight: 3,
                  isScrollable: true, // Allow scrolling if tabs don't fit
                  tabAlignment: TabAlignment.start, // Align tabs to the start
                  padding: const EdgeInsets.symmetric(horizontal: 10), // Match header padding
                  labelPadding: const EdgeInsets.only(right: 24), // Add space between tabs, but not before first
                  labelStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                  tabs: const [
                    Tab(text: 'Vocabulary'),
                    Tab(text: 'Grammar'),
                    Tab(text: 'Sentence'),
                    Tab(text: 'Chat'),
                  ],
                ),
              ),
            ),
            
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  VocabListWidget(),
                  GrammarListWidget(),
                  SavedSentenceListWidget(),
                  ChatHistoryListWidget(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
