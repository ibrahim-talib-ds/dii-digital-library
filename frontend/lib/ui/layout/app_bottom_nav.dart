import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/colors.dart';
import '../../core/constants.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.currentRoute});

  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    final items = <_Tab>[
      _Tab('Home',    Icons.home_rounded,          DiiRoutes.home),
      _Tab('Browse',  Icons.library_books_rounded, DiiRoutes.browse),
      _Tab('Loans',   Icons.book_rounded,          DiiRoutes.myBooks),
      _Tab('Profile', Icons.person_rounded,        DiiRoutes.profile),
    ];

    final index = items.indexWhere((t) => t.route == currentRoute);
    final safeIndex = index < 0 ? 0 : index;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: DiiColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: BottomNavigationBar(
          currentIndex: safeIndex,
          onTap: (i) => context.go(items[i].route),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: DiiColors.blue,
          unselectedItemColor: DiiColors.textSecondary,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
          elevation: 0,
          items: [
            for (final t in items)
              BottomNavigationBarItem(
                icon: Icon(t.icon),
                label: t.label,
              ),
          ],
        ),
      ),
    );
  }
}

class _Tab {
  final String label;
  final IconData icon;
  final String route;
  _Tab(this.label, this.icon, this.route);
}
