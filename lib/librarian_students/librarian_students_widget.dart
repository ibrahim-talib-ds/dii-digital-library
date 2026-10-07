import '/custom/role_utils.dart';
import '/custom/student_info_tile.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'librarian_students_model.dart';
import '/components/app_sidebar.dart';
export 'librarian_students_model.dart';

class LibrarianStudentsWidget extends StatefulWidget {
  const LibrarianStudentsWidget({super.key});

  static String routeName = 'LibrarianStudents';
  static String routePath = '/librarianStudents';

  @override
  State<LibrarianStudentsWidget> createState() =>
      _LibrarianStudentsWidgetState();
}

class _LibrarianStudentsWidgetState extends State<LibrarianStudentsWidget> {
  late LibrarianStudentsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const Color kBlue   = Color(0xFF0A1E5C);
  static const Color kYellow = Color(0xFFFFC107);
  static const Color kGreen  = Color(0xFF10B981);
  static const Color kPurple = Color(0xFF7B1FA2);
  static const Color kRed    = Color(0xFFDC0F0F);

  bool _roleChecked = false;
  String _search = '';
  String _roleFilter = 'student';

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LibrarianStudentsModel());
    _loadRoleAndCheck();
  }

  Future<void> _loadRoleAndCheck() async {
    try {
      // Always load fresh — ignore any cached value
      await loadCurrentUserRole();
    } catch (_) {}
    if (mounted) setState(() => _roleChecked = true);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _messageStudent(String email, String name) async {
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This student has no email on file')),
      );
      return;
    }
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=DII Library — Message to $name',
    );
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open email app. Student email: $email')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Student email: $email')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_roleChecked) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (!(isLibrarianUser() || isAdminUser())) {
      return _accessDenied(context);
    }

    final w = MediaQuery.of(context).size.width;
    final isDesktop = w >= 1024;

    final body = Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: kBlue,
              iconTheme: const IconThemeData(color: Colors.white),
              title: Text('Students',
                  style: GoogleFonts.interTight(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  )),
            ),
      body: SafeArea(
        child: Column(
          children: [
            // ─── Search bar ───
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: TextField(
                onChanged: (v) => setState(() => _search = v.trim().toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Search by name, email, or student number',
                  prefixIcon: const Icon(Icons.search_rounded, color: kBlue),
                  filled: true,
                  fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            // ─── Role filter chips ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final r in ['student', 'librarian', 'admin', 'all'])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(r.toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.4,
                                color: _roleFilter == r ? Colors.white : kBlue,
                              )),
                          selected: _roleFilter == r,
                          selectedColor: kBlue,
                          backgroundColor: kBlue.withOpacity(0.1),
                          onSelected: (_) => setState(() => _roleFilter = r),
                          showCheckmark: false,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // ─── Student list ───
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .orderBy('name')
                    .snapshots(),
                builder: (context, snap) {
                  if (snap.hasError) {
                    return _errorState(context, snap.error.toString());
                  }
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  var docs = snap.data!.docs;

                  // role filter
                  if (_roleFilter != 'all') {
                    docs = docs
                        .where((d) =>
                            ((d.data() as Map)['role'] ?? 'student') ==
                            _roleFilter)
                        .toList();
                  }
                  // search filter
                  if (_search.isNotEmpty) {
                    docs = docs.where((d) {
                      final m = d.data() as Map<String, dynamic>;
                      final hay = [
                        m['name'] ?? '',
                        m['email'] ?? '',
                        m['studentNumber'] ?? '',
                        m['department'] ?? '',
                      ].join(' ').toLowerCase();
                      return hay.contains(_search);
                    }).toList();
                  }

                  if (docs.isEmpty) {
                    return _emptyState(context);
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) =>
                        _studentCard(context, docs[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );

    if (isDesktop) {
      return Row(
        children: [
          AppSidebar(currentRoute: 'LibrarianStudents'),
          Expanded(child: body),
        ],
      );
    }
    return body;
  }

  Widget _studentCard(BuildContext context, QueryDocumentSnapshot doc) {
    final m = doc.data() as Map<String, dynamic>;
    final name = (m['name'] ?? 'Unknown').toString();
    final email = (m['email'] ?? '').toString();
    final role = (m['role'] ?? 'student').toString();
    final status = (m['status'] ?? 'active').toString();

    Color roleColor = kGreen;
    if (role == 'librarian') roleColor = kPurple;
    if (role == 'admin') roleColor = kBlue;

    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate.withOpacity(0.25),
        ),
        boxShadow: const [
          BoxShadow(
            blurRadius: 6,
            color: Color(0x08000000),
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          StudentInfoTile(
            userId: doc.id,
            name: name,
            studentNumber: (m['studentNumber'] ?? '').toString(),
            email: email,
            department: (m['department'] ?? '').toString(),
            year: castToType<int>(m['year']) ?? 0,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Role badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: roleColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(role.toUpperCase(),
                    style: GoogleFonts.inter(
                      color: roleColor,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    )),
              ),
              const SizedBox(width: 6),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (status == 'blocked' ? kRed : kGreen)
                      .withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(status.toUpperCase(),
                    style: GoogleFonts.inter(
                      color: status == 'blocked' ? kRed : kGreen,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    )),
              ),
              const Spacer(),
              // Message button
              OutlinedButton.icon(
                onPressed: () => _messageStudent(email, name),
                icon: const Icon(Icons.mail_outline_rounded, size: 16),
                label: const Text('Message',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    )),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kYellow,
                  side: const BorderSide(color: kYellow, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                color: kBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.people_outline_rounded,
                  size: 48, color: kBlue),
            ),
            const SizedBox(height: 16),
            Text('No users found',
                style: GoogleFonts.interTight(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: FlutterFlowTheme.of(context).primaryText,
                )),
            const SizedBox(height: 8),
            Text(
              _search.isEmpty
                  ? 'No users match the selected role'
                  : 'No results for "$_search"',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorState(BuildContext context, String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 56, color: kRed),
            const SizedBox(height: 16),
            const Text('Could not load students',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }

  Widget _accessDenied(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline_rounded, size: 64, color: kRed),
              const SizedBox(height: 16),
              Text('Access Denied',
                  style: GoogleFonts.interTight(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: FlutterFlowTheme.of(context).primaryText,
                  )),
              const SizedBox(height: 8),
              const Text('Only staff can view this page'),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.safePop(),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
