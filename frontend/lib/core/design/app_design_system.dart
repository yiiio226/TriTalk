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
  // Neutral Color Scale (Light Mode)
  // =============================
  // Unified neutral colors based on pure black (#000000) with percentage-based opacity.
  // This provides a consistent, predictable scale for all neutral UI elements.
  
  static const Color ln50 = Color(0x08000000);   // 3% black - Subtle backgrounds, very light overlays
  static const Color ln100 = Color(0x0D000000);  // 5% black - Shadows, very light grey backgrounds
  static const Color ln200 = Color(0x1F000000);  // 12% black - Borders, dividers, light grey backgrounds
  static const Color ln300 = Color(0x61000000);  // 38% black - Disabled states, placeholder text
  static const Color ln400 = Color(0x73000000);  // 45% black - Medium grey for subtle emphasis
  static const Color ln500 = Color(0xB8000000);  // 72% black - Secondary text, icons
  static const Color ln700 = Color(0xC7000000);  // 78% black - Dark secondary text
  static const Color ln900 = Color(0xE3000000);  // 89% black - Primary text, strong emphasis



  // =============================
  // Semantic Color Scales (Light Mode)
  // =============================
  // Comprehensive color scales for UI components, states, and semantic meanings.
  // Each color has 6 shades from very light (50) to saturated (500).
  
  // Blue Scale (Light Mode) - For info, links, and primary actions
  static const Color lb50 = Color(0xFFEFF6FF);   // Very light blue background
  static const Color lb100 = Color(0xFFDBEAFE);  // Light blue background
  static const Color lb200 = Color(0xFFBFDBFE);  // Soft blue for borders
  static const Color lb300 = Color(0xFF93C5FD);  // Medium blue for hover states
  static const Color lb400 = Color(0xFF60A5FA);  // Bright blue for accents
  static const Color lb500 = Color(0xFF3B82F6);  // Saturated blue for primary info
  
  // Green Scale (Light Mode) - For success, positive states, and growth
  static const Color lg50 = Color(0xFFECFDF5);   // Very light green background
  static const Color lg100 = Color(0xFFD1FAE5);  // Light green background
  static const Color lg200 = Color(0xFFA7F3D0);  // Soft green for borders
  static const Color lg300 = Color(0xFF6EE7B7);  // Medium green for hover states
  static const Color lg400 = Color(0xFF34D399);  // Bright green for accents
  static const Color lg500 = Color(0xFF10B981);  // Saturated green for success
  
  // Red Scale (Light Mode) - For errors, warnings, and destructive actions
  static const Color lr50 = Color(0xFFFEF2F2);   // Very light red background
  static const Color lr100 = Color(0xFFFEE2E2);  // Light red background
  static const Color lr200 = Color(0xFFFECACA);  // Soft red for borders
  static const Color lr300 = Color(0xFFFCA5A5);  // Medium red for hover states
  static const Color lr400 = Color(0xFFF87171);  // Bright red for accents
  static const Color lr500 = Color(0xFFEF4444);  // Saturated red for errors
  
  // Yellow Scale (Light Mode) - For warnings, highlights, and attention
  static const Color ly50 = Color(0xFFFEFCE8);   // Very light yellow background
  static const Color ly100 = Color(0xFFFEF9C3);  // Light yellow background
  static const Color ly200 = Color(0xFFFEF08A);  // Soft yellow for borders
  static const Color ly300 = Color(0xFFFDE047);  // Medium yellow for hover states
  static const Color ly400 = Color(0xFFFACC15);  // Bright yellow for accents
  static const Color ly500 = Color(0xFFEAB308);  // Saturated yellow for warnings
  
  // Orange Scale (Light Mode) - For alerts, energy, and secondary warnings
  static const Color lo50 = Color(0xFFFFF7ED);   // Very light orange background
  static const Color lo100 = Color(0xFFFFEDD5);  // Light orange background
  static const Color lo200 = Color(0xFFFED7AA);  // Soft orange for borders
  static const Color lo300 = Color(0xFFFDBA74);  // Medium orange for hover states
  static const Color lo400 = Color(0xFFFB923C);  // Bright orange for accents
  static const Color lo500 = Color(0xFFF97316);  // Saturated orange for alerts
  
  // Purple Scale (Light Mode) - For premium, creative, and special features
  static const Color lp50 = Color(0xFFFAF5FF);   // Very light purple background
  static const Color lp100 = Color(0xFFF3E8FF);  // Light purple background
  static const Color lp200 = Color(0xFFE9D5FF);  // Soft purple for borders
  static const Color lp300 = Color(0xFFD8B4FE);  // Medium purple for hover states
  static const Color lp400 = Color(0xFFC084FC);  // Bright purple for accents
  static const Color lp500 = Color(0xFFA855F7);  // Saturated purple for premium

  // =============================
  // Brand Colors
  // =============================
  static const Color primary = Color(0xFF1D1D1D); // Main Brand Color (Buttons, Emphasis)
  static const Color secondary = Color(0xFF2BC3C9); // Secondary Brand Color (Auxiliary Emphasis)

  // =============================
  // Light Theme Base Colors
  // =============================
  static const Color lightBackground = Color(0xFFF8FAFC); // Page Background
  static const Color lightSurface = Color(0xFFFFFFFF); // Card/Container Background
  static const Color lightDivider = ln200; // Divider/Border



  // =============================
  // Light Theme State Colors
  // =============================
  static const Color lightError = lr500; // Error
  static const Color lightSuccess = lg500; // Success
  static const Color lightWarning = ly500; // Warning
  static const Color lightInfo = lb500; // Primary blue for info
  static const Color lightBlue = lb500; // Info blue


  // =============================
  // Semantic Color Aliases (Backward Compatibility)
  // =============================
  // These maintain existing color names while using the new ln scale.

  // Light Theme Text Colors
  static const Color lightTextPrimary = ln900; // Primary Text
  static const Color lightTextSecondary = ln500; // Secondary Text
  static const Color lightTextDisabled = ln300; // Placeholder/Disabled

  // Shadows / Overlays
  static const Color lightShadow = ln100;






  // =============================
  // Dark Theme Colors
  // =============================

  // =============================
  // Neutral Color Scale (Dark Mode)
  // =============================
  // Unified neutral colors based on pure white (#FFFFFF) with percentage-based opacity.
  // This provides a consistent, predictable scale for all neutral UI elements in dark mode.
  
  static const Color dn50 = Color(0x08FFFFFF);   // 3% white - Subtle backgrounds, very light overlays
  static const Color dn100 = Color(0x0DFFFFFF);  // 5% white - Shadows, very light grey backgrounds
  static const Color dn200 = Color(0x1FFFFFFF);  // 12% white - Borders, dividers, light grey backgrounds
  static const Color dn300 = Color(0x61FFFFFF);  // 38% white - Disabled states, placeholder text
  static const Color dn400 = Color(0x73FFFFFF);  // 45% white - Medium grey for subtle emphasis
  static const Color dn500 = Color(0xB8FFFFFF);  // 72% white - Secondary text, icons
  static const Color dn700 = Color(0xC7FFFFFF);  // 78% white - Dark secondary text
  static const Color dn900 = Color(0xE3FFFFFF);  // 89% white - Primary text, strong emphasis



  // =============================
  // Semantic Color Scales (Dark Mode)
  // =============================
  // Dark mode variants optimized for dark backgrounds.
  // Colors are adjusted for proper contrast and visual comfort in dark environments.
  
  // Blue Scale (Dark Mode)
  static const Color db50 = Color(0xFF172554);   // Very dark blue background
  static const Color db100 = Color(0xFF1E3A8A);  // Dark blue background
  static const Color db200 = Color(0xFF1E40AF);  // Medium dark blue
  static const Color db300 = Color(0xFF2563EB);  // Medium blue
  static const Color db400 = Color(0xFF3B82F6);  // Bright blue
  static const Color db500 = Color(0xFF60A5FA);  // Light blue for dark mode
  
  // Green Scale (Dark Mode)
  static const Color dg50 = Color(0xFF064E3B);   // Very dark green background
  static const Color dg100 = Color(0xFF065F46);  // Dark green background
  static const Color dg200 = Color(0xFF047857);  // Medium dark green
  static const Color dg300 = Color(0xFF059669);  // Medium green
  static const Color dg400 = Color(0xFF10B981);  // Bright green
  static const Color dg500 = Color(0xFF34D399);  // Light green for dark mode
  
  // Red Scale (Dark Mode)
  static const Color dr50 = Color(0xFF7F1D1D);   // Very dark red background
  static const Color dr100 = Color(0xFF991B1B);  // Dark red background
  static const Color dr200 = Color(0xFFB91C1C);  // Medium dark red
  static const Color dr300 = Color(0xFFDC2626);  // Medium red
  static const Color dr400 = Color(0xFFEF4444);  // Bright red
  static const Color dr500 = Color(0xFFF87171);  // Light red for dark mode
  
  // Yellow Scale (Dark Mode)
  static const Color dy50 = Color(0xFF713F12);   // Very dark yellow background
  static const Color dy100 = Color(0xFF854D0E);  // Dark yellow background
  static const Color dy200 = Color(0xFFA16207);  // Medium dark yellow
  static const Color dy300 = Color(0xFFCA8A04);  // Medium yellow
  static const Color dy400 = Color(0xFFEAB308);  // Bright yellow
  static const Color dy500 = Color(0xFFFACC15);  // Light yellow for dark mode
  
  // Orange Scale (Dark Mode)
  static const Color do50 = Color(0xFF7C2D12);   // Very dark orange background
  static const Color do100 = Color(0xFF9A3412);  // Dark orange background
  static const Color do200 = Color(0xFFC2410C);  // Medium dark orange
  static const Color do300 = Color(0xFFEA580C);  // Medium orange
  static const Color do400 = Color(0xFFF97316);  // Bright orange
  static const Color do500 = Color(0xFFFB923C);  // Light orange for dark mode
  
  // Purple Scale (Dark Mode)
  static const Color dp50 = Color(0xFF581C87);   // Very dark purple background
  static const Color dp100 = Color(0xFF6B21A8);  // Dark purple background
  static const Color dp200 = Color(0xFF7E22CE);  // Medium dark purple
  static const Color dp300 = Color(0xFF9333EA);  // Medium purple
  static const Color dp400 = Color(0xFFA855F7);  // Bright purple
  static const Color dp500 = Color(0xFFC084FC);  // Light purple for dark mode

  
  // Dark Theme Base Colors
  static const Color darkBackground = Color(0xFF0B1220);
  static const Color darkSurface = Color(0xFF111827);
  static const Color darkDivider = ln200; // Divider/Border

  // Dark Theme State Colors
  static const Color darkError = dr500; // Error
  static const Color darkSuccess = dg500; // Success
  static const Color darkWarning = dy500; // Warning
  static const Color darkWarningBackground = dy50; // Warning Background
  static const Color darkInfo = db500; // Info blue
  static const Color darkBlue = db500; // Info blue


  

  // Dark Theme Text Colors
  static const Color darkTextPrimary = dn900; // Primary Text
  static const Color darkTextSecondary = dn500; // Secondary Text
  static const Color darkTextDisabled = dn300; // Placeholder/Disabled

  // Dark Theme Shadows
  static const Color darkShadow = dn100;




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
