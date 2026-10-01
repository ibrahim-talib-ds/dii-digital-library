import '/auth/firebase_auth/auth_util.dart';
import '/components/app_bottom_nav.dart';
import '/components/app_sidebar.dart';
import '/custom/role_utils.dart';
import '/custom/user_avatar.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import 'profile_stats_widget.dart';
import 'profile_page_model.dart';
export 'profile_page_model.dart';

class ProfilePageWidget extends StatefulWidget {
  const ProfilePageWidget({super.key});

  static String routeName = 'ProfilePage';
  static String routePath = '/profilePage';

  @override
  State<ProfilePageWidget> createState() => _ProfilePageWidgetState();
}

class _ProfilePageWidgetState extends State<ProfilePageWidget> {
  late ProfilePageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const Color kBlue   = Color(0xFF0A1E5C);
  static const Color kDeep   = Color(0xFF081444);
  static const Color kYellow = Color(0xFFFFC107);
  static const Color kGreen  = Color(0xFF10B981);
  static const Color kRed    = Color(0xFFDC0F0F);
  static const Color kPurple = Color(0xFF7B1FA2);

  static const String _ownerEmail = '240023018@dii.tj';

  final ImagePicker _picker = ImagePicker();
  Map<String, dynamic>? _student;
  bool _loading = true;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ProfilePageModel());
    _loadStudent();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _loadStudent() async {
    setState(() => _loading = true);
    await loadCurrentUserRole();
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final snap = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
        _student = snap.exists ? snap.data() : currentUserDoc();
      } else {
        _student = currentUserDoc();
      }
    } catch (_) {
      _student = currentUserDoc();
    }
    if (!mounted) return;
    setState(() => _loading = false);
  }

  String _role() {
    final r = (_student?['role'] ?? currentRole()).toString();
    return r.isEmpty ? 'student' : r;
  }

  Color _roleColor() {
    final r = _role();
    if (r == 'admin') return kYellow;
    if (r == 'librarian') return kPurple;
    return kGreen;
  }

  Future<void> _signOut() async {
    clearRoleCache();
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    context.goNamedAuth(LoginPageWidget.routeName, context.mounted);
  }

  Future<void> _onAvatarTapped() async {
    final userEmail =
        (FirebaseAuth.instance.currentUser?.email ?? '').toLowerCase();
    if (userEmail == _ownerEmail) {
      final choice = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Change profile photo'),
          content: const Text('Choose how to set your photo:'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'cancel'),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'url'),
              child: const Text('Paste URL'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kBlue),
              onPressed: () => Navigator.pop(ctx, 'upload'),
              child: const Text('Upload'),
            ),
          ],
        ),
      );
      if (choice == 'url') {
        _askForUrl();
      } else if (choice == 'upload') {
        _pickAndUploadAvatar();
      }
    } else {
      _pickAndUploadAvatar();
    }
  }

  Future<void> _askForUrl() async {
    final ctl = TextEditingController();
    final url = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Paste image URL'),
        content: TextField(
          controller: ctl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'https://example.com/photo.jpg',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kBlue),
            onPressed: () => Navigator.pop(ctx, ctl.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (url == null || url.isEmpty) return;
    if (!url.startsWith('http')) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL must start with http')),
      );
      return;
    }
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set({'photoUrl': url}, SetOptions(merge: true));
    await _loadStudent();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo updated'), backgroundColor: kGreen),
    );
  }

  Future<void> _pickAndUploadAvatar() async {
    if (_uploading) return;
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 85,
      );
      if (picked == null) return;

      setState(() => _uploading = true);

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        setState(() => _uploading = false);
        return;
      }

      final Uint8List raw = await picked.readAsBytes();
      final decoded = img.decodeImage(raw);
      if (decoded == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not read image')),
        );
        setState(() => _uploading = false);
        return;
      }

      final resized = img.copyResize(decoded,
          width: 200,
          height: 200,
          interpolation: img.Interpolation.average);
      final Uint8List jpg =
          Uint8List.fromList(img.encodeJpg(resized, quality: 75));

      final b64 = base64Encode(jpg);
      final dataUrl = 'data:image/jpeg;base64,$b64';

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({'photoUrl': dataUrl}, SetOptions(merge: true));

      try {
        await FirebaseAuth.instance.currentUser?.updatePhotoURL(dataUrl);
      } catch (_) {}

      await _loadStudent();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile photo updated'),
          backgroundColor: kGreen,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: kRed),
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isPhone = w < 600;
    final isDesktop = w >= 1024;

    final body = Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: kBlue,
              iconTheme: const IconThemeData(color: Colors.white),
              title: Text('My Profile',
                  style: GoogleFonts.interTight(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  )),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                  onPressed: _loadStudent,
                ),
              ],
            ),
      bottomNavigationBar:
          isDesktop ? null : const AppBottomNav(currentRoute: 'ProfilePage'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStudent,
              color: kBlue,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: _buildContent(context, isPhone),
              ),
            ),
    );

    if (isDesktop) {
      return Row(
        children: [
          const AppSidebar(currentRoute: 'ProfilePage'),
          Expanded(child: body),
        ],
      );
    }
    return body;
  }

  Widget _buildContent(BuildContext context, bool isPhone) {
    final name = (_student?['name'] ?? currentUserDisplayName).toString();
    final email = (_student?['email'] ?? currentUserEmail).toString();
    final num = (_student?['studentNumber'] ?? '').toString();
    final dept =
        (_student?['department'] ?? _student?['faculty'] ?? '').toString();
    final limit = castToType<int>(_student?['borrowLimit']) ?? 3;
    final status = (_student?['status'] ?? 'active').toString();
    final role = _role();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ═══════════════════════════════════════════════════
        // HERO HEADER — big, beautiful
        // ═══════════════════════════════════════════════════
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [kBlue, kDeep],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
          child: Column(
            children: [
              // Avatar with camera badge
              GestureDetector(
                onTap: _uploading ? null : _onAvatarTapped,
                child: Stack(
                  children: [
                    Container(
                      width: 110, height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: kYellow, width: 4),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 20,
                            color: Color(0x44000000),
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: const UserAvatar(size: 110),
                    ),
                    Positioned(
                      right: 4, bottom: 4,
                      child: Container(
                        width: 34, height: 34,
                        decoration: BoxDecoration(
                          color: kYellow,
                          shape: BoxShape.circle,
                          border: Border.all(color: kBlue, width: 3),
                        ),
                        child: _uploading
                            ? const Padding(
                                padding: EdgeInsets.all(7),
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: kBlue),
                              )
                            : const Icon(Icons.camera_alt_rounded,
                                color: kBlue, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Name
              Text(
                name.isEmpty ? 'Student' : name,
                textAlign: TextAlign.center,
                style: GoogleFonts.interTight(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              // Email
              Text(
                email,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 14),

              // Role + status badges
              Wrap(
                spacing: 8,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: _roleColor(),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          role == 'admin'
                              ? Icons.admin_panel_settings_rounded
                              : role == 'librarian'
                                  ? Icons.badge_rounded
                                  : Icons.school_rounded,
                          color: kBlue,
                          size: 12,
                        ),
                        const SizedBox(width: 5),
                        Text(role.toUpperCase(),
                            style: const TextStyle(
                              color: kBlue,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            )),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: status == 'blocked'
                          ? kRed
                          : Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: status == 'blocked'
                            ? kRed
                            : Colors.white.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          status == 'blocked'
                              ? Icons.block_rounded
                              : Icons.check_circle_rounded,
                          color: Colors.white,
                          size: 12,
                        ),
                        const SizedBox(width: 5),
                        Text(status.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ═══════════════════════════════════════════════
              // LIBRARY STATS
              // ═══════════════════════════════════════════════
              _sectionTitle(context, 'My Library Stats'),
              const SizedBox(height: 12),
              const ProfileStatsWidget(),

              const SizedBox(height: 28),

              // ═══════════════════════════════════════════════
              // ACCOUNT INFO
              // ═══════════════════════════════════════════════
              _sectionTitle(context, 'Account Information'),
              const SizedBox(height: 12),
              _infoRow(context, Icons.badge_rounded, 'Student Number',
                  num.isEmpty ? '—' : num),
              _infoRow(context, Icons.school_rounded, 'Department',
                  dept.isEmpty ? '—' : dept),
              _infoRow(context, Icons.menu_book_rounded, 'Borrow Limit',
                  '$limit books'),
              _infoRow(context, Icons.email_rounded, 'Email',
                  email.isEmpty ? '—' : email),

              const SizedBox(height: 28),

              // ═══════════════════════════════════════════════
              // QUICK ACTIONS
              // ═══════════════════════════════════════════════
              _sectionTitle(context, 'Library Actions'),
              const SizedBox(height: 12),
              _menuItem(context,
                  icon: Icons.book_rounded,
                  title: 'My Books',
                  subtitle: 'Currently borrowed & pending',
                  accent: kGreen,
                  onTap: () => context.pushNamed(MyBooksWidget.routeName)),
              _menuItem(context,
                  icon: Icons.history_rounded,
                  title: 'Borrowing History',
                  subtitle: 'All your past borrowings',
                  accent: kBlue,
                  onTap: () => context.pushNamed(HistoryWidget.routeName)),
              _menuItem(context,
                  icon: Icons.library_books_rounded,
                  title: 'Browse Catalog',
                  subtitle: 'Explore our book collection',
                  accent: kYellow,
                  onTap: () => context.pushNamed(BrowseBooksWidget.routeName)),

              // ═══════════════════════════════════════════════
              // ROLE TOOLS (librarian/admin)
              // ═══════════════════════════════════════════════
              if (role == 'librarian' || role == 'admin') ...[
                const SizedBox(height: 28),
                _sectionTitle(context,
                    role == 'admin' ? 'Admin Tools' : 'Librarian Tools'),
                const SizedBox(height: 12),
                if (role == 'admin')
                  _menuItem(context,
                      icon: Icons.dashboard_rounded,
                      title: 'Admin Dashboard',
                      subtitle: 'KPIs, activity, quick actions',
                      accent: kBlue,
                      onTap: () => context
                          .pushNamed(AdminDashboardWidget.routeName)),
                if (role == 'librarian')
                  _menuItem(context,
                      icon: Icons.dashboard_rounded,
                      title: 'Librarian Dashboard',
                      subtitle: 'Loans, returns, low stock',
                      accent: kBlue,
                      onTap: () => context
                          .pushNamed(LibrarianDashboardWidget.routeName)),
                _menuItem(context,
                    icon: Icons.assignment_rounded,
                    title: 'Borrow Requests',
                    subtitle: 'Approve or reject student requests',
                    accent: kYellow,
                    onTap: () => context
                        .pushNamed(AdminBorrowRequestsWidget.routeName)),
                _menuItem(context,
                    icon: Icons.assignment_turned_in_rounded,
                    title: 'Receive Return',
                    subtitle: 'Mark books as returned',
                    accent: kGreen,
                    onTap: () =>
                        context.pushNamed(LibrarianReturnWidget.routeName)),
                if (role == 'admin') ...[
                  _menuItem(context,
                      icon: Icons.people_rounded,
                      title: 'Manage Students',
                      subtitle: 'Add, edit, block, delete',
                      accent: kPurple,
                      onTap: () =>
                          context.pushNamed(AdminStudentsWidget.routeName)),
                  _menuItem(context,
                      icon: Icons.library_add_rounded,
                      title: 'Manage Books',
                      subtitle: 'Add, edit, delete books',
                      accent: kGreen,
                      onTap: () =>
                          context.pushNamed(AdminBooksWidget.routeName)),
                  _menuItem(context,
                      icon: Icons.badge_rounded,
                      title: 'Librarians',
                      subtitle: 'Manage librarian accounts',
                      accent: kPurple,
                      onTap: () => context
                          .pushNamed(AdminLibrariansWidget.routeName)),
                  _menuItem(context,
                      icon: Icons.analytics_rounded,
                      title: 'Reports & Analytics',
                      subtitle: 'Top books, students, overdue',
                      accent: kYellow,
                      onTap: () =>
                          context.pushNamed(AdminReportsWidget.routeName)),
                ],
              ],

              const SizedBox(height: 28),

              // ═══════════════════════════════════════════════
              // SIGN OUT
              // ═══════════════════════════════════════════════
              SizedBox(
                width: double.infinity,
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
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: kRed, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  Widget _sectionTitle(BuildContext context, String title) {
    return Row(
      children: [
        Container(
          width: 4, height: 20,
          decoration: BoxDecoration(
            color: kYellow,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(title,
            style: GoogleFonts.interTight(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: FlutterFlowTheme.of(context).primaryText,
            )),
      ],
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate.withOpacity(0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: kBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: kBlue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: FlutterFlowTheme.of(context).secondaryText,
                    )),
                const SizedBox(height: 2),
                Text(value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: FlutterFlowTheme.of(context).primaryText,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle,
      required Color accent,
      required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: accent.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: accent, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: GoogleFonts.interTight(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: FlutterFlowTheme.of(context).primaryText,
                          )),
                      const SizedBox(height: 2),
                      Text(subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: FlutterFlowTheme.of(context).secondaryText,
                          )),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: FlutterFlowTheme.of(context).secondaryText),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
