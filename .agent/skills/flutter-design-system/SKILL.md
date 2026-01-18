---
name: flutter-design-system
description: Enforces TriTalk's Flutter design system conventions. Use when creating or modifying UI components, colors, or styling. | 强制执行 TriTalk 的 Flutter 设计系统规范。在创建或修改 UI 组件、颜色或样式时使用。
---

# Flutter Design System Skill

This skill ensures consistent use of the TriTalk design system across all Flutter UI code.

## When to use

- Creating new widgets or screens
- Modifying existing UI components
- Working with colors, typography, or spacing
- Building bottom sheets, dialogs, or overlays

## Design System Reference

Always import and use tokens from `app_design_system.dart`:

```dart
import 'package:tritalk/core/design/app_design_system.dart';
```

## Color Conventions

### DO ✅
```dart
color: AppColors.primary,
color: AppColors.ln700,  // Light neutral
color: AppColors.dn200,  // Dark neutral
color: AppColors.lb100,  // Light blue tint
```

### DON'T ❌
```dart
color: Colors.blue,           // Hardcoded Flutter colors
color: Color(0xFF123456),     // Hardcoded hex values
color: Colors.grey[600],      // Grey shades
```

## Neutral Color Scale

| Light Mode | Dark Mode | Usage |
|------------|-----------|-------|
| ln50-ln200 | dn700-dn900 | Backgrounds |
| ln300-ln500 | dn400-dn600 | Borders, dividers |
| ln600-ln900 | dn50-dn300 | Text, icons |

## Common Patterns

### Bottom Sheet Headers
```dart
// Drag handle
Container(
  width: 40,
  height: 4,
  decoration: BoxDecoration(
    color: AppColors.ln300,
    borderRadius: BorderRadius.circular(2),
  ),
)

// Close button with circular background
Container(
  decoration: BoxDecoration(
    color: AppColors.ln100,
    shape: BoxShape.circle,
  ),
  child: IconButton(
    icon: Icon(Icons.close, color: AppColors.ln600),
    onPressed: () => Navigator.pop(context),
  ),
)
```

### Collapsible Sections
Use `ExpansionTile` with consistent styling for collapsible content sections.

## Before Making Changes

1. Check `app_design_system.dart` for existing color tokens
2. Use semantic color names when available
3. Ensure dark mode compatibility with dn* colors
