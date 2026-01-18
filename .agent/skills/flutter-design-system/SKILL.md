---
name: flutter-design-system
description: Enforces TriTalk's Flutter design system conventions. Use when creating or modifying UI components, colors, or styling. | 强制执行 TriTalk 的 Flutter 设计系统规范。在创建或修改 UI 组件、颜色或样式时使用。
---

# Flutter Design System Skill | Flutter 设计系统技能

This skill ensures consistent use of the TriTalk design system across all Flutter UI code.
此技能确保所有 Flutter UI 代码一致使用 TriTalk 设计系统。

## When to use | 何时使用

- Creating new widgets or screens | 创建新的 widgets 或页面
- Modifying existing UI components | 修改现有 UI 组件
- Working with colors, typography, or spacing | 处理颜色、字体或间距
- Building bottom sheets, dialogs, or overlays | 构建底部弹窗、对话框或遮罩层

## Design System Reference | 设计系统参考

Always import and use tokens from `app_design_system.dart`:
始终从 `app_design_system.dart` 导入并使用设计令牌：

```dart
import 'package:tritalk/core/design/app_design_system.dart';
```

## Color Conventions | 颜色规范

### DO ✅ | 正确做法
```dart
color: AppColors.primary,
color: AppColors.ln700,  // Light neutral | 浅色中性色
color: AppColors.dn200,  // Dark neutral | 深色中性色
color: AppColors.lb100,  // Light blue tint | 浅蓝色调
```

### DON'T ❌ | 错误做法
```dart
color: Colors.blue,           // Hardcoded Flutter colors | 硬编码 Flutter 颜色
color: Color(0xFF123456),     // Hardcoded hex values | 硬编码十六进制值
color: Colors.grey[600],      // Grey shades | 灰色阴影
```

## Neutral Color Scale | 中性色阶

| Light Mode 浅色模式 | Dark Mode 深色模式 | Usage 用途 |
|---------------------|-------------------|------------|
| ln50 | dn900 | Backgrounds 背景 |
| ln100-ln200 | dn700-dn800 | Borders, dividers 边框、分隔线|
| ln300-ln900 | dn50-dn300 | Text, icons 文字、图标 |

## Common Patterns | 常用模式

### Bottom Sheet Headers | 底部弹窗头部
```dart
// Drag handle | 拖拽手柄
Container(
  width: 40,
  height: 4,
  decoration: BoxDecoration(
    color: AppColors.ln300,
    borderRadius: BorderRadius.circular(2),
  ),
)

// Close button with circular background | 圆形背景关闭按钮
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

### Collapsible Sections | 可折叠区块
Use `ExpansionTile` with consistent styling for collapsible content sections.
使用 `ExpansionTile` 并保持一致的样式来实现可折叠内容区块。

## Before Making Changes | 修改前检查

1. Check `app_design_system.dart` for existing color tokens | 检查 `app_design_system.dart` 中现有的颜色令牌
2. Use semantic color names when available | 尽可能使用语义化的颜色名称
3. Ensure dark mode compatibility with dn* colors | 确保使用 dn* 颜色以兼容深色模式
