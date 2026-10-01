import '/auth/firebase_auth/auth_util.dart';
import '/backend/schema/users_record.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'book_details_v2_model.dart';
export 'book_details_v2_model.dart';

class BookDetailsV2Widget extends StatefulWidget {
  const BookDetailsV2Widget({
    super.key,
    required this.bookId,
  });

  final String bookId;

  static String routeName = 'BookDetailsV2';
  static String routePath = '/bookDetailsV2';

  @override
  State<BookDetailsV2Widget> createState() => _BookDetailsV2WidgetState();
}

class _BookDetailsV2WidgetState extends State<BookDetailsV2Widget> {
  late BookDetailsV2Model _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const Color kBlue = Color(0xFF0A1E5C);
  static const Color kRed = Color(0xFFDC0F0F);
  static const Color kYellow = Color(0xFFFFC107);

  bool _requesting = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BookDetailsV2Model());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _requestBook(Map<String, dynamic> book) async {
    if (_requesting) return;
    setState(() => _requesting = true);
    try {
      // Fetch current student profile to cache name + number
      String studentName = '';
      String studentNumber = '';
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserUid)
            .get();
        if (doc.exists) {
          final d = doc.data() ?? {};
          studentName = (d['name'] ?? '').toString();
          studentNumber = (d['studentNumber'] ?? '').toString();
        }
      } catch (_) {}

      // Check for existing active borrowing
      final existing = await FirebaseFirestore.instance
          .collection('borrowings')
          .where('userId', isEqualTo: currentUserUid)
          .where('bookId', isEqualTo: widget.bookId)
          .where('status', whereIn: ['pending', 'approved', 'borrowed'])
          .get();

      if (existing.docs.isNotEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You already have an active request for this book')),
        );
        return;
      }

      final available = (book['availableCopies'] as num?)?.toInt() ?? 0;
      if (available <= 0) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No copies available — please wait')),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('borrowings').add({
        'userId': currentUserUid,
        'studentNumber': studentNumber,
        'userName': studentName,
        'bookId': widget.bookId,
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
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primary,
        iconTheme: IconThemeData(color: FlutterFlowTheme.of(context).alternate),
        title: Text('Book Details',
            style: GoogleFonts.interTight(
              color: FlutterFlowTheme.of(context).alternate,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            )),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('books')
            .doc(widget.bookId)
            .get(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final doc = snap.data!;
          if (!doc.exists) {
            return const Center(child: Text('Book not found'));
          }
          final book = doc.data() as Map<String, dynamic>;
          final title = (book['title'] ?? 'Untitled').toString();
          final author = (book['author'] ?? '').toString();
          final category = (book['category'] ?? '').toString();
          final description = (book['description'] ?? '').toString();
          final cover = (book['Cover_url'] ?? '').toString();
          final pdf = (book['pdfUrl'] ?? '').toString();
          final pages = (book['pages'] as num?)?.toInt() ?? 0;
          final language = (book['language'] ?? '').toString();
          final total = (book['totalCopies'] as num?)?.toInt() ?? 0;
          final available = (book['availableCopies'] as num?)?.toInt() ?? 0;
          final isAvailable = available > 0;

          return SingleChildScrollView(
            child: Padding(
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
                            ? Image.network(cover,
                                width: 140, height: 200, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                      width: 140, height: 200,
                                      color: FlutterFlowTheme.of(context).alternate,
                                      child: const Icon(Icons.menu_book_rounded, size: 40),
                                    ))
                            : Container(
                                width: 140, height: 200,
                                color: FlutterFlowTheme.of(context).alternate,
                                child: const Icon(Icons.menu_book_rounded, size: 40),
                              ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title,
                                style: GoogleFonts.interTight(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: FlutterFlowTheme.of(context).primaryText,
                                )),
                            const SizedBox(height: 6),
                            if (author.isNotEmpty)
                              Text(author,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: FlutterFlowTheme.of(context).secondaryText,
                                  )),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: (isAvailable ? kBlue : kRed).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isAvailable ? 'AVAILABLE · $available / $total' : 'BORROWED',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                  color: isAvailable ? kBlue : kRed,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (category.isNotEmpty)
                              Text('Category: $category',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: FlutterFlowTheme.of(context).secondaryText,
                                  )),
                            if (pages > 0)
                              Text('Pages: $pages',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: FlutterFlowTheme.of(context).secondaryText,
                                  )),
                            if (language.isNotEmpty)
                              Text('Language: $language',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: FlutterFlowTheme.of(context).secondaryText,
                                  )),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (description.isNotEmpty) ...[
                    Text('Description',
                        style: GoogleFonts.interTight(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: FlutterFlowTheme.of(context).primaryText,
                        )),
                    const SizedBox(height: 8),
                    Text(description,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
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
                        label: const Text('Read PDF'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: FlutterFlowTheme.of(context).primary),
                          foregroundColor: FlutterFlowTheme.of(context).primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: (_requesting || !isAvailable) ? null : () => _requestBook(book),
                      icon: _requesting
                          ? const SizedBox(
                              width: 18, height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.book_online_rounded),
                      label: Text(
                        _requesting
                            ? 'Sending…'
                            : (isAvailable ? 'Request Book' : 'Not Available'),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
