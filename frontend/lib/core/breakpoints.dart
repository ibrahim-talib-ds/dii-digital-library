import 'package:flutter/widgets.dart';

/// Responsive breakpoints used across the app.
/// Rules:
///   phone   < 600   → 2-column grids, bottom nav, compact app bar
///   tablet  < 1024  → 3-column grids, compact sidebar
///   desktop >= 1024 → 6-column grids, full sidebar, no bottom nav
class DiiBreakpoints {
  DiiBreakpoints._();

  static const double phone  = 600;
  static const double tablet = 1024;

  static bool isPhone(BuildContext c)   => MediaQuery.sizeOf(c).width < phone;
  static bool isTablet(BuildContext c) {
    final w = MediaQuery.sizeOf(c).width;
    return w >= phone && w < tablet;
  }
  static bool isDesktop(BuildContext c) => MediaQuery.sizeOf(c).width >= tablet;

  /// Default horizontal page padding based on viewport.
  static double pad(BuildContext c) {
    if (isPhone(c))   return 16;
    if (isTablet(c))  return 24;
    return 32;
  }

  /// Grid column count per breakpoint.
  static int gridCols(BuildContext c, {int phone = 2, int tablet = 4, int desktop = 6}) {
    if (isPhone(c))   return phone;
    if (isTablet(c))  return tablet;
    return desktop;
  }
}
