import 'package:flutter/material.dart';
import '../../../../features/study/presentation/widgets/vocab_list_widget.dart';
import '../../../../features/study/presentation/widgets/grammar_list_widget.dart'; // Transformed from sentence_list_widget
import '../../../../features/study/presentation/widgets/saved_sentence_list_widget.dart'; // For full sentences
import '../../../../features/chat/presentation/widgets/chat_history_list_widget.dart';
import 'package:frontend/core/design/app_design_system.dart';
import '../../../study/data/vocab_service.dart';
import '../../../chat/data/chat_history_service.dart';

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
    
    // Trigger data refresh when screen opens
    _refreshData();
  }

  Future<void> _refreshData() async {
    // Refresh vocabulary data (covers Vocabulary, Sentence, Grammar tabs)
    await VocabService().refresh();
    
    // Refresh chat history bookmarks (Chat tab)
    if (widget.sceneId == null) {
      await ChatHistoryService().refreshBookmarks();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightSurface, 
      
   
      body: SafeArea(
        child: Column(
          children: [
            // Unified Header + TabBar Container
            Container(
              color: AppColors.lightSurface,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  // Custom Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.lightBackground,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.arrow_back_rounded,
                              color: AppColors.lightTextPrimary,
                              size: 24,
                            ),
                          ),
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
                      border: Border(
                        bottom: BorderSide(color: AppColors.lightDivider),
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TabBar(
                        controller: _tabController,
                        labelColor: AppColors.lightTextPrimary,
                        unselectedLabelColor: AppColors.lightTextSecondary,
                        indicatorColor: AppColors.primary,
                        dividerColor: Colors.transparent, // Remove default M3 divider
                        indicatorWeight: 3,
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        labelPadding: const EdgeInsets.only(right: 24),
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
                            const Tab(text: 'Chat'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tab Content
            Expanded(
              child: Container(
                color: AppColors.lightBackground,
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
            ),
          ],
        ),
      ),
    );
  }
}
