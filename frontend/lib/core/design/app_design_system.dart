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

  // =============================
  // Color Palette (Semantic)
  // =============================
  // Named by usage for direct reference in components.
  static const Color primary = Color(0xFFB5D0CC); // Main Brand Color (Buttons, Emphasis)
  static const Color secondary = Color(0xFFE8F7F5); // Secondary Brand Color (Auxiliary Emphasis)

  // Light Theme Base Colors
  static const Color lightBackground = Color(0xFFF8FAFC); // Page Background
  static const Color lightSurface = Color(0xFFFFFFFF); // Card/Container Background
  static const Color lightDivider = Color(0xFFE2E8F0); // Divider/Border

  // Light Theme State Colors
  static const Color lightError = Color(0xFFEF4444); // Error
  static const Color lightSuccess = Color(0xFF10B981); // Success
  static const Color lightWarning = Color(0xFFF59E0B); // Warning
  static const Color lightWarningBackground = Color(0xFFFEF3C7); // Warning Background

  // Light Theme Text Colors
  static const Color lightTextPrimary = Color(0xFF0F172A); // Primary Text
  static const Color lightTextSecondary = Color(0xFF475569); // Secondary Text
  static const Color lightTextDisabled = Color(0xFF9CA3AF); // Placeholder/Disabled

  // Dark Theme Base Colors
  static const Color darkBackground = Color(0xFF0B1220);
  static const Color darkSurface = Color(0xFF111827); //
  static const Color darkDivider = Color(0xFF273042); // Divider/Border

  // Dark Theme State Colors
  static const Color darkError = Color(0xFFF87171);
  static const Color darkSuccess = Color(0xFF34D399);
  static const Color darkWarning = Color(0xFFF59E0B);
  static const Color darkWarningBackground = Color(0xFF451A03);

  // Dark Theme Text Colors
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);
  static const Color darkTextDisabled = Color(0xFF9CA3AF); // Placeholder/Disabled

  // Shadows / Overlays
  static const Color lightShadow = Color(0x14000000);
  static const Color darkShadow = Color(0x66000000);

  // -------------------- Analysis Card Colors (Preserved) --------------------
  
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
