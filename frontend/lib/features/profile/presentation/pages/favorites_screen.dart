import 'package:flutter/material.dart';
import '../../../../features/study/presentation/widgets/vocab_list_widget.dart';
import '../../../../features/study/presentation/widgets/grammar_list_widget.dart'; // Transformed from sentence_list_widget
import '../../../../features/study/presentation/widgets/saved_sentence_list_widget.dart'; // For full sentences
import '../../../../features/chat/presentation/widgets/chat_history_list_widget.dart';
import '../../../../design/app_design_system.dart';

class UnifiedFavoritesScreen extends StatefulWidget {
  final String? sceneId; // Optional filter

  const UnifiedFavoritesScreen({super.key, this.sceneId});

  @override
  State<UnifiedFavoritesScreen> createState() => _UnifiedFavoritesScreenState();
}

class _UnifiedFavoritesScreenState extends State<UnifiedFavoritesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // If sceneId is provided (conversation-specific), show 3 tabs (no Chat)
    // Otherwise show all 4 tabs
    final tabCount = widget.sceneId != null ? 3 : 4;
    _tabController = TabController(length: tabCount, vsync: this);
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
                  Text(
                    'Favorites',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tab Bar
            Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ), // Increased left padding
                  labelPadding: const EdgeInsets.only(
                    right: 24,
                  ), // Add space between tabs, but not before first
                  labelStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                  tabs: [
                    const Tab(text: 'Vocabulary'),
                    const Tab(text: 'Sentence'),
                    const Tab(text: 'Grammar'),
                    if (widget.sceneId == null)
                      const Tab(text: 'Chat'), // Only show in global favorites
                  ],
                ),
              ),
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  VocabListWidget(sceneId: widget.sceneId),
                  SavedSentenceListWidget(sceneId: widget.sceneId),
                  GrammarListWidget(sceneId: widget.sceneId),
                  if (widget.sceneId == null)
                    ChatHistoryListWidget(
                      sceneId: widget.sceneId,
                    ), // Only show in global favorites
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
