import 'package:flutter/material.dart';

/// DII Library brand palette.
/// STRICT 3-COLOR SYSTEM — white / dark blue / yellow.
/// Semantic shades (success, danger) come from blue/yellow/red family only.
class DiiColors {
  DiiColors._();

  // ─── The 3 brand colors ───
  static const Color blue   = Color(0xFF0A1E5C);   // dark blue — primary
  static const Color deep   = Color(0xFF061436);   // darker blue — used for gradients
  static const Color yellow = Color(0xFFFFC107);   // konsyello — accent
  static const Color white  = Colors.white;

  // ─── Surfaces ───
  static const Color background = Color(0xFFF7F9FC);
  static const Color surface    = Colors.white;
  static const Color border     = Color(0xFFE5E9F0);

  // ─── Text ───
  static const Color textPrimary   = Color(0xFF0A1E5C);
  static const Color textSecondary = Color(0xFF5A6478);
  static const Color textDisabled  = Color(0xFFA0A8B8);

  // ─── Rare semantic accents (only for OUT / OVERDUE — nowhere else) ───
  static const Color danger = Color(0xFFB3261E);   // muted red, used ONLY for out-of-stock + overdue
  static const Color red    = danger;              // legacy alias — same color

  // ─── Legacy aliases (map to 3-color system) ───
  static const Color green  = blue;      // was green — now blue
  static const Color purple = blue;      // was purple — now blue
  static const Color cyan   = blue;      // was cyan — now blue
  static const Color blue2  = blue;

  // ─── Category color mapping — all categories now use blue or yellow ───
  /// Primary categories use blue. Secondary (accent) use yellow.
  static const Map<String, bool> categoryIsAccent = {
    'is_computer_science':         false,  // blue
    'is_artificial_intelligence':  false,  // blue
    'is_biotechnology':            true,   // yellow
    'is_business_data_science':    true,   // yellow
    'is_business_innovation':      false,  // blue
    'is_mathematics':              true,   // yellow
  };

  static Color categoryColor(String? slug) {
    if (slug == null) return blue;
    return (categoryIsAccent[slug] ?? false) ? yellow : blue;
  }

  static Color categoryTextColor(String? slug) {
    // text/icon color on top of categoryColor
    return (categoryIsAccent[slug] ?? false) ? blue : white;
  }
}
