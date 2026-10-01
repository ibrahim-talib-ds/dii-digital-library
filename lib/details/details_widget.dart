import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/app_bottom_nav.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'details_model.dart';
export 'details_model.dart';

class DetailsWidget extends StatefulWidget {
  const DetailsWidget({super.key, this.books});

  final DocumentReference? books;

  static String routeName = 'Details';
  static String routePath = '/details';

  @override
  State<DetailsWidget> createState() => _DetailsWidgetState();
}

class _DetailsWidgetState extends State<DetailsWidget> {
  late DetailsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const Color kBlue = Color(0xFF0A1E5C);
  static const Color kRed = Color(0xFFDC0F0F);
  static const Color kYellow = Color(0xFFFFC107);

  bool _requesting = false;
  bool _alreadyRequested = false;
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DetailsModel());
    _checkExisting();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _checkExisting() async {
    if (!loggedIn || widget.books == null) {
      setState(() => _checked = true);
      return;
    }
    try {
      final snap = await FirebaseFirestore.instance
          .collection('borrowings')
          .where('userId', isEqualTo: currentUserUid)
          .where('bookId', isEqualTo: widget.books!.id)
          .where('status', whereIn: ['pending', 'approved', 'borrowed'])
          .limit(1)
          .get();
      if (!mounted) return;
      setState(() {
        _alreadyRequested = snap.docs.isNotEmpty;
        _checked = true;
      });
    } catch (_) {
      if (mounted) setState(() => _checked = true);
    }
  }

  Future<void> _requestBook(Map<String, dynamic> book) async {
    if (!loggedIn) {
      context.pushNamed(LoginPageWidget.routeName);
      return;
    }
    if (_requesting || _alreadyRequested) return;
    setState(() => _requesting = true);

    try {
      String studentName = '';
      String studentNumber = '';
      final userDoc = await FirebaseFirestore.instance
          .collection('users').doc(currentUserUid).get();
      if (userDoc.exists) {
        final d = userDoc.data() ?? {};
        studentName = (d['name'] ?? '').toString();
        studentNumber = (d['studentNumber'] ?? '').toString();
      }

      final available = (book['availableCopies'] as num?)?.toInt() ?? 0;
      if (available <= 0) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No copies available — please wait'),
              backgroundColor: kRed),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('borrowings').add({
        'userId': currentUserUid,
        'studentNumber': studentNumber,
        'userName': studentName,
        'bookId': widget.books!.id,
        'bookTitle': (book['title'] ?? '').toString(),
        'bookCover': (book['Cover_url'] ?? '').toString(),
        'bookCode': (book['bookCode'] ?? '').toString(),
        'status': 'pending',
        'requestStatus': 'pending',
        'borrowedAt': FieldValue.serverTimestamp(),
        'dueDate': null,
        'returnedAt': null,
        'fine': 0.0,
        'notes': '',
      });

      if (!mounted) return;
      setState(() => _alreadyRequested = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request sent — waiting for librarian approval'),
          backgroundColor: kBlue,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not request: $e'), backgroundColor: kRed),
      );
    } finally {
      if (mounted) setState(() => _requesting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.books == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('No book selected')),
      );
    }

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primary,
        iconTheme: IconThemeData(color: FlutterFlowTheme.of(context).alternate),
        title: Text('Book Details',
            style: GoogleFonts.interTight(
              color: FlutterFlowTheme.of(context).alternate,
              fontSize: 20, fontWeight: FontWeight.w800,
            )),
      ),
      bottomNavigationBar: const AppBottomNav(currentRoute: 'Details'),
      body: FutureBuilder<DocumentSnapshot>(
        future: widget.books!.get(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final doc = snap.data!;
          if (!doc.exists) return const Center(child: Text('Book not found'));

          final book = doc.data() as Map<String, dynamic>;
          final title = (book['title'] ?? 'Untitled').toString();
          final author = (book['author'] ?? '').toString();
          final category = (book['category'] ?? '').toString();
          final description = (book['description'] ?? '').toString();
          final cover = (book['Cover_url'] ?? '').toString();
          final pdf = (book['pdfUrl'] ?? '').toString();
          final pages = (book['pages'] as num?)?.toInt() ?? 0;
          final language = (book['language'] ?? '').toString();
          final code = (book['bookCode'] ?? '').toString();
          final total = (book['totalCopies'] as num?)?.toInt() ?? 0;
          final available = (book['availableCopies'] as num?)?.toInt() ?? 0;
          final isAvailable = available > 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: cover.isNotEmpty
                          ? Image.network(cover, width: 140, height: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 140, height: 200,
                                color: FlutterFlowTheme.of(context).alternate,
                                child: const Icon(Icons.menu_book_rounded, size: 40)))
                          : Container(width: 140, height: 200,
                              color: FlutterFlowTheme.of(context).alternate,
                              child: const Icon(Icons.menu_book_rounded, size: 40)),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: GoogleFonts.interTight(
                            fontSize: 22, fontWeight: FontWeight.w800,
                            color: FlutterFlowTheme.of(context).primaryText,
                          )),
                          const SizedBox(height: 4),
                          if (author.isNotEmpty)
                            Text(author, style: TextStyle(
                              fontSize: 14,
                              color: FlutterFlowTheme.of(context).secondaryText,
                            )),
                          if (code.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text('Code: $code', style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600,
                              color: FlutterFlowTheme.of(context).secondaryText,
                            )),
                          ],
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: (isAvailable ? kBlue : kRed).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isAvailable ? 'AVAILABLE · $available / $total' : 'OUT OF STOCK',
                              style: GoogleFonts.inter(
                                fontSize: 11, fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                                color: isAvailable ? kBlue : kRed,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (category.isNotEmpty)
                            _infoLine(context, 'Category', category),
                          if (pages > 0)
                            _infoLine(context, 'Pages', '$pages'),
                          if (language.isNotEmpty)
                            _infoLine(context, 'Language', language),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (description.isNotEmpty) ...[
                  Text('About this book', style: GoogleFonts.interTight(
                    fontSize: 17, fontWeight: FontWeight.w700,
                    color: FlutterFlowTheme.of(context).primaryText,
                  )),
                  const SizedBox(height: 8),
                  Text(description, style: TextStyle(
                    fontSize: 14, height: 1.5,
                    color: FlutterFlowTheme.of(context).primaryText,
                  )),
                  const SizedBox(height: 24),
                ],
                if (pdf.isNotEmpty) ...[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => launchURL(pdf),
                      icon: const Icon(Icons.picture_as_pdf_rounded),
                      label: const Text('Read PDF Preview'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: kBlue),
                        foregroundColor: kBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: (!_checked || _requesting || _alreadyRequested || !isAvailable)
                        ? null : () => _requestBook(book),
                    icon: _requesting
                        ? const SizedBox(width: 18, height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Icon(_alreadyRequested
                            ? Icons.check_circle_rounded
                            : Icons.book_online_rounded),
                    label: Text(
                      _alreadyRequested
                          ? 'Already Requested'
                          : (!isAvailable ? 'Not Available'
                              : (_requesting ? 'Sending…' : 'Request Book')),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kBlue,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade400,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoLine(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(
            fontSize: 12.5, fontWeight: FontWeight.w600,
            color: FlutterFlowTheme.of(context).secondaryText,
          )),
          Expanded(child: Text(value, style: TextStyle(
            fontSize: 12.5, fontWeight: FontWeight.w700,
            color: FlutterFlowTheme.of(context).primaryText,
          ))),
        ],
      ),
    );
  }
}
