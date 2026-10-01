import '/auth/firebase_auth/auth_util.dart';
import '/components/app_bottom_nav.dart';
import '/components/app_sidebar.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'my_books_model.dart';
export 'my_books_model.dart';

class MyBooksWidget extends StatefulWidget {
  const MyBooksWidget({super.key});

  static String routeName = 'MyBooks';
  static String routePath = '/myBooks';

  @override
  State<MyBooksWidget> createState() => _MyBooksWidgetState();
}

class _MyBooksWidgetState extends State<MyBooksWidget> {
  late MyBooksModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const Color kBlue   = Color(0xFF0A1E5C);
  static const Color kDeep   = Color(0xFF081444);
  static const Color kYellow = Color(0xFFFFC107);
  static const Color kGreen  = Color(0xFF10B981);
  static const Color kRed    = Color(0xFFDC0F0F);

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MyBooksModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  String _fmt(DateTime? d) {
    if (d == null) return '—';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  String _daysText(DateTime? due) {
    if (due == null) return 'Waiting for approval';
    final diff = due.difference(DateTime.now()).inDays;
    if (diff < 0) return 'Overdue by ${-diff} day${-diff == 1 ? "" : "s"}';
    if (diff == 0) return 'Due today';
    return '$diff day${diff == 1 ? "" : "s"} left';
  }

  @override
  Widget build(BuildContext context) {
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
              title: Text('My Books',
                  style: GoogleFonts.interTight(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  )),
            ),
      bottomNavigationBar:
          isDesktop ? null : const AppBottomNav(currentRoute: 'MyBooks'),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('borrowings')
            .where('userId', isEqualTo: currentUserUid)
            .where('status',
                whereIn: ['pending', 'approved', 'borrowed', 'overdue'])
            .snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return _errorState(context, snap.error.toString());
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data!.docs;
          if (docs.isEmpty) return _emptyState(context);
          return _buildList(context, docs);
        },
      ),
    );

    if (isDesktop) {
      return Row(
        children: [
          const AppSidebar(currentRoute: 'MyBooks'),
          Expanded(child: body),
        ],
      );
    }
    return body;
  }

  Widget _buildList(BuildContext context, List<QueryDocumentSnapshot> docs) {
    final now = DateTime.now();
    final pending =
        docs.where((d) => (d.data() as Map)['status'] == 'pending').toList();
    final active = docs.where((d) {
      final s = (d.data() as Map)['status'];
      return s == 'borrowed' || s == 'approved' || s == 'overdue';
    }).toList();

    // sort active by due date ascending
    active.sort((a, b) {
      final am = a.data() as Map<String, dynamic>;
      final bm = b.data() as Map<String, dynamic>;
      final ad = am['dueDate'] is Timestamp
          ? (am['dueDate'] as Timestamp).toDate()
          : DateTime(2100);
      final bd = bm['dueDate'] is Timestamp
          ? (bm['dueDate'] as Timestamp).toDate()
          : DateTime(2100);
      return ad.compareTo(bd);
    });

    int overdueCount = 0;
    for (final d in active) {
      final m = d.data() as Map<String, dynamic>;
      final due = m['dueDate'] is Timestamp
          ? (m['dueDate'] as Timestamp).toDate()
          : null;
      if (due != null && due.isBefore(now)) overdueCount++;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats bar
          Row(
            children: [
              Expanded(
                child: _stat(context, 'Active', active.length, kGreen,
                    Icons.book_rounded),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _stat(context, 'Pending', pending.length, kYellow,
                    Icons.hourglass_top_rounded),
              ),
              if (overdueCount > 0) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: _stat(context, 'Overdue', overdueCount, kRed,
                      Icons.warning_amber_rounded),
                ),
              ],
            ],
          ),
          const SizedBox(height: 28),

          // Active section
          if (active.isNotEmpty) ...[
            _sectionTitle(context, 'Currently Borrowed', active.length, kGreen),
            const SizedBox(height: 12),
            for (final d in active) _card(context, d),
            const SizedBox(height: 28),
          ],

          // Pending section
          if (pending.isNotEmpty) ...[
            _sectionTitle(context, 'Awaiting Approval', pending.length, kYellow),
            const SizedBox(height: 12),
            for (final d in pending) _card(context, d),
          ],
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String t, int count, Color c) {
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
        Text(t,
            style: GoogleFonts.interTight(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: FlutterFlowTheme.of(context).primaryText,
            )),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: c.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text('$count',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: c,
              )),
        ),
      ],
    );
  }

  Widget _stat(BuildContext context, String label, int value, Color color,
      IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$value',
                    style: GoogleFonts.interTight(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: color,
                    )),
                Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: FlutterFlowTheme.of(context).secondaryText,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(BuildContext context, QueryDocumentSnapshot doc) {
    final m = doc.data() as Map<String, dynamic>;
    final title = (m['bookTitle'] ?? 'Unknown').toString();
    final cover = (m['bookCover'] ?? '').toString();
    final code = (m['bookCode'] ?? '').toString();
    final status = (m['status'] ?? 'pending').toString();
    final borrowed = m['borrowedAt'] is Timestamp
        ? (m['borrowedAt'] as Timestamp).toDate()
        : null;
    final due = m['dueDate'] is Timestamp
        ? (m['dueDate'] as Timestamp).toDate()
        : null;

    final isOverdue =
        status == 'overdue' || (due != null && due.isBefore(DateTime.now()));

    Color statusColor;
    String statusLabel;
    if (status == 'pending') {
      statusColor = kYellow;
      statusLabel = 'PENDING';
    } else if (isOverdue) {
      statusColor = kRed;
      statusLabel = 'OVERDUE';
    } else if (status == 'borrowed' || status == 'approved') {
      statusColor = kGreen;
      statusLabel = 'BORROWED';
    } else {
      statusColor = kBlue;
      statusLabel = status.toUpperCase();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOverdue
              ? kRed.withOpacity(0.4)
              : FlutterFlowTheme.of(context).alternate.withOpacity(0.25),
          width: isOverdue ? 2 : 1,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: cover.isNotEmpty
                ? Image.network(
                    cover,
                    width: 80, height: 110, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 80, height: 110,
                      color: FlutterFlowTheme.of(context).alternate,
                      child: const Icon(Icons.menu_book_rounded, size: 32),
                    ),
                  )
                : Container(
                    width: 80, height: 110,
                    color: FlutterFlowTheme.of(context).alternate,
                    child: const Icon(Icons.menu_book_rounded, size: 32),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(statusLabel,
                      style: GoogleFonts.inter(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                        color: statusColor,
                      )),
                ),
                const SizedBox(height: 8),
                Text(title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.interTight(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      color: FlutterFlowTheme.of(context).primaryText,
                    )),
                if (code.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(code,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: FlutterFlowTheme.of(context).secondaryText,
                      )),
                ],
                const SizedBox(height: 10),
                if (borrowed != null)
                  _row(context, Icons.login_rounded,
                      'Borrowed ${_fmt(borrowed)}', kBlue),
                if (due != null) ...[
                  const SizedBox(height: 3),
                  _row(
                    context,
                    Icons.event_rounded,
                    'Due ${_fmt(due)}  ·  ${_daysText(due)}',
                    isOverdue ? kRed : kYellow,
                  ),
                ] else ...[
                  const SizedBox(height: 3),
                  _row(context, Icons.hourglass_top_rounded,
                      _daysText(due), kYellow),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, IconData icon, String text, Color c) {
    return Row(
      children: [
        Icon(icon, size: 13, color: c),
        const SizedBox(width: 5),
        Expanded(
          child: Text(text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: c,
              )),
        ),
      ],
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
              width: 110, height: 110,
              decoration: BoxDecoration(
                color: kBlue.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.menu_book_rounded, size: 52, color: kBlue),
            ),
            const SizedBox(height: 20),
            Text('No books borrowed yet',
                style: GoogleFonts.interTight(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: FlutterFlowTheme.of(context).primaryText,
                )),
            const SizedBox(height: 8),
            Text('Browse the catalog and request a book to start',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  color: FlutterFlowTheme.of(context).secondaryText,
                )),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.pushNamed(BrowseBooksWidget.routeName),
              icon: const Icon(Icons.search_rounded),
              label: const Text('Browse Books',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              style: ElevatedButton.styleFrom(
                backgroundColor: kBlue,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
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
            Text('Could not load your books',
                style: GoogleFonts.interTight(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: FlutterFlowTheme.of(context).primaryText,
                )),
            const SizedBox(height: 8),
            Text(msg,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: FlutterFlowTheme.of(context).secondaryText,
                )),
          ],
        ),
      ),
    );
  }
}
