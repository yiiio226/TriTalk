import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:frontend/features/scenes/domain/models/scene.dart';
import '../../../scenes/presentation/widgets/scene_card.dart';
import '../../../scenes/presentation/widgets/custom_scene_dialog.dart';
import '../../../scenes/presentation/widgets/scene_options_drawer.dart';
import 'package:frontend/core/widgets/styled_drawer.dart';
import '../../../chat/data/chat_history_service.dart';
import 'package:frontend/features/auth/data/services/auth_service.dart';
import '../../../scenes/data/scene_service.dart';
import 'package:frontend/core/widgets/top_toast.dart';
import 'package:frontend/core/design/app_design_system.dart';
import '../../../chat/presentation/pages/chat_screen.dart';
import '../../../profile/presentation/pages/profile_screen.dart';
import '../../../scenes/presentation/pages/scenario_configuration_screen.dart';
import 'package:frontend/core/utils/l10n_ext.dart';
import 'package:frontend/core/data/language_constants.dart';
import 'package:frontend/features/subscription/presentation/feature_gate.dart';
import 'package:frontend/features/subscription/domain/models/paid_feature.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // _scenes is now managed by SceneService
  bool _isGridView = true;
  bool _isDragging = false;
  final ValueNotifier<Offset> _dragPosition = ValueNotifier(Offset.zero);

  @override
  void initState() {
    super.initState();
    // Listen to changes in SceneService
    SceneService().addListener(_onScenesChanged);
  }

  @override
  void dispose() {
    SceneService().removeListener(_onScenesChanged);
    super.dispose();
  }

  void _onScenesChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final scenes = SceneService().scenes;

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: _isDragging
          ? null
          : FloatingActionButton(
              onPressed: () {
                // Style 1: Callback for navigation action
                FeatureGate().performWithFeatureCheck(
                  context,
                  feature: PaidFeature.customScenarios,
                  onGranted: () async {
                    final result = await showModalBottomSheet<Scene>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      barrierColor: Colors.white.withValues(alpha: 0.5),
                      builder: (context) => Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: const CustomSceneDialog(),
                      ),
                    );

                    if (result != null) {
                      // Add via service
                      await SceneService().addScene(result);
                      // Navigate to configuration screen
                      if (!mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ScenarioConfigurationScreen(scene: result),
                        ),
                      );
                    }
                  },
                );
              },
              backgroundColor: Colors.black,
              elevation: 4,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, color: Colors.white),
            ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // 1. Fixed Header Area
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TriTalk',
                            style: AppTypography.headline1.copyWith(
                              color: AppColors.lightTextPrimary,
                            ),
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isGridView = !_isGridView;
                                  });
                                },
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey[100],
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    _isGridView
                                        ? Icons.view_agenda_rounded
                                        : Icons.grid_view_rounded,
                                    color: AppColors.lightTextPrimary,
                                    size: 24,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ProfileScreen(),
                                    ),
                                  ).then((_) => setState(() {}));
                                },
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey[100],
                                  ),
                                  child: ClipOval(child: _buildAvatar()),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.home_chooseScenario(
                          LanguageConstants.getLabel(
                            LanguageConstants.getIsoCode(
                              AuthService().currentUser?.targetLanguage,
                            ),
                          ).replaceAll(RegExp(r'\s*\(.*?\)|（.*?）'), ''),
                        ),
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),

                // 2. Scrollable Content Area with Refresh
                Expanded(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    slivers: [
                      // Refresh Control inside standard scroll view (appears below header)
                      CupertinoSliverRefreshControl(onRefresh: _onRefresh),

                      SliverPadding(
                        padding: const EdgeInsets.all(20),
                        sliver: SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: _isGridView ? 2 : 1,
                                childAspectRatio: _isGridView ? 0.75 : 2.4,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final scene = scenes[index];
                            return LongPressDraggable<Scene>(
                              data: scene,
                              delay: const Duration(milliseconds: 300),
                              onDragStarted: () {
                                setState(() {
                                  _isDragging = true;
                                });
                              },
                              onDragUpdate: (details) {
                                _dragPosition.value = details.globalPosition;
                              },
                              onDragEnd: (details) {
                                setState(() {
                                  _isDragging = false;
                                });
                              },
                              onDraggableCanceled: (velocity, offset) {
                                setState(() {
                                  _isDragging = false;
                                });
                              },
                              feedback: ValueListenableBuilder<Offset>(
                                valueListenable: _dragPosition,
                                builder: (context, currentPosition, child) {
                                  final screenSize = MediaQuery.of(
                                    context,
                                  ).size;
                                  final targetPos = Offset(
                                    screenSize.width - 52,
                                    screenSize.height - 132,
                                  );

                                  final distance =
                                      (currentPosition - targetPos).distance;
                                  final scale = (distance / 300).clamp(
                                    0.4,
                                    1.05,
                                  );

                                  return Transform.scale(
                                    scale: scale,
                                    child: Material(
                                      color: Colors.transparent,
                                      child: SizedBox(
                                        width: _isGridView
                                            ? (MediaQuery.of(
                                                        context,
                                                      ).size.width -
                                                      56) /
                                                  2
                                            : MediaQuery.of(
                                                    context,
                                                  ).size.width -
                                                  40,
                                        height: _isGridView
                                            ? ((MediaQuery.of(
                                                            context,
                                                          ).size.width -
                                                          56) /
                                                      2) /
                                                  0.75
                                            : (MediaQuery.of(
                                                        context,
                                                      ).size.width -
                                                      40) /
                                                  2.4,
                                        child: Opacity(
                                          opacity: 0.9,
                                          child: SceneCard(
                                            scene: scene,
                                            showRole: !_isGridView,
                                            onTap: () {},
                                            onLongPress: null,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.3,
                                child: SceneCard(
                                  scene: scene,
                                  showRole: !_isGridView,
                                  onTap: () {},
                                  onLongPress: null,
                                ),
                              ),
                              child: DragTarget<Scene>(
                                onAcceptWithDetails: (details) async {
                                  final draggedScene = details.data;
                                  // Find the indices of the dragged and target scenes
                                  final oldIndex = scenes.indexWhere(
                                    (s) => s.id == draggedScene.id,
                                  );
                                  final newIndex = index;

                                  if (oldIndex != -1 && oldIndex != newIndex) {
                                    // Reorder via service
                                    await SceneService().reorderScenes(
                                      oldIndex,
                                      newIndex,
                                    );
                                  }
                                },
                                builder: (context, candidateData, rejectedData) {
                                  final isHovering = candidateData.isNotEmpty;
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      border: isHovering
                                          ? Border.all(
                                              color: Colors.black,
                                              width: 1,
                                            )
                                          : null,
                                    ),
                                    child: SceneCard(
                                      scene: scene,
                                      showRole: !_isGridView,
                                      onTap: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ChatScreen(scene: scene),
                                          ),
                                        );

                                        if (result == 'delete') {
                                          await SceneService().deleteScene(
                                            scene.id,
                                          );
                                        }
                                      },
                                      onLongPress: () {
                                        if (!_isDragging) {
                                          showModalBottomSheet(
                                            context: context,
                                            backgroundColor: Colors.transparent,
                                            barrierColor: Colors.white
                                                .withValues(alpha: 0.5),
                                            builder: (context) =>
                                                SceneOptionsDrawer(
                                                  onClear: () =>
                                                      _showClearConfirmation(
                                                        context,
                                                        scene,
                                                      ),
                                                  onDelete: () =>
                                                      _showDeleteConfirmation(
                                                        context,
                                                        scene,
                                                      ),
                                                  onBookmark: () =>
                                                      _bookmarkConversation(
                                                        context,
                                                        scene,
                                                      ),
                                                ),
                                          );
                                        }
                                      },
                                    ),
                                  );
                                },
                              ),
                            );
                          }, childCount: scenes.length),
                        ),
                      ),

                      // Bottom Padding
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 100), // Space for FAB
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Side Action Panel
            if (_isDragging)
              Positioned(
                right: 20,
                bottom: 20,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDragTarget(
                      icon: Icons.refresh,
                      color: Colors.blue,
                      label: 'Clear',
                      onAccept: (scene) =>
                          _showClearConfirmation(context, scene),
                    ),
                    const SizedBox(height: 16),
                    _buildDragTarget(
                      icon: Icons.bookmark_border,
                      color: Colors.orange,
                      label: 'Save',
                      onAccept: (scene) =>
                          _bookmarkConversation(context, scene),
                    ),
                    const SizedBox(height: 16),
                    _buildDragTarget(
                      icon: Icons.delete_outline,
                      color: Colors.red,
                      label: 'Delete',
                      onAccept: (scene) =>
                          _showDeleteConfirmation(context, scene),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  static Future<void> _onRefresh() async {
    // Min wait time for better UX
    await Future.wait([
      SceneService().refreshScenes(),
      Future.delayed(const Duration(milliseconds: 800)),
    ]);
  }

  Widget _buildDragTarget({
    required IconData icon,
    required Color color,
    required String label,
    required Function(Scene) onAccept,
  }) {
    return DragTarget<Scene>(
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        return SizedBox(
          width: 64,
          height: 64,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isHovering ? 64 : 56,
              height: isHovering ? 64 : 56,
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: isHovering ? Border.all(color: color, width: 2) : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: isHovering ? color : Colors.white,
                    size: isHovering ? 28 : 24,
                  ),
                ],
              ),
            ),
          ),
        );
      },
      onWillAcceptWithDetails: (details) => true,
      onAcceptWithDetails: (details) => onAccept(details.data),
    );
  }

  void _bookmarkConversation(BuildContext context, Scene scene) async {
    final sceneKey = scene.id;
    final history = await ChatHistoryService().getMessages(sceneKey);
    final nonEmptyMessages = history
        .where((m) => m.content.isNotEmpty && !m.isLoading)
        .toList();

    if (nonEmptyMessages.isEmpty) {
      if (mounted) {
        showTopToast(context, "No messages to bookmark", isError: true);
      }
      return;
    }

    final lastMessage = nonEmptyMessages.last.content;
    final preview = lastMessage.length > 50
        ? '${lastMessage.substring(0, 50)}...'
        : lastMessage;

    final now = DateTime.now();
    final dateStr = "${now.month}/${now.day}";

    ChatHistoryService().addBookmark(
      scene.title,
      preview,
      dateStr,
      sceneKey,
      nonEmptyMessages,
    );

    if (mounted) {
      showTopToast(context, "Saved to Favorites", isError: false);
    }
  }

  void _showClearConfirmation(BuildContext context, Scene scene) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.white.withValues(alpha: 0.5),
      builder: (context) => StyledDrawer(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Clear Conversation',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                  child: Text(
                    context.l10n.home_cancel,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () async {
                    final sceneKey = scene.id;
                    await ChatHistoryService().clearHistory(sceneKey);
                    if (mounted) {
                      setState(() {});
                      showTopToast(
                        context,
                        'Conversation cleared',
                        isError: false,
                      );
                      Navigator.pop(context);
                    }
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
      barrierColor: Colors.white.withValues(alpha: 0.5),
      builder: (context) => StyledDrawer(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delete Conversation',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                  child: Text(
                    context.l10n.home_cancel,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    final sceneKey = scene.id;
                    ChatHistoryService().clearHistory(sceneKey);

                    // Delete scene (Standard scenes will be hidden, Custom scenes deleted)
                    await SceneService().deleteScene(scene.id);
                    if (mounted) {
                      showTopToast(context, 'Scene deleted', isError: false);
                    }
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

  Widget _buildAvatar() {
    final user = AuthService().currentUser;
    final avatarUrl = user?.avatarUrl;

    // Priority: Google avatar > Gender-based avatar > Default
    if (avatarUrl != null &&
        avatarUrl.isNotEmpty &&
        !avatarUrl.startsWith('assets/')) {
      // Use Google profile picture
      return Image.network(
        avatarUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to gender-based avatar if network image fails
          return _buildLocalAvatar(user?.gender);
        },
      );
    } else {
      // Use local avatar based on gender
      return _buildLocalAvatar(user?.gender);
    }
  }

  Widget _buildLocalAvatar(String? gender) {
    final assetPath = gender == 'female'
        ? 'assets/images/avatars/user_avatar_female.png'
        : 'assets/images/avatars/user_avatar_male.png';

    return Image.asset(assetPath, fit: BoxFit.cover);
  }
}
