import 'package:flutter/material.dart';

import '../../core/breakpoints.dart';
import 'app_sidebar.dart';
import 'app_bottom_nav.dart';
import '../components/ai_floating_button.dart';

/// Wraps every page that appears after login.
/// Handles the top-level navigation chrome:
///   desktop >= 1024 → sidebar
///   tablet          → compact sidebar
///   phone  < 600    → bottom nav bar
class ResponsiveShell extends StatelessWidget {
  const ResponsiveShell({
    super.key,
    required this.currentRoute,
    required this.child,
  });

  final String currentRoute;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDesktop = DiiBreakpoints.isDesktop(context);
    final isTablet  = DiiBreakpoints.isTablet(context);
    final isPhone   = DiiBreakpoints.isPhone(context);

    // Hide the AI button on the AI page itself
    final showAi = currentRoute != '/ai';

    if (isPhone) {
      return Scaffold(
        body: Stack(
          children: [
            child,
            if (showAi) const AiFloatingButton(),
          ],
        ),
        bottomNavigationBar: AppBottomNav(currentRoute: currentRoute),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          AppSidebar(
            currentRoute: currentRoute,
            compact: isTablet && !isDesktop,
          ),
          Expanded(
            child: Stack(
              children: [
                child,
                if (showAi) const AiFloatingButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
