import 'package:flutter/material.dart';

/// TriTalk Design System
/// 
/// This file contains all design tokens and theme definitions for the TriTalk app.
/// It provides a centralized location for colors, typography, spacing, and other
/// design primitives to ensure consistency across the application.
/// 
/// Usage:
/// - Access colors via `AppColors.primary`, `AppColors.background`, etc.
/// - Access typography via `AppTypography.headline1`, `AppTypography.body`, etc.
/// - Access spacing via `AppSpacing.xs`, `AppSpacing.md`, etc.
/// - Access themes via `AppTheme.lightTheme` or `AppTheme.darkTheme`

// ============================================================================
// COLOR PALETTE
// ============================================================================

/// Application color palette
/// 
/// Defines all colors used throughout the app for both light and dark modes.
/// Colors are organized by purpose (primary, secondary, background, etc.)


class AppColors {
  AppColors._(); // Private constructor

  // ===========================================================================
  // Neutral Color Scale (Light Mode) - 保持了透明度逻辑，但调整为更暖的灰度以匹配柔和氛围
  // ===========================================================================
  // TriTalk 的文字并非冷冰冰的纯黑，而是带有一点点暖意的深灰。
  // 我们沿用透明度方案，这能让文字更好地融合在彩色卡片背景上。
  static const Color ln50 = Color(0x08000000); // 3% - 极淡的分割线
  static const Color ln100 = Color(0x0D000000); // 5% - 投影
  static const Color ln200 = Color(0x1F000000); // 12% - 边框
  static const Color ln300 = Color(0x61000000); // 38% - 失效状态
  static const Color ln400 = Color(0x73000000); // 45% - 辅助图标
  static const Color ln500 = Color(0xB8000000); // 72% - 次要文字 (Subtitle)
  static const Color ln700 = Color(0xC7000000); // 78% - 深色次要文字
  static const Color ln900 = Color(0xE6000000); // 90% - 主要标题 (TriTalk Header)

  // ===========================================================================
  // Semantic Color Scales (Light Mode) - 核心修改区域
  // ===========================================================================
  // 这里的 xx50 和 xx100 色值直接取样于你的 App 卡片背景。

  // 1. Blue Scale (Light Mode) - 对应 "The Shirt Dilemma" 中的蓝色衬衫元素
  // 即使卡片是米色，蓝色依然是重要的信息色。
  static const Color lb50 = Color(0xFFF0F7FF); // 极淡蓝背景
  static const Color lb100 = Color(0xFFE0F0FF); // 淡蓝
  static const Color lb200 = Color(0xFFBAE0FF); // 边框蓝
  static const Color lb300 = Color(0xFF7CC0FF); // 悬停
  static const Color lb400 = Color(0xFF369EFF); // 强调
  static const Color lb500 = Color(0xFF007AFF); // 标准交互蓝 (iOS风格)
  static const Color lb800 = Color(0xFF1E40AF); // 深邃蓝

  // 2. Green Scale (Light Mode) - 对应右下角 "Fireworks" 卡片的薄荷绿背景
  static const Color lg50 = Color(0xFFF2FBF6); // TriTalk 卡片背景: 薄荷白
  static const Color lg100 = Color(0xFFE0F5EA); // 稍深薄荷
  static const Color lg200 = Color(0xFFB8E8D0);
  static const Color lg300 = Color(0xFF85D6B2);
  static const Color lg400 = Color(0xFF4DBF91);
  static const Color lg500 = Color(0xFF10B981); // 成功状态绿色
  static const Color lg800 = Color(0xFF065F46); // 深翠绿

  // 3. Red Scale (Light Mode) - 对应 "Bohol Island Bound" 卡片的淡粉色背景
  // 我们将 Red Scale 调整为 Rose/Pink 倾向，更符合 App 的气质。
  static const Color lr50 = Color(0xFFFFF0F5); // TriTalk 卡片背景: 樱花粉
  static const Color lr100 = Color(0xFFFFE0EB); // 淡粉
  static const Color lr200 = Color(0xFFFFC2D6);
  static const Color lr300 = Color(0xFFFF94B8);
  static const Color lr400 = Color(0xFFFF5C94);
  static const Color lr500 = Color(0xFFFF3366); // 错误/警告红 (偏洋红，更年轻)
  static const Color lr800 = Color(0xFF9F1239); // 深玫瑰红

  // 4. Yellow Scale (Light Mode) - 对应 "Check-in at Immigration" 卡片的奶油黄背景
  static const Color ly50 = Color(0xFFFFFCF0); // TriTalk 卡片背景: 象牙奶油色
  static const Color ly100 = Color(0xFFFFF7D6); // 淡黄
  static const Color ly200 = Color(0xFFFFECAD);
  static const Color ly300 = Color(0xFFFFDE7A);
  static const Color ly400 = Color(0xFFFFCF47);
  static const Color ly500 = Color(0xFFFFB800); // 警告黄
  static const Color ly800 = Color(0xFF854D0E); // 古铜金

  // 5. Orange Scale (Light Mode) - 对应头像及部分暖色高光
  static const Color lo50 = Color(0xFFFFF5EB);
  static const Color lo100 = Color(0xFFFFE6CC);
  static const Color lo200 = Color(0xFFFFC999);
  static const Color lo300 = Color(0xFFFFAC66);
  static const Color lo400 = Color(0xFFFF8F33);
  static const Color lo500 = Color(0xFFFF7200); // 活力橙
  static const Color lo800 = Color(0xFF9A3412); // 焦糖橙

  // 6. Purple Scale (Light Mode) - 对应 "Gym Buddy" 和 "Taxi" 卡片的淡紫背景
  static const Color lp50 = Color(0xFFF7F5FF); // TriTalk 卡片背景: 极淡薰衣草
  static const Color lp100 = Color(0xFFEDE8FF); // 淡紫
  static const Color lp200 = Color(0xFFD6CCFF);
  static const Color lp300 = Color(0xFFB5A3FF);
  static const Color lp400 = Color(0xFF947AFF);
  static const Color lp500 = Color(0xFF7A5CFF); // 优质/会员紫
  static const Color lp800 = Color(0xFF5B21B6); // 深紫罗兰

  // ===========================================================================
  // Brand Colors (核心品牌色)
  // ===========================================================================
  // 基于截图中的 FAB (浮动按钮) 和 "TriTalk" 标题
  static const Color primary = Color(0xFF1D1D1F); // Apple 风格的深黑，非纯黑，更有质感
  static const Color secondary = Color(0xFFFF7200); // 提取自头像的橙色，作为点缀

  // ===========================================================================
  // Light Theme Base Colors
  // ===========================================================================
  static const Color lightBackground = Color(0xFFF8FAFC); // Page Background
  static const Color lightSurface = Color(0xFFFFFFFF); // 卡片表面
  static const Color lightDivider = ln100;

  // ===========================================================================
  // Light Theme State Colors
  // ===========================================================================
  static const Color lightError = lr800;
  static const Color lightSuccess = lg800;
  static const Color lightWarning = ly800;
  static const Color lightInfo = ln700;
  static const Color lightBlue = lb800;

  // ===========================================================================
  // Semantic Color Aliases (Backward Compatibility)
  // ===========================================================================
  static const Color lightTextPrimary = ln900;
  static const Color lightTextSecondary = ln500;
  static const Color lightTextDisabled = ln300;
  static const Color lightShadow = ln100;

  // Skeleton Colors
  static const Color lightSkeletonBase = Color(0xFFE2E8F0);
  static const Color lightSkeletonHighlight = Color(0xFFFFFFFF);

  // ===========================================================================
  // Dark Theme Colors (自动生成的深色模式适配)
  // ===========================================================================
  // 既然 TriTalk 是高亮风格，深色模式需要反转为"深邃背景+高亮卡片"或"暗色柔彩"
  
  // Neutral Color Scale (Dark Mode) - 基于纯白
  static const Color dn50 = Color(0x08FFFFFF);
  static const Color dn100 = Color(0x0DFFFFFF);
  static const Color dn200 = Color(0x1FFFFFFF);
  static const Color dn300 = Color(0x61FFFFFF);
  static const Color dn400 = Color(0x73FFFFFF);
  static const Color dn500 = Color(0xB8FFFFFF);
  static const Color dn700 = Color(0xC7FFFFFF);
  static const Color dn900 = Color(0xE3FFFFFF); 

  // Dark Mode Variants (调整了饱和度以适应深色背景)
  // Blue
  static const Color db50 = Color(0xFF0D1C2E);
  static const Color db100 = Color(0xFF162C46);
  static const Color db500 = Color(0xFF3A91FF); // 提亮

  // Green
  static const Color dg50 = Color(0xFF0E291E);
  static const Color dg100 = Color(0xFF153D2D);
  static const Color dg500 = Color(0xFF34D399);

  // Red
  static const Color dr50 = Color(0xFF2E1218);
  static const Color dr100 = Color(0xFF451A24);
  static const Color dr500 = Color(0xFFFF6B90); // 提亮

  // Yellow
  static const Color dy50 = Color(0xFF2E260D);
  static const Color dy100 = Color(0xFF453913);
  static const Color dy500 = Color(0xFFFFD166);

  // Orange
  static const Color do50 = Color(0xFF2E1A0D);
  static const Color do100 = Color(0xFF452713);
  static const Color do500 = Color(0xFFFF9F5C);

  // Purple
  static const Color dp50 = Color(0xFF1E1A2E);
  static const Color dp100 = Color(0xFF2D2645);
  static const Color dp500 = Color(0xFFA68CFF);

  // Dark Theme Base Colors
  static const Color darkBackground = Color(0xFF000000); // 纯黑 OLED 友好
  static const Color darkSurface = Color(0xFF1C1C1E); // 深灰卡片
  static const Color darkDivider = dn200;

  // Dark Theme State Colors
  static const Color darkError = dr500;
  static const Color darkSuccess = dg500;
  static const Color darkWarning = dy500;
  static const Color darkInfo = db500;
  static const Color darkBlue = db500;

  // Dark Theme Text Colors
  static const Color darkTextPrimary = dn900;
  static const Color darkTextSecondary = dn500;
  static const Color darkTextDisabled = dn300;
  static const Color darkShadow = dn100;

  // Skeleton Colors
  static const Color darkSkeletonBase = dn200;
  static const Color darkSkeletonHighlight = dn100;
}


// ============================================================================
// TYPOGRAPHY
// ============================================================================

/// Application typography system
/// 
/// Defines text styles for different use cases throughout the app.
/// All text styles use the Inter font family for a modern, clean look.
/// 
/// Usage: `Text('Hello', style: AppTypography.headline1)`
class AppTypography {
  AppTypography._(); // Private constructor

  /// Font family used throughout the app
  static const String fontFamily = 'Inter';
  
  /// Fallback font families
  static const List<String> fontFamilyFallback = ['SF Pro', 'Roboto', 'sans-serif'];

  // -------------------- Headlines --------------------
  
  /// Headline 1 - Largest headline, used for main page titles
  /// Size: 32px, Weight: Bold
  static const TextStyle headline1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
    letterSpacing: -0.5,
  );
  
  /// Headline 2 - Secondary headline, used for section titles
  /// Size: 28px, Weight: Bold
  static const TextStyle headline2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.25,
    letterSpacing: -0.4,
  );
  
  /// Headline 3 - Tertiary headline, used for subsection titles
  /// Size: 24px, Weight: SemiBold
  static const TextStyle headline3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.3,
  );
  
  /// Headline 4 - Small headline, used for card titles
  /// Size: 20px, Weight: SemiBold
  static const TextStyle headline4 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: -0.2,
  );

  // -------------------- Subtitles --------------------
  
  /// Subtitle 1 - Primary subtitle, used for prominent secondary text
  /// Size: 18px, Weight: Medium
  static const TextStyle subtitle1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0,
  );
  
  /// Subtitle 2 - Secondary subtitle, used for less prominent secondary text
  /// Size: 16px, Weight: Medium
  static const TextStyle subtitle2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: 0.1,
  );

  // -------------------- Body Text --------------------
  
  /// Body 1 - Primary body text, used for main content
  /// Size: 16px, Weight: Regular
  static const TextStyle body1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.15,
  );
  
  /// Body 2 - Secondary body text, used for less prominent content
  /// Size: 14px, Weight: Regular
  static const TextStyle body2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.25,
  );

  // -------------------- Captions & Labels --------------------
  
  /// Caption - Small text, used for labels and metadata
  /// Size: 12px, Weight: Regular
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.4,
  );
  
  /// Overline - Uppercase small text, used for categories and tags
  /// Size: 10px, Weight: Medium, Uppercase
  static const TextStyle overline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.6,
    letterSpacing: 1.5,
  );
  
  /// Button text - Used for button labels
  /// Size: 14px, Weight: SemiBold
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.5,
  );
}

// ============================================================================
// SPACING
// ============================================================================

/// Application spacing system
/// 
/// Defines consistent spacing values used for padding, margins, and gaps.
/// Uses a 4px base unit for a harmonious spacing scale.
/// 
/// Usage: `padding: EdgeInsets.all(AppSpacing.md)`
class AppSpacing {
  AppSpacing._(); // Private constructor

  /// Extra small spacing - 4px
  /// Use for: Tight spacing between related elements
  static const double xs = 4.0;
  
  /// Small spacing - 8px
  /// Use for: Compact layouts, icon padding
  static const double sm = 8.0;
  
  /// Medium spacing - 16px (base unit)
  /// Use for: Default padding, standard gaps
  static const double md = 16.0;
  
  /// Large spacing - 24px
  /// Use for: Section spacing, card padding
  static const double lg = 24.0;
  
  /// Extra large spacing - 32px
  /// Use for: Major section breaks, page padding
  static const double xl = 32.0;
  
  /// Extra extra large spacing - 48px
  /// Use for: Large gaps, hero sections
  static const double xxl = 48.0;
  
  /// Extra extra extra large spacing - 64px
  /// Use for: Maximum spacing, major layout divisions
  static const double xxxl = 64.0;
}

// ============================================================================
// BORDER RADIUS
// ============================================================================

/// Application border radius tokens
/// 
/// Defines consistent border radius values for rounded corners.
/// 
/// Usage: `borderRadius: BorderRadius.circular(AppRadius.md)`
class AppRadius {
  AppRadius._(); // Private constructor

  /// No radius - 0px
  /// Use for: Sharp corners, rectangular elements
  static const double none = 0.0;
  
  /// Extra small radius - 4px
  /// Use for: Subtle rounding, small chips
  static const double xs = 4.0;
  
  /// Small radius - 8px
  /// Use for: Buttons, input fields
  static const double sm = 8.0;
  
  /// Medium radius - 12px
  /// Use for: Cards, containers
  static const double md = 12.0;
  
  /// Large radius - 16px
  /// Use for: Large cards, modals
  static const double lg = 16.0;
  
  /// Extra large radius - 24px
  /// Use for: Prominent cards, bottom sheets
  static const double xl = 24.0;
  
  /// Full radius - 999px
  /// Use for: Circular elements, pills
  static const double full = 999.0;
}

// ============================================================================
// SHADOWS & ELEVATIONS
// ============================================================================

/// Application shadow and elevation system
/// 
/// Defines consistent shadow styles for different elevation levels.
/// Shadows help establish visual hierarchy and depth.
/// 
/// Usage: `boxShadow: AppShadows.sm`
class AppShadows {
  AppShadows._(); // Private constructor

  /// No shadow - Elevation 0
  /// Use for: Flat elements, no depth needed
  static const List<BoxShadow> none = [];
  
  /// Extra small shadow - Elevation 1
  /// Use for: Subtle depth, hover states
  static const List<BoxShadow> xs = [
    BoxShadow(
      color: Color(0x0A000000), // 4% opacity
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];
  
  /// Small shadow - Elevation 2
  /// Use for: Buttons, chips, small cards
  /// Updated to be softer and cleaner
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x0A000000), // 4% opacity (was 6%)
      offset: Offset(0, 4),     // was (0, 2)
      blurRadius: 12,           // was 4
      spreadRadius: 0,
    ),
  ];
  
  /// Medium shadow - Elevation 4
  /// Use for: Cards, containers, raised elements
  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x14000000), // 8% opacity
      offset: Offset(0, 4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];
  
  /// Large shadow - Elevation 8
  /// Use for: Modals, dropdowns, floating elements
  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x1A000000), // 10% opacity
      offset: Offset(0, 8),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];
  
  /// Extra large shadow - Elevation 16
  /// Use for: Dialogs, overlays, prominent floating elements
  static const List<BoxShadow> xl = [
    BoxShadow(
      color: Color(0x1F000000), // 12% opacity
      offset: Offset(0, 12),
      blurRadius: 24,
      spreadRadius: 0,
    ),
  ];
  
  /// Extra extra large shadow - Elevation 24
  /// Use for: Maximum elevation, important overlays
  static const List<BoxShadow> xxl = [
    BoxShadow(
      color: Color(0x29000000), // 16% opacity
      offset: Offset(0, 16),
      blurRadius: 32,
      spreadRadius: 0,
    ),
  ];
}

// ============================================================================
// CARD THEME
// ============================================================================

/// Application card styling
/// 
/// Defines reusable card styles with consistent appearance.
/// Cards are used throughout the app for content containers.
/// 
/// Usage: 
/// ```dart
/// Container(
///   decoration: AppCardTheme.defaultCard,
///   child: YourContent(),
/// )
/// ```
class AppCardTheme {
  AppCardTheme._(); // Private constructor

  /// Default card decoration - Light mode
  /// Features: White background, medium shadow, medium border radius
  static BoxDecoration defaultCardLight = BoxDecoration(
    color: AppColors.lightSurface,
    borderRadius: BorderRadius.circular(AppRadius.md),
    boxShadow: AppShadows.md,
  );
  
  /// Default card decoration - Dark mode
  /// Features: Dark surface background, medium shadow, medium border radius
  static BoxDecoration defaultCardDark = BoxDecoration(
    color: AppColors.darkSurface,
    borderRadius: BorderRadius.circular(AppRadius.md),
    boxShadow: AppShadows.md,
  );
  
  /// Elevated card decoration - Light mode
  /// Features: White background, large shadow, large border radius
  /// Use for: Important cards, featured content
  static BoxDecoration elevatedCardLight = BoxDecoration(
    color: AppColors.lightSurface,
    borderRadius: BorderRadius.circular(AppRadius.lg),
    boxShadow: AppShadows.lg,
  );
  
  /// Elevated card decoration - Dark mode
  static BoxDecoration elevatedCardDark = BoxDecoration(
    color: AppColors.darkSurface,
    borderRadius: BorderRadius.circular(AppRadius.lg),
    boxShadow: AppShadows.lg,
  );
  
  /// Flat card decoration - Light mode
  /// Features: White background, no shadow, medium border radius, subtle border
  /// Use for: Minimal cards, list items
  static BoxDecoration flatCardLight = BoxDecoration(
    color: AppColors.lightSurface,
    borderRadius: BorderRadius.circular(AppRadius.md),
    border: Border.all(
      color: AppColors.lightDivider,
      width: 1,
    ),
  );
  
  /// Flat card decoration - Dark mode
  static BoxDecoration flatCardDark = BoxDecoration(
    color: AppColors.darkSurface,
    borderRadius: BorderRadius.circular(AppRadius.md),
    border: Border.all(
      color: AppColors.darkDivider,
      width: 1,
    ),
  );
  
  /// Default card padding
  /// Use for: Standard card content padding
  static const EdgeInsets defaultPadding = EdgeInsets.all(AppSpacing.md);
  
  /// Compact card padding
  /// Use for: Dense cards, list items
  static const EdgeInsets compactPadding = EdgeInsets.all(AppSpacing.sm);
  
  /// Spacious card padding
  /// Use for: Large cards, featured content
  static const EdgeInsets spaciousPadding = EdgeInsets.all(AppSpacing.lg);
}

// ============================================================================
// THEME DATA
// ============================================================================

/// Application theme configurations
/// 
/// Provides complete ThemeData for light and dark modes.
/// Apply these themes to MaterialApp to style the entire app.
/// 
/// Usage:
/// ```dart
/// MaterialApp(
///   theme: AppTheme.lightTheme,
///   darkTheme: AppTheme.darkTheme,
///   themeMode: ThemeMode.system,
/// )
/// ```
class AppTheme {
  AppTheme._(); // Private constructor

  // -------------------- Light Theme --------------------
  
  static ThemeData lightTheme = ThemeData(
    // Brightness
    brightness: Brightness.light,
    
    // Color scheme
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      primaryContainer: AppColors.secondary,
      secondary: AppColors.secondary,
      secondaryContainer: AppColors.secondary,
      surface: AppColors.lightSurface,
      error: AppColors.lightError,
      onPrimary: AppColors.lightTextPrimary, // Dark text on light brand color
      onSecondary: AppColors.lightTextPrimary,
      onSurface: AppColors.lightTextPrimary,
      onError: Colors.white,
    ),
    
    // Scaffold
    scaffoldBackgroundColor: AppColors.lightBackground,
    
    // App bar
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.lightSurface,
      foregroundColor: AppColors.lightTextPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTypography.headline4.copyWith(
        color: AppColors.lightTextPrimary,
      ),
      iconTheme: IconThemeData(
        color: AppColors.lightTextPrimary,
        size: 24,
      ),
    ),
    
    // Card
    cardTheme: CardThemeData(
      color: AppColors.lightSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      margin: EdgeInsets.all(AppSpacing.sm),
    ),
    
    // Elevated button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.lightTextPrimary, // Text color on primary
        elevation: 2,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        textStyle: AppTypography.button,
      ),
    ),
    
    // Text button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        textStyle: AppTypography.button,
      ),
    ),
    
    // Outlined button
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: BorderSide(color: AppColors.primary, width: 1.5),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        textStyle: AppTypography.button,
      ),
    ),
    
    // Input decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightSurface,
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(color: AppColors.lightDivider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(color: AppColors.lightDivider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(color: AppColors.lightError),
      ),
      labelStyle: AppTypography.body2.copyWith(
        color: AppColors.lightTextSecondary,
      ),
      hintStyle: AppTypography.body2.copyWith(
        color: AppColors.lightTextDisabled,
      ),
    ),
    
    // Icon
    iconTheme: IconThemeData(
      color: AppColors.lightTextPrimary,
      size: 24,
    ),
    
    // Divider
    dividerTheme: DividerThemeData(
      color: AppColors.lightDivider,
      thickness: 1,
      space: AppSpacing.md,
    ),
    
    // Text theme
    textTheme: TextTheme(
      displayLarge: AppTypography.headline1.copyWith(color: AppColors.lightTextPrimary),
      displayMedium: AppTypography.headline2.copyWith(color: AppColors.lightTextPrimary),
      displaySmall: AppTypography.headline3.copyWith(color: AppColors.lightTextPrimary),
      headlineMedium: AppTypography.headline4.copyWith(color: AppColors.lightTextPrimary),
      titleLarge: AppTypography.subtitle1.copyWith(color: AppColors.lightTextPrimary),
      titleMedium: AppTypography.subtitle2.copyWith(color: AppColors.lightTextPrimary),
      bodyLarge: AppTypography.body1.copyWith(color: AppColors.lightTextPrimary),
      bodyMedium: AppTypography.body2.copyWith(color: AppColors.lightTextPrimary),
      bodySmall: AppTypography.caption.copyWith(color: AppColors.lightTextSecondary),
      labelLarge: AppTypography.button.copyWith(color: AppColors.lightTextPrimary),
    ),
    
    // Font family
    fontFamily: AppTypography.fontFamily,
  );

  // -------------------- Dark Theme --------------------
  
  static ThemeData darkTheme = ThemeData(
    // Brightness
    brightness: Brightness.dark,
    
    // Color scheme
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      primaryContainer: AppColors.primary,
      secondary: AppColors.secondary,
      secondaryContainer: AppColors.secondary,
      surface: AppColors.darkSurface,
      error: AppColors.darkError,
      onPrimary: AppColors.darkBackground, // Dark background on light primary
      onSecondary: AppColors.darkBackground,
      onSurface: AppColors.darkTextPrimary,
      onError: AppColors.darkTextPrimary,
    ),
    
    // Scaffold
    scaffoldBackgroundColor: AppColors.darkBackground,
    
    // App bar
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      foregroundColor: AppColors.darkTextPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTypography.headline4.copyWith(
        color: AppColors.darkTextPrimary,
      ),
      iconTheme: IconThemeData(
        color: AppColors.darkTextPrimary,
        size: 24,
      ),
    ),
    
    // Card
    cardTheme: CardThemeData(
      color: AppColors.darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      margin: EdgeInsets.all(AppSpacing.sm),
    ),
    
    // Elevated button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 2,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        textStyle: AppTypography.button,
      ),
    ),
    
    // Text button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        textStyle: AppTypography.button,
      ),
    ),
    
    // Outlined button
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: BorderSide(color: AppColors.primary, width: 1.5),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        textStyle: AppTypography.button,
      ),
    ),
    
    // Input decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface,
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(color: AppColors.darkDivider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(color: AppColors.darkDivider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(color: AppColors.darkError),
      ),
      labelStyle: AppTypography.body2.copyWith(
        color: AppColors.darkTextSecondary,
      ),
      hintStyle: AppTypography.body2.copyWith(
        color: AppColors.darkTextDisabled,
      ),
    ),
    
    // Icon
    iconTheme: IconThemeData(
      color: AppColors.darkTextPrimary,
      size: 24,
    ),
    
    // Divider
    dividerTheme: DividerThemeData(
      color: AppColors.darkDivider,
      thickness: 1,
      space: AppSpacing.md,
    ),
    
    // Text theme
    textTheme: TextTheme(
      displayLarge: AppTypography.headline1.copyWith(color: AppColors.darkTextPrimary),
      displayMedium: AppTypography.headline2.copyWith(color: AppColors.darkTextPrimary),
      displaySmall: AppTypography.headline3.copyWith(color: AppColors.darkTextPrimary),
      headlineMedium: AppTypography.headline4.copyWith(color: AppColors.darkTextPrimary),
      titleLarge: AppTypography.subtitle1.copyWith(color: AppColors.darkTextPrimary),
      titleMedium: AppTypography.subtitle2.copyWith(color: AppColors.darkTextPrimary),
      bodyLarge: AppTypography.body1.copyWith(color: AppColors.darkTextPrimary),
      bodyMedium: AppTypography.body2.copyWith(color: AppColors.darkTextPrimary),
      bodySmall: AppTypography.caption.copyWith(color: AppColors.darkTextSecondary),
      labelLarge: AppTypography.button.copyWith(color: AppColors.darkTextPrimary),
    ),
    
    // Font family
    fontFamily: AppTypography.fontFamily,
  );
}
