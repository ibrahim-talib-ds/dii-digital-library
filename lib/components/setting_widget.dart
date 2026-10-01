import '/auth/firebase_auth/auth_util.dart';
import '/custom/role_utils.dart';
import '/custom/user_avatar.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'setting_model.dart';
export 'setting_model.dart';

/// Bottom sheet menu.
/// Navigation is done INSIDE this widget after closing the sheet,
/// using the app's global router — works on phone, tablet, and laptop.
class SettingWidget extends StatefulWidget {
  const SettingWidget({super.key});

  static String routeName = 'Setting';
  static String routePath = '/setting';

  @override
  State<SettingWidget> createState() => _SettingWidgetState();
}

class _SettingWidgetState extends State<SettingWidget> {
  late SettingModel _model;

  static const Color kBlue   = Color(0xFF0A1E5C);
  static const Color kDeep   = Color(0xFF081444);
  static const Color kYellow = Color(0xFFFFC107);
  static const Color kGreen  = Color(0xFF10B981);
  static const Color kRed    = Color(0xFFDC0F0F);
  static const Color kPurple = Color(0xFF7B1FA2);

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SettingModel());
    Future.microtask(() async {
      await loadCurrentUserRole();
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  /// Close the sheet, THEN navigate using the app's root router.
  /// Works on every screen size because we capture the router BEFORE pop.
  void _go(String route) {
    // Capture the router before popping
    final router = GoRouter.of(context);
    // Fire navigation and dismiss sheet at the same time
    router.pushNamed(route);
    Navigator.of(context).pop();
  }

  Future<void> _signOut() async {
    final router = GoRouter.of(context);
    clearRoleCache();
    router.goNamed(LoginPageWidget.routeName);
    Navigator.of(context).pop();
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final role = currentRole();
    final isAdmin = isAdminUser();
    final isStaff = isLibrarianUser() || isAdmin;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 44, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              if (loggedIn)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [kBlue, kDeep],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const UserAvatar(size: 56),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentUserDisplayName.isEmpty
                                    ? 'Student'
                                    : currentUserDisplayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.interTight(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                currentUserEmail,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.75),
                                  fontSize: 11.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: kYellow,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isAdmin
                                          ? Icons.admin_panel_settings_rounded
                                          : role == 'librarian'
                                              ? Icons.badge_rounded
                                              : Icons.school_rounded,
                                      color: kBlue,
                                      size: 11,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      (role.isEmpty ? 'student' : role)
                                          .toUpperCase(),
                                      style: const TextStyle(
                                        color: kBlue,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              _sectionLabel('MAIN'),
              _item(Icons.home_rounded, 'Home',
                  subtitle: 'Back to home page',
                  onTap: () => _go(HomePageWidget.routeName)),
              _item(Icons.library_books_rounded, 'Browse Catalog',
                  subtitle: 'See all available books',
                  onTap: () => _go(BrowseBooksWidget.routeName)),
              _item(Icons.info_outline_rounded, 'About DII Library',
                  subtitle: 'Learn more about us',
                  onTap: () => _go(AboutPageWidget.routeName)),

              if (loggedIn) ...[
                const SizedBox(height: 8),
                _sectionLabel('MY LIBRARY'),
                _item(Icons.person_rounded, 'My Profile',
                    subtitle: 'Account & photo',
                    onTap: () => _go(ProfilePageWidget.routeName)),
                _item(Icons.book_rounded, 'My Books',
                    subtitle: 'Active loans & requests',
                    onTap: () => _go(MyBooksWidget.routeName)),
                _item(Icons.history_rounded, 'Borrowing History',
                    subtitle: 'Past borrowings',
                    onTap: () => _go(HistoryWidget.routeName)),
              ],

              if (isStaff) ...[
                const SizedBox(height: 8),
                _sectionLabel(isAdmin ? 'ADMIN TOOLS' : 'LIBRARIAN TOOLS'),
                if (isAdmin)
                  _item(Icons.dashboard_rounded, 'Admin Dashboard',
                      subtitle: 'KPIs & overview',
                      accent: kBlue,
                      onTap: () => _go(AdminDashboardWidget.routeName)),
                if (!isAdmin && role == 'librarian')
                  _item(Icons.dashboard_rounded, 'Librarian Dashboard',
                      subtitle: 'Loans & returns',
                      accent: kBlue,
                      onTap: () => _go(LibrarianDashboardWidget.routeName)),
                _item(Icons.assignment_rounded, 'Borrow Requests',
                    subtitle: 'Approve or reject',
                    accent: kYellow,
                    onTap: () => _go(AdminBorrowRequestsWidget.routeName)),
                _item(Icons.assignment_turned_in_rounded, 'Receive Return',
                    subtitle: 'Mark books returned',
                    accent: kGreen,
                    onTap: () => _go(LibrarianReturnWidget.routeName)),
                if (isAdmin) ...[
                  _item(Icons.people_rounded, 'Manage Students',
                      subtitle: 'Add, edit, block',
                      accent: kPurple,
                      onTap: () => _go(AdminStudentsWidget.routeName)),
                  _item(Icons.library_add_rounded, 'Manage Books',
                      subtitle: 'Add, edit, delete',
                      accent: kGreen,
                      onTap: () => _go(AdminBooksWidget.routeName)),
                  _item(Icons.badge_rounded, 'Librarians',
                      subtitle: 'Manage accounts',
                      accent: kPurple,
                      onTap: () => _go(AdminLibrariansWidget.routeName)),
                  _item(Icons.analytics_rounded, 'Reports',
                      subtitle: 'Stats & analytics',
                      accent: kRed,
                      onTap: () => _go(AdminReportsWidget.routeName)),
                ],
              ],

              const SizedBox(height: 8),
              _sectionLabel('SUPPORT'),
              _item(Icons.help_outline_rounded, 'Help Center',
                  subtitle: 'FAQ & contact',
                  onTap: () => _go(HelpWidget.routeName)),
              _item(Icons.privacy_tip_outlined, 'Privacy Policy',
                  onTap: () => _go(PrivacyWidget.routeName)),
              _item(Icons.contact_mail_outlined, 'Contact Us',
                  subtitle: '240023018@dii.tj',
                  onTap: () => _go(ContactWidget.routeName)),

              if (loggedIn) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: _signOut,
                      icon: const Icon(Icons.logout_rounded, color: kRed),
                      label: const Text('Sign Out',
                          style: TextStyle(
                            color: kRed,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          )),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: kRed, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 6),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }

  Widget _item(IconData icon, String title,
      {String? subtitle,
      Color? accent,
      required VoidCallback onTap}) {
    final color = accent ?? kBlue;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: GoogleFonts.interTight(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          )),
                      if (subtitle != null)
                        Text(subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Colors.grey.shade600,
                            )),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: Colors.grey.shade400, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
