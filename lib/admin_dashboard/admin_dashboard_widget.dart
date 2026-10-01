import '/components/app_sidebar.dart';
import '/custom/role_utils.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'admin_dashboard_model.dart';
export 'admin_dashboard_model.dart';

class AdminDashboardWidget extends StatefulWidget {
  const AdminDashboardWidget({super.key});
  static String routeName = 'AdminDashboard';
  static String routePath = '/adminDashboard';

  @override
  State<AdminDashboardWidget> createState() => _AdminDashboardWidgetState();
}

class _AdminDashboardWidgetState extends State<AdminDashboardWidget> {
  late AdminDashboardModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const Color kBlue   = Color(0xFF0A1E5C);
  static const Color kDeep   = Color(0xFF081444);
  static const Color kYellow = Color(0xFFFFC107);
  static const Color kGreen  = Color(0xFF10B981);
  static const Color kRed    = Color(0xFFDC0F0F);
  static const Color kPurple = Color(0xFF7B1FA2);

  bool _roleChecked = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AdminDashboardModel());
    Future.microtask(() async {
      await loadCurrentUserRole();
      if (mounted) setState(() => _roleChecked = true);
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_roleChecked) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!isAdminUser()) return _denied(context);

    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final body = Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: isDesktop ? null : _appBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isDesktop) _desktopHeader(context),
              _kpiGrid(context),
              const SizedBox(height: 28),
              _sectionTitle(context, 'Quick Actions'),
              const SizedBox(height: 12),
              _actionGrid(context),
              const SizedBox(height: 28),
              _sectionTitle(context, 'Latest Borrowings'),
              const SizedBox(height: 12),
              _latestBorrowings(context),
              const SizedBox(height: 28),
              _sectionTitle(context, 'Recent Users'),
              const SizedBox(height: 12),
              _recentUsers(context),
            ],
          ),
        ),
      ),
    );

    if (isDesktop) {
      return Row(children: [
        const AppSidebar(currentRoute: 'AdminDashboard'),
        Expanded(child: body),
      ]);
    }
    return body;
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      backgroundColor: kBlue,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Text('Admin Dashboard',
          style: GoogleFonts.interTight(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
    );
  }

  Widget _desktopHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Text('Admin Dashboard',
              style: GoogleFonts.interTight(
                fontSize: 28, fontWeight: FontWeight.w900,
                color: FlutterFlowTheme.of(context).primaryText,
              )),
        ],
      ),
    );
  }

  Widget _kpiGrid(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('books').snapshots(),
      builder: (context, bs) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, us) {
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('borrowings').snapshots(),
              builder: (context, brs) {
                int totalBooks = bs.data?.docs.length ?? 0;
                int available = 0;
                if (bs.hasData) {
                  for (final d in bs.data!.docs) {
                    final m = d.data() as Map<String, dynamic>;
                    if (((m['availableCopies'] as num?)?.toInt() ?? 0) > 0) {
                      available++;
                    }
                  }
                }
                int students = 0, staff = 0;
                if (us.hasData) {
                  for (final d in us.data!.docs) {
                    final r = ((d.data() as Map)['role'] ?? 'student').toString();
                    if (r == 'student') students++; else staff++;
                  }
                }
                int active = 0, overdue = 0, pending = 0;
                if (brs.hasData) {
                  final now = DateTime.now();
                  for (final d in brs.data!.docs) {
                    final m = d.data() as Map<String, dynamic>;
                    final s = (m['status'] ?? '').toString();
                    if (s == 'pending') pending++;
                    else if (s == 'borrowed' || s == 'approved') {
                      final due = m['dueDate'] is Timestamp
                          ? (m['dueDate'] as Timestamp).toDate() : null;
                      if (due != null && due.isBefore(now)) overdue++;
                      else active++;
                    }
                  }
                }

                return Column(
                  children: [
                    Row(children: [
                      Expanded(child: _kpi(context, 'Books', totalBooks, kBlue, Icons.menu_book_rounded)),
                      const SizedBox(width: 10),
                      Expanded(child: _kpi(context, 'Students', students, kGreen, Icons.people_rounded)),
                    ]),
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(child: _kpi(context, 'Active Loans', active, kYellow, Icons.book_rounded)),
                      const SizedBox(width: 10),
                      Expanded(child: _kpi(context, 'Overdue', overdue, kRed, Icons.warning_amber_rounded)),
                    ]),
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(child: _kpi(context, 'Pending', pending, kPurple, Icons.hourglass_top_rounded)),
                      const SizedBox(width: 10),
                      Expanded(child: _kpi(context, 'Available', available, kGreen, Icons.check_circle_rounded)),
                    ]),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _kpi(BuildContext context, String label, int value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('$value', style: GoogleFonts.interTight(
                fontSize: 22, fontWeight: FontWeight.w900, color: color)),
              Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600,
                    color: FlutterFlowTheme.of(context).secondaryText)),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _sectionTitle(BuildContext context, String t) {
    return Row(children: [
      Container(width: 4, height: 20,
        decoration: BoxDecoration(color: kYellow, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 10),
      Text(t, style: GoogleFonts.interTight(
        fontSize: 17, fontWeight: FontWeight.w800,
        color: FlutterFlowTheme.of(context).primaryText)),
    ]);
  }

  Widget _actionGrid(BuildContext context) {
    final actions = [
      ('Manage Students', Icons.people_rounded, kBlue, AdminStudentsWidget.routeName),
      ('Manage Books', Icons.library_add_rounded, kGreen, AdminBooksWidget.routeName),
      ('Borrow Requests', Icons.assignment_rounded, kYellow, AdminBorrowRequestsWidget.routeName),
      ('Librarians', Icons.badge_rounded, kPurple, AdminLibrariansWidget.routeName),
      ('Receive Return', Icons.assignment_turned_in_rounded, kGreen, LibrarianReturnWidget.routeName),
      ('Reports', Icons.analytics_rounded, kRed, AdminReportsWidget.routeName),
    ];
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: MediaQuery.of(context).size.width < 700 ? 2 : 3,
      crossAxisSpacing: 10, mainAxisSpacing: 10,
      childAspectRatio: 1.6,
      children: [
        for (final a in actions)
          InkWell(
            onTap: () => context.pushNamed(a.$4),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: a.$3.withOpacity(0.25)),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: a.$3.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(a.$2, color: a.$3, size: 20),
                  ),
                  const SizedBox(height: 8),
                  Text(a.$1, textAlign: TextAlign.center, maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 11.5, fontWeight: FontWeight.w800,
                        color: FlutterFlowTheme.of(context).primaryText)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _latestBorrowings(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('borrowings')
          .orderBy('borrowedAt', descending: true)
          .limit(5).snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) return _loading(context);
        final docs = snap.data!.docs;
        if (docs.isEmpty) return _empty(context, 'No borrowings yet');
        return Container(
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: FlutterFlowTheme.of(context).alternate.withOpacity(0.25)),
          ),
          child: Column(children: [
            for (int i = 0; i < docs.length; i++) ...[
              _borrowRow(context, docs[i]),
              if (i < docs.length - 1)
                Divider(height: 1, color: FlutterFlowTheme.of(context).alternate.withOpacity(0.2)),
            ]
          ]),
        );
      },
    );
  }

  Widget _borrowRow(BuildContext context, QueryDocumentSnapshot doc) {
    final m = doc.data() as Map<String, dynamic>;
    final title = (m['bookTitle'] ?? 'Unknown').toString();
    final user = (m['userName'] ?? 'Unknown').toString();
    final status = (m['status'] ?? 'borrowed').toString();
    final color = status == 'pending' ? kYellow
        : status == 'returned' ? kGreen
        : status == 'overdue' ? kRed
        : kBlue;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10)),
          child: Icon(Icons.menu_book_rounded, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: GoogleFonts.interTight(fontSize: 13, fontWeight: FontWeight.w700,
                  color: FlutterFlowTheme.of(context).primaryText)),
            Text('by $user', maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11.5,
                  color: FlutterFlowTheme.of(context).secondaryText)),
          ],
        )),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6)),
          child: Text(status.toUpperCase(),
              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900,
                letterSpacing: 0.6, color: color)),
        ),
      ]),
    );
  }

  Widget _recentUsers(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .limit(5).snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) return _loading(context);
        final docs = snap.data!.docs;
        if (docs.isEmpty) return _empty(context, 'No users yet');
        return Container(
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: FlutterFlowTheme.of(context).alternate.withOpacity(0.25)),
          ),
          child: Column(children: [
            for (int i = 0; i < docs.length; i++) ...[
              _userRow(context, docs[i]),
              if (i < docs.length - 1)
                Divider(height: 1, color: FlutterFlowTheme.of(context).alternate.withOpacity(0.2)),
            ]
          ]),
        );
      },
    );
  }

  Widget _userRow(BuildContext context, QueryDocumentSnapshot doc) {
    final m = doc.data() as Map<String, dynamic>;
    final name = (m['name'] ?? 'Unknown').toString();
    final num = (m['studentNumber'] ?? '').toString();
    final role = (m['role'] ?? 'student').toString();
    final color = role == 'admin' ? kBlue
        : role == 'librarian' ? kPurple : kGreen;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(color: color, fontWeight: FontWeight.w900)),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: GoogleFonts.interTight(fontSize: 13, fontWeight: FontWeight.w700,
                  color: FlutterFlowTheme.of(context).primaryText)),
            Text('#$num', maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11.5,
                  color: FlutterFlowTheme.of(context).secondaryText)),
          ],
        )),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6)),
          child: Text(role.toUpperCase(),
              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900,
                letterSpacing: 0.6, color: color)),
        ),
      ]),
    );
  }

  Widget _loading(BuildContext context) => Container(
    height: 80,
    decoration: BoxDecoration(
      color: FlutterFlowTheme.of(context).secondaryBackground,
      borderRadius: BorderRadius.circular(14),
    ),
    child: const Center(child: CircularProgressIndicator()),
  );

  Widget _empty(BuildContext context, String msg) => Container(
    height: 80,
    decoration: BoxDecoration(
      color: FlutterFlowTheme.of(context).secondaryBackground,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Center(child: Text(msg,
      style: TextStyle(color: FlutterFlowTheme.of(context).secondaryText))),
  );

  Widget _denied(BuildContext context) => Scaffold(
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
                style: GoogleFonts.interTight(fontSize: 20, fontWeight: FontWeight.w800,
                  color: FlutterFlowTheme.of(context).primaryText)),
            const SizedBox(height: 8),
            const Text('Only administrators can access this page'),
          ],
        ),
      ),
    ),
  );
}
