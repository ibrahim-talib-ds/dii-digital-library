import '/auth/firebase_auth/auth_util.dart';
import '/custom/role_utils.dart';
import '/index.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key, required this.currentRoute, this.width = 260});

  final String currentRoute;
  final double width;

  static const Color kBlue   = Color(0xFF0A1E5C);
  static const Color kDeep   = Color(0xFF081444);
  static const Color kYellow = Color(0xFFFFC107);
  static const Color kGreen  = Color(0xFF10B981);
  static const Color kPurple = Color(0xFF7B1FA2);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kDeep,
      child: Container(
        width: width,
        decoration: const BoxDecoration(color: kDeep),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Brand ───
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Row(
                  children: [
                    Container(
                      width: 32, height: 32,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: kYellow,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        'assets/logos/dii_logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.menu_book_rounded,
                          color: kBlue,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    RichText(
                      text: TextSpan(children: [
                        TextSpan(text: 'DII ', style: GoogleFonts.interTight(
                          fontWeight: FontWeight.w900, color: Colors.white, fontSize: 18)),
                        TextSpan(text: 'Library', style: GoogleFonts.interTight(
                          fontWeight: FontWeight.w900, color: kYellow, fontSize: 18)),
                      ]),
                    ),
                  ],
                ),
              ),
              Divider(color: Colors.white.withOpacity(0.08), height: 1),
              const SizedBox(height: 8),

              // ─── Links ───
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  children: [
                    _section('MAIN'),
                    _link(context, 'Home', Icons.home_rounded, HomePageWidget.routeName),
                    _link(context, 'Browse Books', Icons.library_books_rounded, BrowseBooksWidget.routeName),
                    _link(context, 'About', Icons.info_outline_rounded, AboutPageWidget.routeName),

                    if (loggedIn) ...[
                      const SizedBox(height: 10),
                      _section('MY LIBRARY'),
                      _link(context, 'My Books', Icons.book_rounded, MyBooksWidget.routeName),
                      _link(context, 'Saved Books', Icons.bookmark_rounded, SavedBooksWidget.routeName),
                      _link(context, 'History', Icons.history_rounded, HistoryWidget.routeName),
                      _link(context, 'Profile', Icons.person_rounded, ProfilePageWidget.routeName),
                    ],

                    if (isStaffUser()) ...[
                      const SizedBox(height: 10),
                      _section(isAdminUser() ? 'ADMIN TOOLS' : 'LIBRARIAN TOOLS'),
                      if (isAdminUser())
                        _link(context, 'Dashboard', Icons.dashboard_rounded, AdminDashboardWidget.routeName),
                      if (isLibrarianUser())
                        _link(context, 'Dashboard', Icons.dashboard_rounded, LibrarianDashboardWidget.routeName),
                      _link(context, 'Borrow Requests', Icons.assignment_rounded, AdminBorrowRequestsWidget.routeName),
                      _link(context, 'Receive Return', Icons.assignment_turned_in_rounded, LibrarianReturnWidget.routeName),
                      _link(context, 'Students', Icons.people_rounded, LibrarianStudentsWidget.routeName),
                      if (isAdminUser()) ...[
                        _link(context, 'Manage Students', Icons.people_rounded, AdminStudentsWidget.routeName),
                        _link(context, 'Manage Books', Icons.library_add_rounded, AdminBooksWidget.routeName),
                        _link(context, 'Librarians', Icons.badge_rounded, AdminLibrariansWidget.routeName),
                        _link(context, 'Reports', Icons.analytics_rounded, AdminReportsWidget.routeName),
                      ],
                    ],

                    const SizedBox(height: 10),
                    _section('SUPPORT'),
                    _link(context, 'Help Center', Icons.help_outline_rounded, HelpWidget.routeName),
                    _link(context, 'Privacy', Icons.privacy_tip_outlined, PrivacyWidget.routeName),
                    _link(context, 'Contact', Icons.contact_mail_outlined, ContactWidget.routeName),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // ─── Account strip ───
              if (loggedIn) ...[
                Divider(color: Colors.white.withOpacity(0.08), height: 1),
                const _SidebarAccountStrip(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      child: Text(label, style: GoogleFonts.inter(
        fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2,
        color: Colors.white.withOpacity(0.45))),
    );
  }

  Widget _link(BuildContext context, String label, IconData icon, String route) {
    final active = currentRoute == route;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      child: Material(
        color: active ? kYellow.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            if (active) return;
            context.pushNamed(route);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(icon, color: active ? kYellow : Colors.white70, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: active ? kYellow : Colors.white70,
                      fontSize: 14,
                      fontWeight: active ? FontWeight.w800 : FontWeight.w500)),
                ),
                if (active)
                  Container(
                    width: 4, height: 18,
                    decoration: BoxDecoration(color: kYellow, borderRadius: BorderRadius.circular(2)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarAccountStrip extends StatelessWidget {
  const _SidebarAccountStrip();

  static const Color kBlue   = Color(0xFF0A1E5C);
  static const Color kYellow = Color(0xFFFFC107);
  static const Color kGreen  = Color(0xFF10B981);
  static const Color kPurple = Color(0xFF7B1FA2);

  @override
  Widget build(BuildContext context) {
    final uid = currentUserUid;
    if (uid.isEmpty) return const SizedBox.shrink();

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snap) {
        String name = currentUserDisplayName;
        String role = 'student';
        String photoUrl = '';

        if (snap.hasData && snap.data!.exists) {
          final data = snap.data!.data() as Map<String, dynamic>?;
          if (data != null) {
            name = (data['name'] ?? name).toString();
            role = (data['role'] ?? 'student').toString();
            photoUrl = (data['photoUrl'] ?? '').toString();
          }
        }
        if (name.isEmpty) name = 'Student';

        final Color roleBg = role == 'admin' ? kYellow : role == 'librarian' ? kPurple : kGreen;
        final Color roleFg = role == 'admin' ? kBlue : Colors.white;
        final IconData roleIcon = role == 'admin'
            ? Icons.admin_panel_settings_rounded
            : role == 'librarian' ? Icons.badge_rounded : Icons.school_rounded;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.pushNamed(ProfilePageWidget.routeName),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: kYellow, width: 2),
                      color: kYellow,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _renderAvatar(photoUrl, name),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.interTight(
                            color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: roleBg, borderRadius: BorderRadius.circular(4)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(roleIcon, color: roleFg, size: 9),
                              const SizedBox(width: 3),
                              Text(role.toUpperCase(), style: TextStyle(
                                color: roleFg, fontWeight: FontWeight.w900,
                                fontSize: 8.5, letterSpacing: 0.5)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Colors.white54, size: 18),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _renderAvatar(String photoUrl, String name) {
    if (photoUrl.startsWith('data:image')) {
      try {
        final b64 = photoUrl.split(',').last;
        return Image.memory(base64Decode(b64), fit: BoxFit.cover);
      } catch (_) {}
    }
    if (photoUrl.startsWith('http')) {
      return Image.network(photoUrl, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _initial(name));
    }
    return _initial(name);
  }

  Widget _initial(String name) {
    return Container(
      color: kYellow,
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'U',
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: kBlue),
      ),
    );
  }
}
