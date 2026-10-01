import '/auth/firebase_auth/auth_util.dart';
import '/components/app_bottom_nav.dart';
import '/components/app_sidebar.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'history_model.dart';
export 'history_model.dart';

class HistoryWidget extends StatefulWidget {
  const HistoryWidget({super.key});

  static String routeName = 'History';
  static String routePath = '/history';

  @override
  State<HistoryWidget> createState() => _HistoryWidgetState();
}

class _HistoryWidgetState extends State<HistoryWidget> {
  late HistoryModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const Color kBlue   = Color(0xFF0A1E5C);
  static const Color kDeep   = Color(0xFF081444);
  static const Color kYellow = Color(0xFFFFC107);
  static const Color kGreen  = Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HistoryModel());
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
              title: Text('Borrowing History',
                  style: GoogleFonts.interTight(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  )),
            ),
      bottomNavigationBar:
          isDesktop ? null : const AppBottomNav(currentRoute: 'History'),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('borrowings')
            .where('userId', isEqualTo: currentUserUid)
            .where('status', isEqualTo: 'returned')
            .snapshots(),
        builder: (context, snap) {
          if (snap.hasError) return _error(context, snap.error.toString());
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data!.docs;
          if (docs.isEmpty) return _empty(context);

          final sorted = [...docs];
          sorted.sort((a, b) {
            final am = a.data() as Map<String, dynamic>;
            final bm = b.data() as Map<String, dynamic>;
            final ad = am['returnedAt'] is Timestamp
                ? (am['returnedAt'] as Timestamp).toDate()
                : DateTime(1900);
            final bd = bm['returnedAt'] is Timestamp
                ? (bm['returnedAt'] as Timestamp).toDate()
                : DateTime(1900);
            return bd.compareTo(ad);
          });

          int totalDays = 0;
          for (final d in sorted) {
            final m = d.data() as Map<String, dynamic>;
            final b = m['borrowedAt'] is Timestamp
                ? (m['borrowedAt'] as Timestamp).toDate()
                : null;
            final r = m['returnedAt'] is Timestamp
                ? (m['returnedAt'] as Timestamp).toDate()
                : null;
            if (b != null && r != null) {
              totalDays += r.difference(b).inDays;
            }
          }
          final avgDays =
              sorted.isEmpty ? 0 : (totalDays / sorted.length).round();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary strip
                Row(
                  children: [
                    Expanded(
                      child: _stat(context, 'Books Returned',
                          sorted.length, kBlue, Icons.assignment_turned_in_rounded),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _stat(context, 'Avg. Days Kept',
                          avgDays, kGreen, Icons.timelapse_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                _sectionTitle(context, 'Returned Books', sorted.length),
                const SizedBox(height: 12),
                for (final d in sorted) _card(context, d),
              ],
            ),
          );
        },
      ),
    );

    if (isDesktop) {
      return Row(
        children: [
          const AppSidebar(currentRoute: 'History'),
          Expanded(child: body),
        ],
      );
    }
    return body;
  }

  Widget _sectionTitle(BuildContext context, String t, int count) {
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
            color: kBlue.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text('$count',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: kBlue,
              )),
        ),
      ],
    );
  }

  Widget _stat(BuildContext context, String label, int value, Color color,
      IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$value',
                    style: GoogleFonts.interTight(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: color,
                    )),
                Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
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
    final borrowed = m['borrowedAt'] is Timestamp
        ? (m['borrowedAt'] as Timestamp).toDate()
        : null;
    final returned = m['returnedAt'] is Timestamp
        ? (m['returnedAt'] as Timestamp).toDate()
        : null;
    final days = (borrowed != null && returned != null)
        ? returned.difference(borrowed).inDays
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate.withOpacity(0.25),
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
                    width: 72, height: 98, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 72, height: 98,
                      color: FlutterFlowTheme.of(context).alternate,
                      child: const Icon(Icons.menu_book_rounded, size: 28),
                    ),
                  )
                : Container(
                    width: 72, height: 98,
                    color: FlutterFlowTheme.of(context).alternate,
                    child: const Icon(Icons.menu_book_rounded, size: 28),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: kGreen.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('RETURNED',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                        color: kGreen,
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
                _row(context, Icons.login_rounded, 'Borrowed ${_fmt(borrowed)}',
                    kBlue),
                const SizedBox(height: 3),
                _row(context, Icons.logout_rounded,
                    'Returned ${_fmt(returned)}', kGreen),
                if (days != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: kYellow.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Kept for $days day${days == 1 ? "" : "s"}',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFB28600),
                      ),
                    ),
                  ),
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

  Widget _empty(BuildContext context) {
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
              child: const Icon(Icons.history_rounded, size: 52, color: kBlue),
            ),
            const SizedBox(height: 20),
            Text('No history yet',
                style: GoogleFonts.interTight(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: FlutterFlowTheme.of(context).primaryText,
                )),
            const SizedBox(height: 8),
            Text('Books you return will appear here',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  color: FlutterFlowTheme.of(context).secondaryText,
                )),
          ],
        ),
      ),
    );
  }

  Widget _error(BuildContext context, String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 56, color: Color(0xFFDC0F0F)),
            const SizedBox(height: 16),
            Text('Could not load history',
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
