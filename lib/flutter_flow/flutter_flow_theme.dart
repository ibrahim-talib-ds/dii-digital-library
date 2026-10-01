// ignore_for_file: overridden_fields, annotate_overrides

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

const kThemeModeKey = 'theme_mode';

SharedPreferences? _prefs;

// ---------------------------------------------------------------------------
// FlutterFlowTheme
// ---------------------------------------------------------------------------

abstract class FlutterFlowTheme {
  const FlutterFlowTheme();

  static Future initialize() async =>
      _prefs = await SharedPreferences.getInstance();

  static ThemeMode get themeMode {
    final darkMode = _prefs?.getBool(kThemeModeKey);
    return darkMode == null
        ? ThemeMode.system
        : darkMode
            ? ThemeMode.dark
            : ThemeMode.light;
  }

  static void saveThemeMode(ThemeMode mode) => mode == ThemeMode.system
      ? _prefs?.remove(kThemeModeKey)
      : _prefs?.setBool(kThemeModeKey, mode == ThemeMode.dark);

  static FlutterFlowTheme of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const DarkModeTheme()
        : const LightModeTheme();
  }

  Color get primary;
  Color get secondary;
  Color get tertiary;
  Color get alternate;
  Color get primaryText;
  Color get secondaryText;
  Color get primaryBackground;
  Color get secondaryBackground;
  Color get accent1;
  Color get accent2;
  Color get accent3;
  Color get accent4;
  Color get success;
  Color get warning;
  Color get error;
  Color get info;

  Brightness get brightness;

  ColorScheme get colorScheme => ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: Colors.white,
        secondary: secondary,
        onSecondary: Colors.white,
        tertiary: tertiary,
        onTertiary: Colors.white,
        error: error,
        onError: Colors.white,
        surface: secondaryBackground,
        onSurface: primaryText,
      );

  FFDesignTokens get designToken => FFDesignTokens(this);
  Typography get typography => ThemeTypography(this);

  @Deprecated('Use primary instead')
  Color get primaryColor => primary;
  @Deprecated('Use secondary instead')
  Color get secondaryColor => secondary;
  @Deprecated('Use tertiary instead')
  Color get tertiaryColor => tertiary;

  @Deprecated('Use displaySmallFamily instead')
  String get title1Family => displaySmallFamily;
  @Deprecated('Use displaySmall instead')
  TextStyle get title1 => typography.displaySmall;
  @Deprecated('Use headlineMediumFamily instead')
  String get title2Family => typography.headlineMediumFamily;
  @Deprecated('Use headlineMedium instead')
  TextStyle get title2 => typography.headlineMedium;
  @Deprecated('Use headlineSmallFamily instead')
  String get title3Family => typography.headlineSmallFamily;
  @Deprecated('Use headlineSmall instead')
  TextStyle get title3 => typography.headlineSmall;
  @Deprecated('Use titleMediumFamily instead')
  String get subtitle1Family => typography.titleMediumFamily;
  @Deprecated('Use titleMedium instead')
  TextStyle get subtitle1 => typography.titleMedium;
  @Deprecated('Use titleSmallFamily instead')
  String get subtitle2Family => typography.titleSmallFamily;
  @Deprecated('Use titleSmall instead')
  TextStyle get subtitle2 => typography.titleSmall;
  @Deprecated('Use bodyMediumFamily instead')
  String get bodyText1Family => typography.bodyMediumFamily;
  @Deprecated('Use bodyMedium instead')
  TextStyle get bodyText1 => typography.bodyMedium;
  @Deprecated('Use bodySmallFamily instead')
  String get bodyText2Family => typography.bodySmallFamily;
  @Deprecated('Use bodySmall instead')
  TextStyle get bodyText2 => typography.bodySmall;

  String get displayLargeFamily => typography.displayLargeFamily;
  bool get displayLargeIsCustom => typography.displayLargeIsCustom;
  TextStyle get displayLarge => typography.displayLarge;

  String get displayMediumFamily => typography.displayMediumFamily;
  bool get displayMediumIsCustom => typography.displayMediumIsCustom;
  TextStyle get displayMedium => typography.displayMedium;

  String get displaySmallFamily => typography.displaySmallFamily;
  bool get displaySmallIsCustom => typography.displaySmallIsCustom;
  TextStyle get displaySmall => typography.displaySmall;

  String get headlineLargeFamily => typography.headlineLargeFamily;
  bool get headlineLargeIsCustom => typography.headlineLargeIsCustom;
  TextStyle get headlineLarge => typography.headlineLarge;

  String get headlineMediumFamily => typography.headlineMediumFamily;
  bool get headlineMediumIsCustom => typography.headlineMediumIsCustom;
  TextStyle get headlineMedium => typography.headlineMedium;

  String get headlineSmallFamily => typography.headlineSmallFamily;
  bool get headlineSmallIsCustom => typography.headlineSmallIsCustom;
  TextStyle get headlineSmall => typography.headlineSmall;

  String get titleLargeFamily => typography.titleLargeFamily;
  bool get titleLargeIsCustom => typography.titleLargeIsCustom;
  TextStyle get titleLarge => typography.titleLarge;

  String get titleMediumFamily => typography.titleMediumFamily;
  bool get titleMediumIsCustom => typography.titleMediumIsCustom;
  TextStyle get titleMedium => typography.titleMedium;

  String get titleSmallFamily => typography.titleSmallFamily;
  bool get titleSmallIsCustom => typography.titleSmallIsCustom;
  TextStyle get titleSmall => typography.titleSmall;

  String get labelLargeFamily => typography.labelLargeFamily;
  bool get labelLargeIsCustom => typography.labelLargeIsCustom;
  TextStyle get labelLarge => typography.labelLarge;

  String get labelMediumFamily => typography.labelMediumFamily;
  bool get labelMediumIsCustom => typography.labelMediumIsCustom;
  TextStyle get labelMedium => typography.labelMedium;

  String get labelSmallFamily => typography.labelSmallFamily;
  bool get labelSmallIsCustom => typography.labelSmallIsCustom;
  TextStyle get labelSmall => typography.labelSmall;

  String get bodyLargeFamily => typography.bodyLargeFamily;
  bool get bodyLargeIsCustom => typography.bodyLargeIsCustom;
  TextStyle get bodyLarge => typography.bodyLarge;

  String get bodyMediumFamily => typography.bodyMediumFamily;
  bool get bodyMediumIsCustom => typography.bodyMediumIsCustom;
  TextStyle get bodyMedium => typography.bodyMedium;

  String get bodySmallFamily => typography.bodySmallFamily;
  bool get bodySmallIsCustom => typography.bodySmallIsCustom;
  TextStyle get bodySmall => typography.bodySmall;
}

// Light Theme — Custom Palette from Screenshot
// ---------------------------------------------------------------------------

class LightModeTheme extends FlutterFlowTheme {
  const LightModeTheme();

  @override
  Brightness get brightness => Brightness.light;

  @override
  Color get primary => const Color(0xFF060229); // #060229
  @override
  Color get secondary => const Color(0xFF39d2c0); // #39d2c0
  @override
  Color get tertiary => const Color(0xFFffa61c); // #ffa61c
  @override
  Color get alternate => const Color(0xFFe0e3e7); // #e0e3e7
  @override
  Color get primaryText => const Color(0xFF14181b); // #14181b
  @override
  Color get secondaryText => const Color(0xFF57636c); // #57636c
  @override
  Color get primaryBackground => const Color(0xFFe0e7e0); // #e0e7e0
  @override
  Color get secondaryBackground => const Color(0xFFffffff); // #ffffff

  @override
  Color get accent1 => const Color(0x4C4B39EF); // #4c4b39ef
  @override
  Color get accent2 => const Color(0x4D39D2C0); // #4d39d2c0
  @override
  Color get accent3 => const Color(0xFF1e293b); // #1e293b
  @override
  Color get accent4 => const Color(0xCCFFFFFF); // #ccffffff

  @override
  Color get success => const Color(0xFF249689); // #249689
  @override
  Color get warning => const Color(0xFFf2af07); // #f2af07
  @override
  Color get error => const Color(0xFFff5963); // #ff5963
  @override
  Color get info => const Color(0xFFffffff); // #ffffff
}
// ---------------------------------------------------------------------------
// Typography
// ---------------------------------------------------------------------------

abstract class Typography {
  String get displayLargeFamily;
  bool get displayLargeIsCustom;
  TextStyle get displayLarge;

  String get displayMediumFamily;
  bool get displayMediumIsCustom;
  TextStyle get displayMedium;

  String get displaySmallFamily;
  bool get displaySmallIsCustom;
  TextStyle get displaySmall;

  String get headlineLargeFamily;
  bool get headlineLargeIsCustom;
  TextStyle get headlineLarge;

  String get headlineMediumFamily;
  bool get headlineMediumIsCustom;
  TextStyle get headlineMedium;

  String get headlineSmallFamily;
  bool get headlineSmallIsCustom;
  TextStyle get headlineSmall;

  String get titleLargeFamily;
  bool get titleLargeIsCustom;
  TextStyle get titleLarge;

  String get titleMediumFamily;
  bool get titleMediumIsCustom;
  TextStyle get titleMedium;

  String get titleSmallFamily;
  bool get titleSmallIsCustom;
  TextStyle get titleSmall;

  String get labelLargeFamily;
  bool get labelLargeIsCustom;
  TextStyle get labelLarge;

  String get labelMediumFamily;
  bool get labelMediumIsCustom;
  TextStyle get labelMedium;

  String get labelSmallFamily;
  bool get labelSmallIsCustom;
  TextStyle get labelSmall;

  String get bodyLargeFamily;
  bool get bodyLargeIsCustom;
  TextStyle get bodyLarge;

  String get bodyMediumFamily;
  bool get bodyMediumIsCustom;
  TextStyle get bodyMedium;

  String get bodySmallFamily;
  bool get bodySmallIsCustom;
  TextStyle get bodySmall;
}

class ThemeTypography extends Typography {
  ThemeTypography(this.theme);

  final FlutterFlowTheme theme;

  @override
  String get displayLargeFamily => 'Inter Tight';
  @override
  bool get displayLargeIsCustom => false;
  @override
  TextStyle get displayLarge => GoogleFonts.interTight(
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 64.0,
      );

  @override
  String get displayMediumFamily => 'Inter Tight';
  @override
  bool get displayMediumIsCustom => false;
  @override
  TextStyle get displayMedium => GoogleFonts.interTight(
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 44.0,
      );

  @override
  String get displaySmallFamily => 'Inter Tight';
  @override
  bool get displaySmallIsCustom => false;
  @override
  TextStyle get displaySmall => GoogleFonts.interTight(
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 36.0,
      );

  @override
  String get headlineLargeFamily => 'Inter Tight';
  @override
  bool get headlineLargeIsCustom => false;
  @override
  TextStyle get headlineLarge => GoogleFonts.interTight(
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 32.0,
      );

  @override
  String get headlineMediumFamily => 'Inter Tight';
  @override
  bool get headlineMediumIsCustom => false;
  @override
  TextStyle get headlineMedium => GoogleFonts.interTight(
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 28.0,
      );

  @override
  String get headlineSmallFamily => 'Inter Tight';
  @override
  bool get headlineSmallIsCustom => false;
  @override
  TextStyle get headlineSmall => GoogleFonts.interTight(
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 24.0,
      );

  @override
  String get titleLargeFamily => 'Inter Tight';
  @override
  bool get titleLargeIsCustom => false;
  @override
  TextStyle get titleLarge => GoogleFonts.interTight(
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 20.0,
      );

  @override
  String get titleMediumFamily => 'Inter Tight';
  @override
  bool get titleMediumIsCustom => false;
  @override
  TextStyle get titleMedium => GoogleFonts.interTight(
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 18.0,
      );

  @override
  String get titleSmallFamily => 'Inter Tight';
  @override
  bool get titleSmallIsCustom => false;
  @override
  TextStyle get titleSmall => GoogleFonts.interTight(
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 16.0,
      );

  @override
  String get labelLargeFamily => 'Inter';
  @override
  bool get labelLargeIsCustom => false;
  @override
  TextStyle get labelLarge => GoogleFonts.inter(
        color: theme.secondaryText,
        fontWeight: FontWeight.normal,
        fontSize: 16.0,
      );

  @override
  String get labelMediumFamily => 'Inter';
  @override
  bool get labelMediumIsCustom => false;
  @override
  TextStyle get labelMedium => GoogleFonts.inter(
        color: theme.secondaryText,
        fontWeight: FontWeight.normal,
        fontSize: 14.0,
      );

  @override
  String get labelSmallFamily => 'Inter';
  @override
  bool get labelSmallIsCustom => false;
  @override
  TextStyle get labelSmall => GoogleFonts.inter(
        color: theme.secondaryText,
        fontWeight: FontWeight.normal,
        fontSize: 12.0,
      );

  @override
  String get bodyLargeFamily => 'Inter';
  @override
  bool get bodyLargeIsCustom => false;
  @override
  TextStyle get bodyLarge => GoogleFonts.inter(
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 16.0,
      );

  @override
  String get bodyMediumFamily => 'Inter';
  @override
  bool get bodyMediumIsCustom => false;
  @override
  TextStyle get bodyMedium => GoogleFonts.inter(
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 14.0,
      );

  @override
  String get bodySmallFamily => 'Inter';
  @override
  bool get bodySmallIsCustom => false;
  @override
  TextStyle get bodySmall => GoogleFonts.inter(
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 12.0,
      );
}

// Dark Theme — Optimized for Maximum Clarity and Legibility
// ---------------------------------------------------------------------------

class DarkModeTheme extends FlutterFlowTheme {
  const DarkModeTheme();

  @override
  Brightness get brightness => Brightness.dark;

  @override
  Color get primary => const Color(0xFF060606); // High-contrast deep base
  @override
  Color get secondary => const Color(0xFF39D2C0); // Vivid Teal Accent
  @override
  Color get tertiary => const Color(0xFFEE8B60); // Warm Accent
  @override
  Color get alternate => const Color(0xFF334155); // Crisp Border Slate
  
  // High-contrast text values for crystal-clear readability
  @override
  Color get primaryText => const Color(0xFFFFFFFF); // Pure White for Headings
  @override
  Color get secondaryText => const Color(0xFFCBD5E1); // Bright Light Slate for Body Text (Improved Contrast)
  
  @override
  Color get primaryBackground => const Color(0xFF0F172A); // Deep Slate Canvas
  @override
  Color get secondaryBackground => const Color(0xFF1E293B); // Elevated Card Surface

  @override
  Color get accent1 => const Color(0x4C4B39EF); 
  @override
  Color get accent2 => const Color(0x4D39D2C0); 
  @override
  Color get accent3 => const Color(0x4DEE8B60); 
  @override
  Color get accent4 => const Color(0xB2262D34); 

  @override
  Color get success => const Color(0xFF34D399); // Clear Emerald 
  @override
  Color get warning => const Color(0xFFFBBF24); // Bright Warning Amber
  @override
  Color get error => const Color(0xFFF87171); // Vibrant Coral Red
  @override
  Color get info => const Color(0xFF60A5FA); // High-visibility Info Blue
}
// ---------------------------------------------------------------------------
// Design Tokens
// ---------------------------------------------------------------------------

class FFDesignTokens {
  const FFDesignTokens(this.theme);

  final FlutterFlowTheme theme;

  FFSpacing get spacing => const FFSpacing();
  FFRadius get radius => const FFRadius();
  FFShadows get shadow => FFShadows(theme);
}

class FFSpacing {
  const FFSpacing();

  double get xs => 4.0;
  double get sm => 8.0;
  double get md => 16.0;
  double get lg => 24.0;
  double get xl => 32.0;
}

class FFRadius {
  const FFRadius();

  double get sm => 8.0;
  double get md => 16.0;
  double get lg => 24.0;
  double get full => 9999.0;
}

class FFShadows {
  const FFShadows(this.theme);

  final FlutterFlowTheme theme;

  BoxShadow get sm => const BoxShadow(
        blurRadius: 3.0,
        color: Color(0x1A000000),
        offset: Offset(0.0, 1.0),
        spreadRadius: 0.0,
      );

  BoxShadow get md => const BoxShadow(
        blurRadius: 6.0,
        color: Color(0x1A000000),
        offset: Offset(0.0, 3.0),
        spreadRadius: 0.0,
      );

  BoxShadow get lg => const BoxShadow(
        blurRadius: 15.0,
        color: Color(0x1A000000),
        offset: Offset(0.0, 8.0),
        spreadRadius: 0.0,
      );

  BoxShadow get xl => const BoxShadow(
        blurRadius: 25.0,
        color: Color(0x1A000000),
        offset: Offset(0.0, 16.0),
        spreadRadius: 0.0,
      );
}

// ---------------------------------------------------------------------------
// TextStyle Helper
// ---------------------------------------------------------------------------

extension TextStyleHelper on TextStyle {
  TextStyle override({
    TextStyle? font,
    String? fontFamily,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    FontStyle? fontStyle,
    bool useGoogleFonts = false,
    TextDecoration? decoration,
    double? lineHeight,
    List<Shadow>? shadows,
    String? package,
  }) {
    if (useGoogleFonts && fontFamily != null && fontFamily.isNotEmpty) {
      font = GoogleFonts.getFont(
        fontFamily,
        fontWeight: fontWeight ?? this.fontWeight,
        fontStyle: fontStyle ?? this.fontStyle,
      );
    }

    return font != null
        ? font.copyWith(
            color: color ?? this.color,
            fontSize: fontSize ?? this.fontSize,
            letterSpacing: letterSpacing ?? this.letterSpacing,
            fontWeight: fontWeight ?? this.fontWeight,
            fontStyle: fontStyle ?? this.fontStyle,
            decoration: decoration,
            height: lineHeight,
            shadows: shadows,
          )
        : copyWith(
            fontFamily: fontFamily,
            package: package,
            color: color,
            fontSize: fontSize,
            letterSpacing: letterSpacing,
            fontWeight: fontWeight,
            fontStyle: fontStyle,
            decoration: decoration,
            height: lineHeight,
            shadows: shadows,
          );
  }
}