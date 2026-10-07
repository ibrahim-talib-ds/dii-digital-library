import '/auth/firebase_auth/auth_util.dart';
import '/components/app_sidebar.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'admin_borrow_requests_model.dart';
import '/custom/student_info_tile.dart';
import '/custom/role_utils.dart';
export 'admin_borrow_requests_model.dart';

class AdminBorrowRequestsWidget extends StatefulWidget {
  const AdminBorrowRequestsWidget({super.key});
  static String routeName = 'AdminBorrowRequests';
  static String routePath = '/adminBorrowRequests';

  @override
  State<AdminBorrowRequestsWidget> createState() =>
      _AdminBorrowRequestsWidgetState();
}

class _AdminBorrowRequestsWidgetState extends State<AdminBorrowRequestsWidget> {
  bool _roleChecked = false;

  late AdminBorrowRequestsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const Color kBlue   = Color(0xFF0A1E5C);
  static const Color kYellow = Color(0xFFFFC107);
  static const Color kGreen  = Color(0xFF10B981);
  static const Color kRed    = Color(0xFFDC0F0F);

  final Set<String> _busy = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await loadCurrentUserRole();
      if (mounted) setState(() => _roleChecked = true);
    });
    _model = createModel(context, () => AdminBorrowRequestsModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _approve(String docId, Map<String, dynamic> data) async {
    if (_busy.contains(docId)) return;
    setState(() => _busy.add(docId));
    try {
      final bookId = (data['bookId'] ?? '').toString();
      final bookRef = FirebaseFirestore.instance.collection('books').doc(bookId);

      await FirebaseFirestore.instance.runTransaction((tx) async {
        final bookSnap = await tx.get(bookRef);
        if (!bookSnap.exists) throw Exception('Book no longer exists');
        final book = bookSnap.data() ?? {};
        final available = (book['availableCopies'] as num?)?.toInt() ?? 0;
        if (available <= 0) throw Exception('No copies available');

        final now = DateTime.now();
        final due = now.add(const Duration(days: 14));

        tx.update(bookRef, {
          'availableCopies': available - 1,
        });

        tx.update(
          FirebaseFirestore.instance.collection('borrowings').doc(docId),
          {
            'status': 'borrowed',
            'requestStatus': 'approved',
            'borrowedAt': Timestamp.fromDate(now),
            'dueDate': Timestamp.fromDate(due),
            'approvedBy': currentUserUid,
            'approvedAt': FieldValue.serverTimestamp(),
          },
        );
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Approved'), backgroundColor: kGreen));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Approve failed: $e'), backgroundColor: kRed));
    } finally {
      if (mounted) setState(() => _busy.remove(docId));
    }
  }

  Future<void> _reject(String docId) async {
    if (_busy.contains(docId)) return;
    setState(() => _busy.add(docId));
    try {
      await FirebaseFirestore.instance
          .collection('borrowings').doc(docId).update({
        'status': 'rejected',
        'requestStatus': 'rejected',
        'approvedBy': currentUserUid,
        'approvedAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rejected'), backgroundColor: kRed));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reject failed: $e'), backgroundColor: kRed));
    } finally {
      if (mounted) setState(() => _busy.remove(docId));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_roleChecked) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (!(isLibrarianUser() || isAdminUser())) return _accessDenied(context);
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    final body = Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: isDesktop ? null : AppBar(
        backgroundColor: kBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Borrow Requests',
            style: GoogleFonts.interTight(color: Colors.white,
              fontSize: 20, fontWeight: FontWeight.w800)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('borrowings')
            .where('status', isEqualTo: 'pending')
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
        const AppSidebar(currentRoute: 'AdminBorrowRequests'),
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
    final email = (m['userEmail'] ?? '').toString();
    final dept = (m['userDepartment'] ?? '').toString();
    final year = castToType<int>(m['userYear']) ?? 0;
    final code = (m['bookCode'] ?? '').toString();
    final busy = _busy.contains(doc.id);

    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kYellow.withOpacity(0.4), width: 2),
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
                    decoration: BoxDecoration(color: kYellow.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6)),
                    child: const Text('PENDING REQUEST',
                        style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900,
                          letterSpacing: 0.6, color: Color(0xFFB28600))),
                  ),
                  const SizedBox(height: 8),
                  Text(title, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.interTight(fontSize: 15, fontWeight: FontWeight.w800,
                      color: FlutterFlowTheme.of(context).primaryText)),
                  if (code.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(code, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600,
                      color: FlutterFlowTheme.of(context).secondaryText)),
                  ],
                  const SizedBox(height: 8),
                  const SizedBox(height: 10),
                  StudentInfoTile(
                    userId: (m['userId'] ?? '').toString(),
                    name: student,
                    studentNumber: num,
                    email: email,
                    department: dept,
                    year: year,
                  ),
                ],
              )),
            ],
          ),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: OutlinedButton.icon(
              onPressed: busy ? null : () => _reject(doc.id),
              icon: const Icon(Icons.close_rounded, size: 18),
              label: const Text('Reject', style: TextStyle(fontWeight: FontWeight.w800)),
              style: OutlinedButton.styleFrom(
                foregroundColor: kRed,
                side: const BorderSide(color: kRed, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            )),
            const SizedBox(width: 10),
            Expanded(child: ElevatedButton.icon(
              onPressed: busy ? null : () => _approve(doc.id, m),
              icon: busy
                  ? const SizedBox(width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.check_rounded, size: 18),
              label: const Text('Approve', style: TextStyle(fontWeight: FontWeight.w800)),
              style: ElevatedButton.styleFrom(
                backgroundColor: kGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            )),
          ]),
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
            decoration: BoxDecoration(color: kGreen.withOpacity(0.08), shape: BoxShape.circle),
            child: const Icon(Icons.inbox_rounded, size: 48, color: kGreen)),
          const SizedBox(height: 20),
          Text('No pending requests',
            style: GoogleFonts.interTight(fontSize: 20, fontWeight: FontWeight.w800,
              color: FlutterFlowTheme.of(context).primaryText)),
          const SizedBox(height: 8),
          Text('All caught up!',
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
        Text('Could not load requests', style: GoogleFonts.interTight(
          fontSize: 18, fontWeight: FontWeight.w800,
          color: FlutterFlowTheme.of(context).primaryText)),
        const SizedBox(height: 8),
        Text(msg, textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: FlutterFlowTheme.of(context).secondaryText)),
      ]),
    ),
  );

  // ─── Access denied screen ───
  Widget _accessDenied(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline_rounded, size: 64, color: Colors.red.shade400),
              const SizedBox(height: 16),
              Text(
                'Access Denied',
                style: GoogleFonts.interTight(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: FlutterFlowTheme.of(context).primaryText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You do not have permission to view this page.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
              ),
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
