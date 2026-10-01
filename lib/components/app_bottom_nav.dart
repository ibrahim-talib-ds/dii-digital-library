import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Mobile-only bottom navigation.
/// Automatically hidden on screens wider than 900px (laptop/desktop).
///
/// Use:
///   Scaffold(
///     bottomNavigationBar: const AppBottomNav(currentRoute: 'HomePage'),
///     ...
///   )
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.currentRoute});

  final String currentRoute;

  static const Color kBlue = Color(0xFF0A1E5C);
  static const double kMobileBreakpoint = 1024;

  @override
  Widget build(BuildContext context) {
    // Hide on laptop/desktop
    final width = MediaQuery.of(context).size.width;
    if (width >= kMobileBreakpoint) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            color: Color(0x11000000),
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _item(context, Icons.home_rounded, 'Home',
                HomePageWidget.routeName),
            _item(context, Icons.library_books_rounded, 'Books',
                BrowseBooksWidget.routeName),
            if (loggedIn)
              _item(context, Icons.book_rounded, 'My Books',
                  MyBooksWidget.routeName),
            if (loggedIn)
              _item(context, Icons.person_rounded, 'Profile',
                  ProfilePageWidget.routeName)
            else
              _item(context, Icons.login_rounded, 'Sign In',
                  LoginPageWidget.routeName),
          ],
        ),
      ),
    );
  }

  Widget _item(BuildContext context, IconData icon, String label, String route) {
    final active = currentRoute == route;
    return Expanded(
      child: InkWell(
        onTap: () {
          if (active) return;
          context.pushNamed(route);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  color: active
                      ? kBlue
                      : FlutterFlowTheme.of(context).secondaryText,
                  size: 22),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                  color: active
                      ? kBlue
                      : FlutterFlowTheme.of(context).secondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
