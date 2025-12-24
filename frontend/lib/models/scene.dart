class Scene {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final String aiRole;
  final String userRole;
  final String initialMessage;
  final String category;

  const Scene({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.aiRole,
    required this.userRole,
    required this.initialMessage,
    required this.category,
  });
}
