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
  AppColors._(); // Private constructor to prevent instantiation

  // -------------------- Light Mode Colors --------------------
  
  /// Primary brand color - iOS blue, used for main actions, highlights, and branding
  /// Example: Primary buttons, active states, links, selected items
  static const Color primaryLight = Color(0xFF007AFF);
  
  /// Darker shade of primary - used for hover states and pressed states
  static const Color primaryDarkLight = Color(0xFF0051D5);
  
  /// Lighter shade of primary - used for backgrounds and subtle highlights
  /// Example: Selected item backgrounds, hover states
  static const Color primaryLightLight = Color(0xFFF2F8FF);
  
  /// Secondary accent color - Premium/Pro color (Indigo)
  /// Example: Premium features, paywall, special badges
  static const Color secondaryLight = Color(0xFF4F46E5);
  
  /// Darker shade of secondary
  static const Color secondaryDarkLight = Color(0xFF4338CA);
  
  /// Lighter shade of secondary
  static const Color secondaryLightLight = Color(0xFFEEF2FF);
  
  /// Main background color - used for app background
  static const Color backgroundLight = Color(0xFFFAFAFA);
  
  /// Secondary background - pure white for cards and surfaces
  static const Color backgroundSecondaryLight = Color(0xFFFFFFFF);
  
  /// Surface color - used for cards, sheets, and elevated components
  static const Color surfaceLight = Color(0xFFFFFFFF);
  
  /// Error color - iOS red, used for error states, destructive actions
  static const Color errorLight = Color(0xFFFF3B30);
  
  /// Success color - used for success states and positive feedback
  static const Color successLight = Color(0xFF34C759);
  
  /// Warning color - used for warning states and caution indicators
  /// Example: Feedback highlights, important notices
  static const Color warningLight = Color(0xFFFFCC00);
  
  /// Warning background - light yellow for warning/feedback backgrounds
  static const Color warningBackgroundLight = Color(0xFFFFF3CD);
  
  /// Info color - used for informational messages and neutral highlights
  static const Color infoLight = Color(0xFF007AFF);
  
  /// Primary text color - dark gray/black used throughout the app
  static const Color textPrimaryLight = Color(0xFF1A1A1A);
  
  /// Secondary text color - used for less important text
  static const Color textSecondaryLight = Color(0xFF8E8E93);
  
  /// Disabled text color - used for disabled states
  static const Color textDisabledLight = Color(0xFFC7C7CC);
  
  /// Hint text color - used for placeholder text and hints
  static const Color textHintLight = Color(0xFFAEAEB2);
  
  /// Divider color - used for separators and borders
  static const Color dividerLight = Color(0xFFE5E5EA);
  
  /// Icon color - default icon color (matches primary text)
  static const Color iconLight = Color(0xFF1A1A1A);
  
  /// Icon color secondary - for less prominent icons
  static const Color iconSecondaryLight = Color(0xFF8E8E93);
  
  // -------------------- Analysis Card Colors --------------------
  
  /// Purple background for analysis cards (e.g., grammar explanations)
  static const Color analysisPurpleLight = Color(0xFFF3E5F5);
  
  /// Blue background for analysis cards (e.g., vocabulary)
  static const Color analysisBlueLight = Color(0xFFE3F2FD);
  
  /// Red/Pink background for analysis cards (e.g., corrections)
  static const Color analysisRedLight = Color(0xFFFFEBEE);
  
  /// Yellow gradient start for chat bubbles with feedback
  static const Color feedbackGradientStart = Color(0xFFFFF8E1);
  
  /// Yellow gradient end for chat bubbles with feedback
  static const Color feedbackGradientEnd = Color(0xFFFFECB3);

  // -------------------- Dark Mode Colors --------------------
  
  /// Primary brand color - iOS blue for dark mode
  static const Color primaryDark = Color(0xFF0A84FF);
  
  /// Darker shade of primary - dark mode
  static const Color primaryDarkDark = Color(0xFF007AFF);
  
  /// Lighter shade of primary - dark mode
  static const Color primaryLightDark = Color(0xFF1F2937);
  
  /// Secondary accent color - Premium indigo for dark mode
  static const Color secondaryDark = Color(0xFF6366F1);
  
  /// Darker shade of secondary - dark mode
  static const Color secondaryDarkDark = Color(0xFF4F46E5);
  
  /// Lighter shade of secondary - dark mode
  static const Color secondaryLightDark = Color(0xFF312E81);
  
  /// Main background color - dark mode
  static const Color backgroundDark = Color(0xFF000000);
  
  /// Secondary background - dark mode
  static const Color backgroundSecondaryDark = Color(0xFF1C1C1E);
  
  /// Surface color - dark mode
  static const Color surfaceDark = Color(0xFF1C1C1E);
  
  /// Error color - iOS red for dark mode
  static const Color errorDark = Color(0xFFFF453A);
  
  /// Success color - iOS green for dark mode
  static const Color successDark = Color(0xFF32D74B);
  
  /// Warning color - dark mode variant
  static const Color warningDark = Color(0xFFFFD60A);
  
  /// Warning background - dark mode
  static const Color warningBackgroundDark = Color(0xFF3A3A1C);
  
  /// Info color - dark mode variant
  static const Color infoDark = Color(0xFF0A84FF);
  
  /// Primary text color - dark mode
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  
  /// Secondary text color - dark mode
  static const Color textSecondaryDark = Color(0xFF98989D);
  
  /// Disabled text color - dark mode
  static const Color textDisabledDark = Color(0xFF48484A);
  
  /// Hint text color - dark mode
  static const Color textHintDark = Color(0xFF636366);
  
  /// Divider color - dark mode
  static const Color dividerDark = Color(0xFF38383A);
  
  /// Icon color - dark mode
  static const Color iconDark = Color(0xFFFFFFFF);
  
  /// Icon color secondary - dark mode
  static const Color iconSecondaryDark = Color(0xFF98989D);
  
  // -------------------- Analysis Card Colors (Dark Mode) --------------------
  
  /// Purple background for analysis cards - dark mode
  static const Color analysisPurpleDark = Color(0xFF2D1B3D);
  
  /// Blue background for analysis cards - dark mode
  static const Color analysisBlueDark = Color(0xFF1A2942);
  
  /// Red/Pink background for analysis cards - dark mode
  static const Color analysisRedDark = Color(0xFF3D1F1F);
  
  /// Yellow gradient start for chat bubbles with feedback - dark mode
  static const Color feedbackGradientStartDark = Color(0xFF3A3A1C);
  
  /// Yellow gradient end for chat bubbles with feedback - dark mode
  static const Color feedbackGradientEndDark = Color(0xFF4A4A2C);
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
    color: AppColors.surfaceLight,
    borderRadius: BorderRadius.circular(AppRadius.md),
    boxShadow: AppShadows.md,
  );
  
  /// Default card decoration - Dark mode
  /// Features: Dark surface background, medium shadow, medium border radius
  static BoxDecoration defaultCardDark = BoxDecoration(
    color: AppColors.surfaceDark,
    borderRadius: BorderRadius.circular(AppRadius.md),
    boxShadow: AppShadows.md,
  );
  
  /// Elevated card decoration - Light mode
  /// Features: White background, large shadow, large border radius
  /// Use for: Important cards, featured content
  static BoxDecoration elevatedCardLight = BoxDecoration(
    color: AppColors.surfaceLight,
    borderRadius: BorderRadius.circular(AppRadius.lg),
    boxShadow: AppShadows.lg,
  );
  
  /// Elevated card decoration - Dark mode
  static BoxDecoration elevatedCardDark = BoxDecoration(
    color: AppColors.surfaceDark,
    borderRadius: BorderRadius.circular(AppRadius.lg),
    boxShadow: AppShadows.lg,
  );
  
  /// Flat card decoration - Light mode
  /// Features: White background, no shadow, medium border radius, subtle border
  /// Use for: Minimal cards, list items
  static BoxDecoration flatCardLight = BoxDecoration(
    color: AppColors.surfaceLight,
    borderRadius: BorderRadius.circular(AppRadius.md),
    border: Border.all(
      color: AppColors.dividerLight,
      width: 1,
    ),
  );
  
  /// Flat card decoration - Dark mode
  static BoxDecoration flatCardDark = BoxDecoration(
    color: AppColors.surfaceDark,
    borderRadius: BorderRadius.circular(AppRadius.md),
    border: Border.all(
      color: AppColors.dividerDark,
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
      primary: AppColors.primaryLight,
      primaryContainer: AppColors.primaryLightLight,
      secondary: AppColors.secondaryLight,
      secondaryContainer: AppColors.secondaryLightLight,
      surface: AppColors.surfaceLight,
      error: AppColors.errorLight,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.textPrimaryLight,
      onError: Colors.white,
    ),
    
    // Scaffold
    scaffoldBackgroundColor: AppColors.backgroundLight,
    
    // App bar
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surfaceLight,
      foregroundColor: AppColors.textPrimaryLight,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTypography.headline4.copyWith(
        color: AppColors.textPrimaryLight,
      ),
      iconTheme: IconThemeData(
        color: AppColors.iconLight,
        size: 24,
      ),
    ),
    
    // Card
    cardTheme: CardThemeData(
      color: AppColors.surfaceLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      margin: EdgeInsets.all(AppSpacing.sm),
    ),
    
    // Elevated button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.white,
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
        foregroundColor: AppColors.primaryLight,
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
        foregroundColor: AppColors.primaryLight,
        side: BorderSide(color: AppColors.primaryLight, width: 1.5),
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
      fillColor: AppColors.surfaceLight,
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(color: AppColors.dividerLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(color: AppColors.dividerLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(color: AppColors.primaryLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(color: AppColors.errorLight),
      ),
      labelStyle: AppTypography.body2.copyWith(
        color: AppColors.textSecondaryLight,
      ),
      hintStyle: AppTypography.body2.copyWith(
        color: AppColors.textHintLight,
      ),
    ),
    
    // Icon
    iconTheme: IconThemeData(
      color: AppColors.iconLight,
      size: 24,
    ),
    
    // Divider
    dividerTheme: DividerThemeData(
      color: AppColors.dividerLight,
      thickness: 1,
      space: AppSpacing.md,
    ),
    
    // Text theme
    textTheme: TextTheme(
      displayLarge: AppTypography.headline1.copyWith(color: AppColors.textPrimaryLight),
      displayMedium: AppTypography.headline2.copyWith(color: AppColors.textPrimaryLight),
      displaySmall: AppTypography.headline3.copyWith(color: AppColors.textPrimaryLight),
      headlineMedium: AppTypography.headline4.copyWith(color: AppColors.textPrimaryLight),
      titleLarge: AppTypography.subtitle1.copyWith(color: AppColors.textPrimaryLight),
      titleMedium: AppTypography.subtitle2.copyWith(color: AppColors.textPrimaryLight),
      bodyLarge: AppTypography.body1.copyWith(color: AppColors.textPrimaryLight),
      bodyMedium: AppTypography.body2.copyWith(color: AppColors.textPrimaryLight),
      bodySmall: AppTypography.caption.copyWith(color: AppColors.textSecondaryLight),
      labelLarge: AppTypography.button.copyWith(color: AppColors.textPrimaryLight),
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
      primary: AppColors.primaryDark,
      primaryContainer: AppColors.primaryDarkDark,
      secondary: AppColors.secondaryDark,
      secondaryContainer: AppColors.secondaryDarkDark,
      surface: AppColors.surfaceDark,
      error: AppColors.errorDark,
      onPrimary: AppColors.textPrimaryDark,
      onSecondary: AppColors.textPrimaryDark,
      onSurface: AppColors.textPrimaryDark,
      onError: AppColors.textPrimaryDark,
    ),
    
    // Scaffold
    scaffoldBackgroundColor: AppColors.backgroundDark,
    
    // App bar
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surfaceDark,
      foregroundColor: AppColors.textPrimaryDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTypography.headline4.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      iconTheme: IconThemeData(
        color: AppColors.iconDark,
        size: 24,
      ),
    ),
    
    // Card
    cardTheme: CardThemeData(
      color: AppColors.surfaceDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      margin: EdgeInsets.all(AppSpacing.sm),
    ),
    
    // Elevated button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.textPrimaryDark,
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
        foregroundColor: AppColors.primaryDark,
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
        foregroundColor: AppColors.primaryDark,
        side: BorderSide(color: AppColors.primaryDark, width: 1.5),
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
      fillColor: AppColors.surfaceDark,
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(color: AppColors.dividerDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(color: AppColors.dividerDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(color: AppColors.primaryDark, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(color: AppColors.errorDark),
      ),
      labelStyle: AppTypography.body2.copyWith(
        color: AppColors.textSecondaryDark,
      ),
      hintStyle: AppTypography.body2.copyWith(
        color: AppColors.textHintDark,
      ),
    ),
    
    // Icon
    iconTheme: IconThemeData(
      color: AppColors.iconDark,
      size: 24,
    ),
    
    // Divider
    dividerTheme: DividerThemeData(
      color: AppColors.dividerDark,
      thickness: 1,
      space: AppSpacing.md,
    ),
    
    // Text theme
    textTheme: TextTheme(
      displayLarge: AppTypography.headline1.copyWith(color: AppColors.textPrimaryDark),
      displayMedium: AppTypography.headline2.copyWith(color: AppColors.textPrimaryDark),
      displaySmall: AppTypography.headline3.copyWith(color: AppColors.textPrimaryDark),
      headlineMedium: AppTypography.headline4.copyWith(color: AppColors.textPrimaryDark),
      titleLarge: AppTypography.subtitle1.copyWith(color: AppColors.textPrimaryDark),
      titleMedium: AppTypography.subtitle2.copyWith(color: AppColors.textPrimaryDark),
      bodyLarge: AppTypography.body1.copyWith(color: AppColors.textPrimaryDark),
      bodyMedium: AppTypography.body2.copyWith(color: AppColors.textPrimaryDark),
      bodySmall: AppTypography.caption.copyWith(color: AppColors.textSecondaryDark),
      labelLarge: AppTypography.button.copyWith(color: AppColors.textPrimaryDark),
    ),
    
    // Font family
    fontFamily: AppTypography.fontFamily,
  );
}
