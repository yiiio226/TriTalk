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
    required this.difficulty,
    required this.goal,
    required this.iconPath,
    required this.color,
  });

  final String difficulty; // Easy, Medium, Hard
  final String goal;
  final String iconPath;
  final int color; // Hex value for custom styling if needed, or we can resolve from difficulty
}
