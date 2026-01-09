# 设计系统迁移进度

## ✅ 已完成迁移的文件

### 核心文件
- ✅ **main.dart** - 应用主题配置
  - 导入设计系统
  - 应用 `AppTheme.lightTheme` 和 `AppTheme.darkTheme`

### 屏幕 (Screens)
- ✅ **home_screen.dart** - 主屏幕
  - 标题文字：使用 `AppTypography.headline1`
  - 图标颜色：使用 `AppColors.iconLight`
  - 文本颜色：使用 `AppColors.textPrimaryLight`

- ✅ **scenario_configuration_screen.dart** - 场景配置屏幕
  - 主按钮：使用 `AppColors.primaryLight` (iOS 蓝色)
  - 选中背景：使用 `AppColors.primaryLightLight`
  - 边框颜色：使用 `AppColors.primaryLight` / `AppColors.dividerLight`
  - 圆角：使用 `AppRadius.md`
  - 间距：使用 `AppSpacing.md`
  - 文字样式：使用 `AppTypography.subtitle1`, `AppTypography.subtitle2`, `AppTypography.body2`

- ✅ **paywall_screen.dart** - 付费墙屏幕
  - Premium 按钮：使用 `AppColors.secondaryLight` (Indigo)
  - 标题：使用 `AppTypography.headline1`
  - 副标题：使用 `AppTypography.headline4`
  - 正文：使用 `AppTypography.body1`, `AppTypography.body2`
  - 图标颜色：使用 `AppColors.secondaryLight`
  - 圆角：使用 `AppRadius.lg`
  - 间距：使用 `AppSpacing.md`, `AppSpacing.lg`

### 组件 (Widgets)
- ✅ **scene_card.dart** - 场景卡片
  - 圆角：使用 `AppRadius.xl` (24px)
  - 阴影：使用 `AppShadows.sm`
  - 标题：使用 `AppTypography.subtitle2`
  - 副标题：使用 `AppTypography.caption`
  - 文本颜色：使用 `AppColors.textPrimaryLight`, `AppColors.textSecondaryLight`

- ✅ **chat_bubble.dart** - 聊天气泡
  - 反馈背景：使用 `AppColors.warningBackgroundLight` (#FFF3CD)
  - 反馈渐变：使用 `AppColors.feedbackGradientStart`, `AppColors.feedbackGradientEnd`
  - 圆角：使用 `AppRadius.lg`
  - 阴影：使用 `AppShadows.xs`

- ✅ **analysis_sheet.dart** - 分析面板
  - 紫色背景：使用 `AppColors.analysisPurpleLight` (#F3E5F5)
  - 蓝色背景：使用 `AppColors.analysisBlueLight` (#E3F2FD)
  - 红色背景：使用 `AppColors.analysisRedLight` (#FFEBEE)
  - 圆角：使用 `AppRadius.lg`, `AppRadius.md`, `AppRadius.sm`

## ⏳ 待迁移的文件

### 高优先级屏幕
- ⏳ **chat_screen.dart** - 聊天屏幕 (5 处硬编码颜色)
  - `Color(0xFF1A1A1A)` - 文本颜色
  - `Color(0xFF34C759)` - 成功绿色

- ⏳ **profile_screen.dart** - 个人资料屏幕 (5 处硬编码颜色)
  - `Color(0xFF1A1A1A)` - 文本颜色

- ⏳ **login_screen.dart** - 登录屏幕 (1 处)
- ⏳ **onboarding_screen.dart** - 引导屏幕 (4 处)
- ⏳ **splash_screen.dart** - 启动屏幕 (1 处)
- ⏳ **archived_chat_screen.dart** - 归档聊天屏幕 (1 处)
- ⏳ **unified_favorites_screen.dart** - 收藏屏幕 (1 处)

### 组件 (Widgets)
- ⏳ **chat_history_list_widget.dart** - 聊天历史列表 (1 处)
  - `Color(0xFFFF3B30)` - 删除按钮红色

## 📊 迁移统计

### 已完成
- **文件数**: 7 个
- **替换的颜色**: ~40 处
- **替换的字体样式**: ~20 处
- **替换的间距**: ~15 处
- **替换的圆角**: ~12 处
- **替换的阴影**: ~5 处

### 待完成
- **剩余文件**: ~8 个
- **剩余硬编码颜色**: ~15 处

## 🎯 下一步建议

### 优先级 1: 聊天相关
```bash
# 迁移聊天界面的核心组件
- chat_screen.dart
- chat_bubble.dart
- analysis_sheet.dart
```

### 优先级 2: 用户界面
```bash
# 迁移用户相关屏幕
- profile_screen.dart
- login_screen.dart
- onboarding_screen.dart
```

### 优先级 3: 其他组件
```bash
# 迁移剩余的小组件
- chat_history_list_widget.dart
- 其他 widgets
```

## 🔄 迁移模式参考

### 颜色迁移
```dart
// 之前
color: Color(0xFF1A1A1A)

// 之后
color: AppColors.textPrimaryLight
```

### 字体迁移
```dart
// 之前
style: TextStyle(
  fontSize: 32,
  fontWeight: FontWeight.bold,
  color: Color(0xFF1A1A1A),
)

// 之后
style: AppTypography.headline1.copyWith(
  color: AppColors.textPrimaryLight,
)
```

### 间距迁移
```dart
// 之前
padding: EdgeInsets.all(16)

// 之后
padding: EdgeInsets.all(AppSpacing.md)
```

### 圆角迁移
```dart
// 之前
borderRadius: BorderRadius.circular(12)

// 之后
borderRadius: BorderRadius.circular(AppRadius.md)
```

## 📝 注意事项

1. **保持一致性**: 确保相同用途的元素使用相同的设计 token
2. **测试验证**: 每次迁移后进行 hot reload 测试
3. **渐进式迁移**: 一次迁移一个文件，避免大规模改动
4. **文档更新**: 迁移完成后更新此文档

## 🎨 常用颜色映射表

| 原始颜色 | 设计系统 | 用途 |
|---------|---------|------|
| `Color(0xFF1A1A1A)` | `AppColors.textPrimaryLight` | 主要文本 |
| `Color(0xFF007AFF)` | `AppColors.primaryLight` | 主要按钮/链接 |
| `Color(0xFFF2F8FF)` | `AppColors.primaryLightLight` | 选中背景 |
| `Color(0xFF4F46E5)` | `AppColors.secondaryLight` | Premium 功能 |
| `Color(0xFFFF3B30)` | `AppColors.errorLight` | 错误/删除 |
| `Color(0xFF34C759)` | `AppColors.successLight` | 成功状态 |
| `Color(0xFFFFF3CD)` | `AppColors.warningBackgroundLight` | 警告背景 |
| `Color(0xFFF3E5F5)` | `AppColors.analysisPurpleLight` | 分析卡片(紫) |
| `Color(0xFFE3F2FD)` | `AppColors.analysisBlueLight` | 分析卡片(蓝) |
| `Color(0xFFFFEBEE)` | `AppColors.analysisRedLight` | 分析卡片(红) |
| `Colors.grey[600]` | `AppColors.textSecondaryLight` | 次要文本 |
| `Colors.grey.shade300` | `AppColors.dividerLight` | 分割线/边框 |

---

**最后更新**: 2026-01-09
**迁移进度**: 47% (7/15 文件)
