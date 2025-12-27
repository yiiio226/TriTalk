import 'package:flutter/material.dart';
import '../models/scene.dart';
import '../data/mock_scenes.dart';
import '../widgets/scene_card.dart';
import '../widgets/custom_scene_dialog.dart';
import '../widgets/scene_options_drawer.dart';
import '../services/chat_history_service.dart';
import '../widgets/top_toast.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import 'scenario_configuration_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Scene> _scenes;
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _scenes = List.from(mockScenes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showModalBottomSheet<Scene>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: const CustomSceneDialog(),
            ),
          );

          if (result != null) {
            setState(() {
              _scenes.add(result);
            });
            // Navigate to configuration screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ScenarioConfigurationScreen(scene: result),
              ),
            );
          }
        },
        backgroundColor: Colors.black,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TriTalk',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _isGridView = !_isGridView;
                              });
                            },
                            icon: Icon(
                              _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
                              color: Colors.grey[700],
                               size: 28,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ProfileScreen(),
                                ),
                              );
                            },
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[100],
                                image: const DecorationImage(
                                  image: AssetImage('assets/images/user_avatar_female.png'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose a scenario to practice your English',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _isGridView ? 2 : 1,
                  childAspectRatio: _isGridView ? 0.75 : 2.4, // Compact list view
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _scenes.length,
                itemBuilder: (context, index) {
                  final scene = _scenes[index];
                  return SceneCard(
                    scene: scene,
                    showRole: !_isGridView,
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(scene: scene),
                        ),
                      );

                      if (result == 'delete') {
                        setState(() {
                          _scenes.remove(scene);
                        });
                      }
                    },
                    onLongPress: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (context) => SceneOptionsDrawer(
                          onClear: () => _showClearConfirmation(context, scene),
                          onDelete: () => _showDeleteConfirmation(context, scene),
                          onBookmark: () => _bookmarkConversation(context, scene),
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

  void _bookmarkConversation(BuildContext context, Scene scene) {
    final sceneKey = "${scene.title}_${scene.aiRole}";
    final history = ChatHistoryService().getMessages(sceneKey);
    final nonEmptyMessages = history.where((m) => m.content.isNotEmpty && !m.isLoading).toList();
    
    if (nonEmptyMessages.isEmpty) {
      showTopToast(context, "No messages to bookmark", isError: true);
      return;
    }

    final lastMessage = nonEmptyMessages.last.content;
    final preview = lastMessage.length > 50 ? '${lastMessage.substring(0, 50)}...' : lastMessage;
    
    final now = DateTime.now();
    final dateStr = "${now.month}/${now.day}"; 

    ChatHistoryService().addBookmark(
      scene.title, 
      preview, 
      dateStr, 
      sceneKey, 
      nonEmptyMessages
    );

    showTopToast(context, "Conversation bookmarked!", isError: false);
  }

  void _showClearConfirmation(BuildContext context, Scene scene) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Clear Conversation',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Are you sure you want to clear this conversation and start over?',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    final sceneKey = "${scene.title}_${scene.aiRole}";
                    ChatHistoryService().clearHistory(sceneKey);
                  },
                  child: const Text(
                    'Clear',
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Scene scene) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delete Conversation',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Are you sure you want to delete this conversation? This will also remove it from your home screen.',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    final sceneKey = "${scene.title}_${scene.aiRole}";
                    ChatHistoryService().clearHistory(sceneKey);
                    setState(() {
                      _scenes.remove(scene);
                    });
                  },
                  child: const Text(
                    'Delete',
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}



