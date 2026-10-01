import '/components/app_sidebar.dart';
import 'package:flutter/material.dart';

/// Wraps any page body and automatically adds the AppSidebar on desktop.
///
/// On phone/tablet, child is shown alone.
/// On desktop (>= 1024px), sidebar + child side-by-side.
class ResponsiveShell extends StatelessWidget {
  const ResponsiveShell({
    super.key,
    required this.currentRoute,
    required this.child,
  });

  final String currentRoute;
  final Widget child;

  static const double kDesktopBreakpoint = 1024;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= kDesktopBreakpoint;

    if (!isDesktop) return child;

    return Row(
      children: [
        AppSidebar(currentRoute: currentRoute),
        Expanded(child: child),
      ],
    );
  }
}
