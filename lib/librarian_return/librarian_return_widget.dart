import '/auth/firebase_auth/auth_util.dart';
import '/components/app_sidebar.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'librarian_return_model.dart';
export 'librarian_return_model.dart';

class LibrarianReturnWidget extends StatefulWidget {
  const LibrarianReturnWidget({super.key});
  static String routeName = 'LibrarianReturn';
  static String routePath = '/librarianReturn';

  @override
  State<LibrarianReturnWidget> createState() => _LibrarianReturnWidgetState();
}

class _LibrarianReturnWidgetState extends State<LibrarianReturnWidget> {
  late LibrarianReturnModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const Color kBlue   = Color(0xFF0A1E5C);
  static const Color kYellow = Color(0xFFFFC107);
  static const Color kGreen  = Color(0xFF10B981);
  static const Color kRed    = Color(0xFFDC0F0F);

  final Set<String> _busy = {};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LibrarianReturnModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _markReturned(String docId, Map<String, dynamic> data) async {
    if (_busy.contains(docId)) return;
    setState(() => _busy.add(docId));
    try {
      final bookId = (data['bookId'] ?? '').toString();
      final bookRef = FirebaseFirestore.instance.collection('books').doc(bookId);
      final borrowRef = FirebaseFirestore.instance.collection('borrowings').doc(docId);

      await FirebaseFirestore.instance.runTransaction((tx) async {
        final bookSnap = await tx.get(bookRef);
        final now = DateTime.now();

        tx.update(borrowRef, {
          'status': 'returned',
          'requestStatus': 'returned',
          'returnedAt': Timestamp.fromDate(now),
          'receivedBy': currentUserUid,
        });

        if (bookSnap.exists) {
          final book = bookSnap.data() ?? {};
          final total = (book['totalCopies'] as num?)?.toInt() ?? 1;
          final avail = (book['availableCopies'] as num?)?.toInt() ?? 0;
          tx.update(bookRef, {'availableCopies': (avail + 1).clamp(0, total)});
        }
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Marked returned'), backgroundColor: kGreen));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e'), backgroundColor: kRed));
    } finally {
      if (mounted) setState(() => _busy.remove(docId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    final body = Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: isDesktop ? null : AppBar(
        backgroundColor: kBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Receive Return',
            style: GoogleFonts.interTight(color: Colors.white,
              fontSize: 20, fontWeight: FontWeight.w800)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('borrowings')
            .where('status', whereIn: ['borrowed', 'approved', 'overdue'])
            .snapshots(),
        builder: (context, snap) {
          if (snap.hasError) return _error(context, snap.error.toString());
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty) return _empty(context);
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) => _card(context, docs[i]),
          );
        },
      ),
    );

    if (isDesktop) {
      return Row(children: [
        const AppSidebar(currentRoute: 'LibrarianReturn'),
        Expanded(child: body),
      ]);
    }
    return body;
  }

  Widget _card(BuildContext context, QueryDocumentSnapshot doc) {
    final m = doc.data() as Map<String, dynamic>;
    final title = (m['bookTitle'] ?? 'Unknown').toString();
    final cover = (m['bookCover'] ?? '').toString();
    final student = (m['userName'] ?? '').toString();
    final num = (m['studentNumber'] ?? '').toString();
    final due = m['dueDate'] is Timestamp
        ? (m['dueDate'] as Timestamp).toDate() : null;
    final overdue = due != null && due.isBefore(DateTime.now());
    final daysLate = overdue ? DateTime.now().difference(due).inDays : 0;
    final busy = _busy.contains(doc.id);

    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: overdue ? kRed.withOpacity(0.5) : kGreen.withOpacity(0.3),
          width: 2),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: cover.isNotEmpty
                    ? Image.network(cover, width: 64, height: 88, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(width: 64, height: 88,
                          color: FlutterFlowTheme.of(context).alternate,
                          child: const Icon(Icons.menu_book_rounded)))
                    : Container(width: 64, height: 88,
                        color: FlutterFlowTheme.of(context).alternate,
                        child: const Icon(Icons.menu_book_rounded)),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (overdue ? kRed : kGreen).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6)),
                    child: Text(overdue ? 'OVERDUE' : 'ACTIVE LOAN',
                      style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900,
                        letterSpacing: 0.6, color: overdue ? kRed : kGreen)),
                  ),
                  const SizedBox(height: 8),
                  Text(title, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.interTight(fontSize: 15, fontWeight: FontWeight.w800,
                      color: FlutterFlowTheme.of(context).primaryText)),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.person_rounded, size: 13, color: kBlue),
                    const SizedBox(width: 4),
                    Expanded(child: Text('$student · #$num', maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kBlue))),
                  ]),
                  if (due != null) ...[
                    const SizedBox(height: 6),
                    Row(children: [
                      Icon(overdue ? Icons.warning_amber_rounded : Icons.event_rounded,
                        size: 13, color: overdue ? kRed : kYellow),
                      const SizedBox(width: 4),
                      Expanded(child: Text(
                        overdue ? 'Overdue by $daysLate day${daysLate == 1 ? "" : "s"}'
                          : 'Due ${due.month}/${due.day}/${due.year}',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                          color: overdue ? kRed : const Color(0xFFB28600)),
                      )),
                    ]),
                  ],
                ],
              )),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: busy ? null : () => _markReturned(doc.id, m),
              icon: busy
                  ? const SizedBox(width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.assignment_turned_in_rounded, size: 18),
              label: const Text('Mark as Returned',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              style: ElevatedButton.styleFrom(
                backgroundColor: kGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _empty(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 100, height: 100,
            decoration: BoxDecoration(color: kBlue.withOpacity(0.08), shape: BoxShape.circle),
            child: const Icon(Icons.assignment_turned_in_rounded, size: 48, color: kBlue)),
          const SizedBox(height: 20),
          Text('No active loans',
            style: GoogleFonts.interTight(fontSize: 20, fontWeight: FontWeight.w800,
              color: FlutterFlowTheme.of(context).primaryText)),
          const SizedBox(height: 8),
          Text('Books awaiting return will show here',
            style: TextStyle(fontSize: 13.5, color: FlutterFlowTheme.of(context).secondaryText)),
        ],
      ),
    ),
  );

  Widget _error(BuildContext context, String msg) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline_rounded, size: 56, color: kRed),
        const SizedBox(height: 16),
        Text('Could not load returns', style: GoogleFonts.interTight(
          fontSize: 18, fontWeight: FontWeight.w800,
          color: FlutterFlowTheme.of(context).primaryText)),
        const SizedBox(height: 8),
        Text(msg, textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: FlutterFlowTheme.of(context).secondaryText)),
      ]),
    ),
  );
}
