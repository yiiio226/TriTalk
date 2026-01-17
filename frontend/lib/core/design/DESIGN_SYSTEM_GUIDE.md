# TriTalk 设计系统使用指南

## 📚 概述

`app_design_system.dart` 包含了 TriTalk 应用的所有设计规范，包括颜色、字体、间距、圆角、阴影等。这个文件已经根据你当前应用中实际使用的设计元素进行了配置。

## 🎨 颜色使用

### 主要颜色

```dart
// iOS 蓝色 - 主要操作按钮、链接、选中状态
Container(
  color: AppColors.primaryLight,  // #007AFF
)

// Premium/Pro 颜色 - 付费功能、高级徽章
Container(
  color: AppColors.secondaryLight,  // #4F46E5 (Indigo)
)

// 文本颜色 - 深灰黑色
Text(
  'Hello',
  style: TextStyle(color: AppColors.textPrimaryLight),  // #1A1A1A
)

// 错误/删除 - iOS 红色
Text(
  'Delete',
  style: TextStyle(color: AppColors.errorLight),  // #FF3B30
)
```

### 分析卡片颜色

```dart
// 紫色背景 - 语法解释
Container(
  color: AppColors.analysisPurpleLight,  // #F3E5F5
)

// 蓝色背景 - 词汇
Container(
  color: AppColors.lightBlue,  // #E3F2FD
)

// 红色背景 - 纠错
Container(
  color: AppColors.analysisRedLight,  // #FFEBEE
)
```

### 反馈高亮渐变

```dart
// 聊天气泡的反馈高亮
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [
        AppColors.feedbackGradientStart,  // #FFF8E1
        AppColors.feedbackGradientEnd,    // #FFECB3
      ],
    ),
  ),
)
```

## 📝 字体排版

### 标题

```dart
// 大标题 - 页面主标题
Text(
  'TriTalk',
  style: AppTypography.headline1,  // 32px, Bold
)

// 二级标题 - 区块标题
Text(
  'Scenarios',
  style: AppTypography.headline2,  // 28px, Bold
)

// 三级标题 - 子区块标题
Text(
  'Recent Chats',
  style: AppTypography.headline3,  // 24px, SemiBold
)

// 卡片标题
Text(
  'Coffee Shop',
  style: AppTypography.headline4,  // 20px, SemiBold
)
```

### 正文和辅助文本

```dart
// 主要正文
Text(
  'Choose a scenario to practice',
  style: AppTypography.body1,  // 16px, Regular
)

// 次要正文
Text(
  'Last updated 2 hours ago',
  style: AppTypography.body2,  // 14px, Regular
)

// 小字说明
Text(
  'Beginner',
  style: AppTypography.caption,  // 12px, Regular
)

// 按钮文字
Text(
  'Start Chat',
  style: AppTypography.button,  // 14px, SemiBold
)
```

## 📏 间距

```dart
// 紧密间距 - 相关元素之间
SizedBox(height: AppSpacing.xs),  // 4px

// 小间距 - 紧凑布局
SizedBox(height: AppSpacing.sm),  // 8px

// 中等间距 - 默认间距（最常用）
Padding(
  padding: EdgeInsets.all(AppSpacing.md),  // 16px
)

// 大间距 - 区块间距
SizedBox(height: AppSpacing.lg),  // 24px

// 超大间距 - 主要区块分隔
SizedBox(height: AppSpacing.xl),  // 32px
```

## 🔲 圆角

```dart
// 按钮、输入框
BorderRadius.circular(AppRadius.sm),  // 8px

// 卡片、容器（最常用）
BorderRadius.circular(AppRadius.md),  // 12px

// 大卡片、模态框
BorderRadius.circular(AppRadius.lg),  // 16px

// 圆形元素、药丸按钮
BorderRadius.circular(AppRadius.full),  // 999px
```

## 🌑 阴影

```dart
// 轻微阴影 - 悬停状态
Container(
  decoration: BoxDecoration(
    boxShadow: AppShadows.xs,
  ),
)

// 小阴影 - 按钮、小卡片
Container(
  decoration: BoxDecoration(
    boxShadow: AppShadows.sm,
  ),
)

// 中等阴影 - 卡片、容器（最常用）
Container(
  decoration: BoxDecoration(
    boxShadow: AppShadows.md,
  ),
)

// 大阴影 - 模态框、下拉菜单
Container(
  decoration: BoxDecoration(
    boxShadow: AppShadows.lg,
  ),
)
```

## 🎴 卡片样式

### 默认卡片

```dart
Container(
  decoration: AppCardTheme.defaultCardLight,  // 白色背景 + 中等阴影 + 12px 圆角
  padding: AppCardTheme.defaultPadding,       // 16px 内边距
  child: YourContent(),
)
```

### 突出卡片

```dart
Container(
  decoration: AppCardTheme.elevatedCardLight,  // 白色背景 + 大阴影 + 16px 圆角
  padding: AppCardTheme.spaciousPadding,       // 24px 内边距
  child: ImportantContent(),
)
```

### 扁平卡片

```dart
Container(
  decoration: AppCardTheme.flatCardLight,  // 白色背景 + 边框 + 无阴影
  padding: AppCardTheme.compactPadding,    // 8px 内边距
  child: ListItem(),
)
```

## 🌓 深色模式

所有颜色都有对应的深色模式变体，使用相同的命名约定，只需将 `Light` 替换为 `Dark`：

```dart
// 浅色模式
AppColors.primaryLight
AppColors.textPrimaryLight
AppCardTheme.defaultCardLight

// 深色模式
AppColors.primaryDark
AppColors.textPrimaryDark
AppCardTheme.defaultCardDark
```

## 🔄 迁移现有代码

### 替换硬编码颜色

**之前：**
```dart
Text(
  'TriTalk',
  style: TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Color(0xFF1A1A1A),
  ),
)
```

**之后：**
```dart
Text(
  'TriTalk',
  style: AppTypography.headline1.copyWith(
    color: AppColors.textPrimaryLight,
  ),
)
```

### 替换硬编码间距

**之前：**
```dart
Padding(
  padding: const EdgeInsets.all(16),
  child: YourWidget(),
)
```

**之后：**
```dart
Padding(
  padding: EdgeInsets.all(AppSpacing.md),
  child: YourWidget(),
)
```

### 替换硬编码圆角

**之前：**
```dart
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12),
  ),
)
```

**之后：**
```dart
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(AppRadius.md),
  ),
)
```

## 🎯 最佳实践

1. **始终使用设计系统中的颜色**，避免硬编码颜色值
2. **使用预定义的字体样式**，保持排版一致性
3. **使用间距常量**，确保布局和谐
4. **使用卡片主题**，快速创建一致的卡片样式
5. **考虑深色模式**，使用相应的深色变体

## 📱 完整示例

```dart
import 'package:flutter/material.dart';
import '../design/app_design_system.dart';

class ExampleCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppCardTheme.defaultCardLight,
      padding: AppCardTheme.defaultPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Coffee Shop',
            style: AppTypography.headline4.copyWith(
              color: AppColors.textPrimaryLight,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Practice ordering coffee',
            style: AppTypography.body2.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
            child: Text(
              'Start Chat',
              style: AppTypography.button,
            ),
          ),
        ],
      ),
    );
  }
}
```

## 🎨 当前应用中的实际颜色映射

| 用途 | 原始颜色 | 设计系统 |
|------|---------|---------|
| 主要蓝色 | `Color(0xFF007AFF)` | `AppColors.primaryLight` |
| 深色文本 | `Color(0xFF1A1A1A)` | `AppColors.textPrimaryLight` |
| Premium 颜色 | `Color(0xFF4F46E5)` | `AppColors.secondaryLight` |
| 选中背景 | `Color(0xFFF2F8FF)` | `AppColors.primaryLightLight` |
| 错误红色 | `Color(0xFFFF3B30)` | `AppColors.errorLight` |
| 警告黄色 | `Color(0xFFFFF3CD)` | `AppColors.warningBackgroundLight` |
| 分析紫色 | `Color(0xFFF3E5F5)` | `AppColors.analysisPurpleLight` |
| 分析蓝色 | `Color(0xFFE3F2FD)` | `AppColors.lightBlue` |
| 分析红色 | `Color(0xFFFFEBEE)` | `AppColors.analysisRedLight` |
