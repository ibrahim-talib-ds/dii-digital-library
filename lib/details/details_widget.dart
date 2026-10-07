import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/custom/book_reader_page.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  static const Color kBlue   = Color(0xFF0A1E5C);
  static const Color kDeep   = Color(0xFF081444);
  static const Color kYellow = Color(0xFFFFC107);
  static const Color kGreen  = Color(0xFF10B981);
  static const Color kPurple = Color(0xFF7B1FA2);
  static const Color kRed    = Color(0xFFDC0F0F);

  bool _requesting = false;
  bool _alreadyRequested = false;
  bool _checked = false;
  bool _isSaved = false;
  bool _savedChecked = false;

  Future<DocumentSnapshot>? _bookFuture;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DetailsModel());
    _bookFuture = widget.books?.get();
    _checkExisting();
    _checkSaved();
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

  Future<void> _checkSaved() async {
    if (!loggedIn || widget.books == null) {
      setState(() => _savedChecked = true);
      return;
    }
    try {
      final docId = '${currentUserUid}_${widget.books!.id}';
      final snap = await FirebaseFirestore.instance
          .collection('saved_books')
          .doc(docId)
          .get();
      if (!mounted) return;
      setState(() {
        _isSaved = snap.exists;
        _savedChecked = true;
      });
    } catch (_) {
      if (mounted) setState(() => _savedChecked = true);
    }
  }

  Future<void> _toggleSave(Map<String, dynamic> book) async {
    if (!loggedIn) {
      context.pushNamed(LoginPageWidget.routeName);
      return;
    }
    final docId = '${currentUserUid}_${widget.books!.id}';
    try {
      if (_isSaved) {
        await FirebaseFirestore.instance
            .collection('saved_books')
            .doc(docId)
            .delete();
        if (!mounted) return;
        setState(() => _isSaved = false);
        _toast('Removed from saved', kBlue);
      } else {
        await FirebaseFirestore.instance
            .collection('saved_books')
            .doc(docId)
            .set({
          'userId': currentUserUid,
          'bookId': widget.books!.id,
          'bookTitle': (book['title'] ?? '').toString(),
          'bookCover': (book['Cover_url'] ?? '').toString(),
          'bookCode': (book['bookCode'] ?? '').toString(),
          'bookAuthor': (book['author'] ?? '').toString(),
          'bookType': (book['bookType'] ?? 'both').toString(),
          'savedAt': FieldValue.serverTimestamp(),
        });
        if (!mounted) return;
        setState(() => _isSaved = true);
        _toast('Saved to your library', kGreen);
      }
    } catch (e) {
      _toast('Could not save: $e', kRed);
    }
  }

  void _toast(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  Future<void> _requestBook(Map<String, dynamic> book) async {
    if (!loggedIn) {
      context.pushNamed(LoginPageWidget.routeName);
      return;
    }
    if (_requesting || _alreadyRequested) return;
    setState(() => _requesting = true);

    try {
      final db = FirebaseFirestore.instance;
      final userDoc = await db.collection('users').doc(currentUserUid).get();
      final d = userDoc.data() ?? {};

      if ((d['status'] ?? 'active') == 'blocked' || d['active'] == false) {
        _toast('Your account is blocked. Please contact the librarian.', kRed);
        return;
      }

      await db.collection('borrowings').add({
        'userId': currentUserUid,
        'studentNumber': (d['studentNumber'] ?? '').toString(),
        'userName': (d['name'] ?? '').toString(),
        'userEmail': FirebaseAuth.instance.currentUser?.email ?? '',
        'userDepartment': (d['department'] ?? '').toString(),
        'userYear': (d['year'] as num?)?.toInt() ?? 0,
        'bookId': widget.books!.id,
        'bookTitle': (book['title'] ?? '').toString(),
        'bookCover': (book['Cover_url'] ?? '').toString(),
        'bookCode': (book['bookCode'] ?? '').toString(),
        'status': 'pending',
        'requestStatus': 'pending',
        'requestedAt': FieldValue.serverTimestamp(),
        'borrowedAt': FieldValue.serverTimestamp(),
        'dueDate': null,
        'returnedAt': null,
        'fine': 0.0,
        'notes': '',
      });

      if (!mounted) return;
      setState(() => _alreadyRequested = true);
      _toast('Request sent — waiting for librarian approval', kBlue);
    } catch (e) {
      _toast('Could not request: $e', kRed);
    } finally {
      if (mounted) setState(() => _requesting = false);
    }
  }

  void _openReader(String title, String pdf) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => BookReaderPage(title: title, pdfUrl: pdf),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.books == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('No book selected')),
      );
    }

    final w = MediaQuery.of(context).size.width;
    final isPhone = w < 600;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: FutureBuilder<DocumentSnapshot>(
        future: _bookFuture,
        builder: (context, snap) {
          if (snap.hasError) {
            return const Center(child: Text('Could not load book'));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
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

          final rawType = (book['bookType'] ?? 'both').toString();
          final hasPdf = pdf.isNotEmpty;
          final hasDigital = (rawType != 'physical') && hasPdf;
          final hasPhysical = rawType != 'digital';

          final typeText = rawType == 'digital'
              ? 'Digital'
              : rawType == 'physical'
                  ? 'Physical'
                  : 'Digital + Physical';

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ═══════════════════════════════════════════════
                // HERO
                // ═══════════════════════════════════════════════
                Stack(
                  children: [
                    // Gradient background
                    Container(
                      height: isPhone ? 460 : 520,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [kBlue, kDeep],
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(28),
                          bottomRight: Radius.circular(28),
                        ),
                      ),
                    ),
                    // Subtle pattern
                    Positioned(
                      right: -80, top: 40,
                      child: Container(
                        width: 200, height: 200,
                        decoration: BoxDecoration(
                          color: kYellow.withOpacity(0.06),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      left: -60, bottom: 100,
                      child: Container(
                        width: 140, height: 140,
                        decoration: BoxDecoration(
                          color: kYellow.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                    // Content
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            // ─── Top bar ───
                            Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 20),
                              child: Row(
                                children: [
                                  _iconBtn(
                                    icon: Icons.arrow_back_rounded,
                                    onTap: () => context.safePop(),
                                  ),
                                  const Spacer(),
                                  _iconBtn(
                                    icon: _isSaved
                                        ? Icons.bookmark_rounded
                                        : Icons.bookmark_border_rounded,
                                    color: kYellow,
                                    onTap: _savedChecked
                                        ? () => _toggleSave(book)
                                        : null,
                                  ),
                                ],
                              ),
                            ),

                            // ─── Floating cover ───
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 40,
                                    color: Colors.black.withOpacity(0.5),
                                    offset: const Offset(0, 20),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: SizedBox(
                                  width: isPhone ? 200 : 240,
                                  height: isPhone ? 280 : 340,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      cover.isNotEmpty
                                          ? Image.network(cover,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  _placeholder(context))
                                          : _placeholder(context),
                                      // Type badge
                                      Positioned(
                                        top: 12, left: 12,
                                        child: _typeBadge(rawType),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // ─── Title ───
                            Text(
                              title,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.interTight(
                                color: Colors.white,
                                fontSize: isPhone ? 24 : 30,
                                fontWeight: FontWeight.w900,
                                height: 1.15,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // ─── Author ───
                            if (author.isNotEmpty)
                              Text(
                                'by $author',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                            const SizedBox(height: 12),

                            // ─── Code · Category ───
                            Text(
                              [
                                if (code.isNotEmpty) code,
                                if (category.isNotEmpty) category,
                              ].join('  ·  '),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: kYellow,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // ═══════════════════════════════════════════════
                // CTA BUTTONS
                // ═══════════════════════════════════════════════
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Column(
                    children: [
                      if (hasDigital)
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: loggedIn
                                ? () => _openReader(title, pdf)
                                : () => context.pushNamed(
                                    LoginPageWidget.routeName),
                            icon: const Icon(Icons.chrome_reader_mode_rounded,
                                size: 20),
                            label: Text(
                              loggedIn ? 'Read Online' : 'Sign in to Read',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kYellow,
                              foregroundColor: kBlue,
                              elevation: 4,
                              shadowColor: kYellow.withOpacity(0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      if (hasDigital && hasPhysical)
                        const SizedBox(height: 12),
                      if (hasPhysical)
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed:
                                (!_checked || _requesting || _alreadyRequested)
                                    ? null
                                    : () => _requestBook(book),
                            icon: _requesting
                                ? const SizedBox(
                                    width: 18, height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white))
                                : Icon(_alreadyRequested
                                    ? Icons.check_circle_rounded
                                    : Icons.book_online_rounded,
                                    size: 20),
                            label: Text(
                              _alreadyRequested
                                  ? 'Already Requested'
                                  : (_requesting
                                      ? 'Sending…'
                                      : 'Request Physical Copy'),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kBlue,
                              foregroundColor: Colors.white,
                              elevation: 4,
                              shadowColor: kBlue.withOpacity(0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // ═══════════════════════════════════════════════
                // ABOUT THIS BOOK
                // ═══════════════════════════════════════════════
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _sectionHeader(context, 'About this book'),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: FlutterFlowTheme.of(context)
                              .alternate
                              .withOpacity(0.25),
                        ),
                      ),
                      child: Text(
                        description,
                        style: TextStyle(
                          fontSize: 14.5,
                          height: 1.6,
                          color: FlutterFlowTheme.of(context).primaryText,
                        ),
                      ),
                    ),
                  ),
                ],

                // ═══════════════════════════════════════════════
                // DETAILS
                // ═══════════════════════════════════════════════
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _sectionHeader(context, 'Details'),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: FlutterFlowTheme.of(context)
                            .alternate
                            .withOpacity(0.25),
                      ),
                    ),
                    child: Column(
                      children: [
                        if (pages > 0)
                          _detailRow(context, Icons.description_outlined,
                              'Pages', '$pages'),
                        if (language.isNotEmpty)
                          _detailRow(context, Icons.language_rounded,
                              'Language', language),
                        if (category.isNotEmpty)
                          _detailRow(context, Icons.category_outlined,
                              'Category', category),
                        if (code.isNotEmpty)
                          _detailRow(context, Icons.qr_code_rounded,
                              'Book Code', code),
                        _detailRow(context, Icons.collections_bookmark_outlined,
                            'Type', typeText),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Helpers
  // ═══════════════════════════════════════════════════════════════
  Widget _iconBtn({
    required IconData icon,
    required VoidCallback? onTap,
    Color color = Colors.white,
  }) {
    return Material(
      color: Colors.white.withOpacity(0.15),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 42, height: 42,
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }

  Widget _typeBadge(String type) {
    Color c = kGreen;
    IconData i = Icons.auto_stories_rounded;
    String t = 'BOTH';
    if (type == 'digital') {
      c = kPurple;
      i = Icons.tablet_mac_rounded;
      t = 'DIGITAL';
    } else if (type == 'physical') {
      c = kBlue;
      i = Icons.menu_book_rounded;
      t = 'PHYSICAL';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            blurRadius: 6,
            color: Color(0x33000000),
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(i, color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Text(t,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              )),
        ],
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      color: FlutterFlowTheme.of(context).alternate,
      alignment: Alignment.center,
      child: const Icon(Icons.menu_book_rounded, size: 60, color: Colors.grey),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
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
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: FlutterFlowTheme.of(context).primaryText,
            )),
      ],
    );
  }

  Widget _detailRow(BuildContext context,
      IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: kBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: kBlue, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: FlutterFlowTheme.of(context).secondaryText,
                )),
          ),
          Text(value,
              style: GoogleFonts.interTight(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: FlutterFlowTheme.of(context).primaryText,
              )),
        ],
      ),
    );
  }
}
