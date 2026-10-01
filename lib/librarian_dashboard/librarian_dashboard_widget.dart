import '/components/app_sidebar.dart';
import '/custom/role_utils.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'librarian_dashboard_model.dart';
export 'librarian_dashboard_model.dart';

class LibrarianDashboardWidget extends StatefulWidget {
  const LibrarianDashboardWidget({super.key});
  static String routeName = 'LibrarianDashboard';
  static String routePath = '/librarianDashboard';

  @override
  State<LibrarianDashboardWidget> createState() =>
      _LibrarianDashboardWidgetState();
}

class _LibrarianDashboardWidgetState extends State<LibrarianDashboardWidget> {
  late LibrarianDashboardModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const Color kBlue   = Color(0xFF0A1E5C);
  static const Color kYellow = Color(0xFFFFC107);
  static const Color kGreen  = Color(0xFF10B981);
  static const Color kRed    = Color(0xFFDC0F0F);

  bool _roleChecked = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LibrarianDashboardModel());
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
    if (!(isLibrarianUser() || isAdminUser())) return _denied(context);

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
              _sectionTitle(context, 'Daily Tasks'),
              const SizedBox(height: 12),
              _tasks(context),
              const SizedBox(height: 28),
              _sectionTitle(context, 'Pending Returns'),
              const SizedBox(height: 12),
              _pendingReturns(context),
            ],
          ),
        ),
      ),
    );

    if (isDesktop) {
      return Row(children: [
        const AppSidebar(currentRoute: 'LibrarianDashboard'),
        Expanded(child: body),
      ]);
    }
    return body;
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      backgroundColor: kBlue,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Text('Librarian Dashboard',
          style: GoogleFonts.interTight(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
    );
  }

  Widget _desktopHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text('Librarian Dashboard',
          style: GoogleFonts.interTight(
            fontSize: 28, fontWeight: FontWeight.w900,
            color: FlutterFlowTheme.of(context).primaryText)),
    );
  }

  Widget _kpiGrid(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('borrowings').snapshots(),
      builder: (context, brs) {
        int active = 0, pending = 0, overdue = 0, returned = 0;
        if (brs.hasData) {
          final now = DateTime.now();
          for (final d in brs.data!.docs) {
            final m = d.data() as Map<String, dynamic>;
            final s = (m['status'] ?? '').toString();
            if (s == 'pending') pending++;
            else if (s == 'returned') returned++;
            else if (s == 'borrowed' || s == 'approved') {
              final due = m['dueDate'] is Timestamp
                  ? (m['dueDate'] as Timestamp).toDate() : null;
              if (due != null && due.isBefore(now)) overdue++;
              else active++;
            }
          }
        }
        return Column(children: [
          Row(children: [
            Expanded(child: _kpi(context, 'Active', active, kGreen, Icons.book_rounded)),
            const SizedBox(width: 10),
            Expanded(child: _kpi(context, 'Pending', pending, kYellow, Icons.hourglass_top_rounded)),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _kpi(context, 'Overdue', overdue, kRed, Icons.warning_amber_rounded)),
            const SizedBox(width: 10),
            Expanded(child: _kpi(context, 'Returned', returned, kBlue, Icons.assignment_turned_in_rounded)),
          ]),
        ]);
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
          decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(11)),
          child: Icon(icon, color: color, size: 22)),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$value', style: GoogleFonts.interTight(
              fontSize: 22, fontWeight: FontWeight.w900, color: color)),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                color: FlutterFlowTheme.of(context).secondaryText)),
          ],
        )),
      ]),
    );
  }

  Widget _sectionTitle(BuildContext context, String t) {
    return Row(children: [
      Container(width: 4, height: 20,
        decoration: BoxDecoration(color: kYellow, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 10),
      Text(t, style: GoogleFonts.interTight(fontSize: 17, fontWeight: FontWeight.w800,
        color: FlutterFlowTheme.of(context).primaryText)),
    ]);
  }

  Widget _tasks(BuildContext context) {
    final tasks = [
      ('Borrow Requests', Icons.assignment_rounded, kYellow, AdminBorrowRequestsWidget.routeName),
      ('Receive Return', Icons.assignment_turned_in_rounded, kGreen, LibrarianReturnWidget.routeName),
      ('Add Book', Icons.library_add_rounded, kBlue, AdminBooksWidget.routeName),
      ('View Students', Icons.people_rounded, kBlue, AdminStudentsWidget.routeName),
    ];
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: MediaQuery.of(context).size.width < 700 ? 2 : 4,
      crossAxisSpacing: 10, mainAxisSpacing: 10,
      childAspectRatio: 1.4,
      children: [
        for (final t in tasks)
          InkWell(
            onTap: () => context.pushNamed(t.$4),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: t.$3.withOpacity(0.25)),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 40, height: 40,
                    decoration: BoxDecoration(color: t.$3.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                    child: Icon(t.$2, color: t.$3, size: 20)),
                  const SizedBox(height: 8),
                  Text(t.$1, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w800,
                      color: FlutterFlowTheme.of(context).primaryText)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _pendingReturns(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('borrowings')
          .where('status', whereIn: ['borrowed', 'approved', 'overdue'])
          .orderBy('dueDate', descending: false)
          .limit(10).snapshots(),
      builder: (context, snap) {
        if (snap.hasData) {
          return Container(
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: FlutterFlowTheme.of(context).alternate.withOpacity(0.25)),
            ),
            child: const SizedBox.shrink(),
          );
        }
        if (!snap.hasData) {
          return Container(
            height: 80,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        final docs = snap.data!.docs;
        if (docs.isEmpty) {
          return Container(
            height: 80,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(child: Text('No pending returns',
              style: TextStyle(color: FlutterFlowTheme.of(context).secondaryText))),
          );
        }
        return Container(
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: FlutterFlowTheme.of(context).alternate.withOpacity(0.25)),
          ),
          child: Column(children: [
            for (int i = 0; i < docs.length; i++) ...[
              _returnRow(context, docs[i]),
              if (i < docs.length - 1)
                Divider(height: 1, color: FlutterFlowTheme.of(context).alternate.withOpacity(0.2)),
            ]
          ]),
        );
      },
    );
  }

  Widget _returnRow(BuildContext context, QueryDocumentSnapshot doc) {
    final m = doc.data() as Map<String, dynamic>;
    final title = (m['bookTitle'] ?? 'Unknown').toString();
    final user = (m['userName'] ?? 'Unknown').toString();
    final num = (m['studentNumber'] ?? '').toString();
    final due = m['dueDate'] is Timestamp
        ? (m['dueDate'] as Timestamp).toDate() : null;
    final overdue = due != null && due.isBefore(DateTime.now());

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(children: [
        Container(width: 40, height: 40,
          decoration: BoxDecoration(
            color: (overdue ? kRed : kBlue).withOpacity(0.12),
            borderRadius: BorderRadius.circular(10)),
          child: Icon(Icons.menu_book_rounded, color: overdue ? kRed : kBlue, size: 18)),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: GoogleFonts.interTight(fontSize: 13, fontWeight: FontWeight.w700,
                color: FlutterFlowTheme.of(context).primaryText)),
            Text('$user · #$num', maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11.5, color: FlutterFlowTheme.of(context).secondaryText)),
          ],
        )),
        if (due != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: (overdue ? kRed : kGreen).withOpacity(0.15),
              borderRadius: BorderRadius.circular(6)),
            child: Text(
              '${overdue ? "Overdue" : "Due"} ${due.month}/${due.day}',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900,
                color: overdue ? kRed : kGreen)),
          ),
      ]),
    );
  }

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
          ],
        ),
      ),
    ),
  );
}
