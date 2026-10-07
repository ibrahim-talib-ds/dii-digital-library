import '/auth/firebase_auth/auth_util.dart';
import '/components/app_sidebar.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'saved_books_model.dart';
export 'saved_books_model.dart';

class SavedBooksWidget extends StatefulWidget {
  const SavedBooksWidget({super.key});

  static String routeName = 'SavedBooks';
  static String routePath = '/savedBooks';

  @override
  State<SavedBooksWidget> createState() => _SavedBooksWidgetState();
}

class _SavedBooksWidgetState extends State<SavedBooksWidget> {
  late SavedBooksModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const Color kBlue   = Color(0xFF0A1E5C);
  static const Color kYellow = Color(0xFFFFC107);
  static const Color kPurple = Color(0xFF7B1FA2);
  static const Color kGreen  = Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SavedBooksModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isPhone = w < 600;
    final isTablet = w >= 600 && w < 1024;
    final isDesktop = w >= 1024;
    final cols = isPhone ? 2 : (isTablet ? 4 : 6);

    final body = Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: kBlue,
              iconTheme: const IconThemeData(color: Colors.white),
              title: Text('Saved Books',
                  style: GoogleFonts.interTight(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  )),
            ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('saved_books')
              .where('userId', isEqualTo: currentUserUid)
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

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isPhone ? 16 : 24,
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(context, 'Your Library', docs.length),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.68,
                    ),
                    itemCount: docs.length,
                    itemBuilder: (context, i) =>
                        _savedCard(context, docs[i]),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );

    if (isDesktop) {
      return Row(
        children: [
          const AppSidebar(currentRoute: 'SavedBooks'),
          Expanded(child: body),
        ],
      );
    }
    return body;
  }

  Widget _sectionHeader(BuildContext context, String title, int count) {
    return Row(
      children: [
        Container(
          width: 4, height: 22,
          decoration: BoxDecoration(
            color: kYellow,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(title,
            style: GoogleFonts.interTight(
              fontSize: 20,
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

  Widget _savedCard(BuildContext context, QueryDocumentSnapshot doc) {
    final m = doc.data() as Map<String, dynamic>;
    final title = (m['bookTitle'] ?? 'Unknown').toString();
    final cover = (m['bookCover'] ?? '').toString();
    final code = (m['bookCode'] ?? '').toString();
    final author = (m['bookAuthor'] ?? '').toString();
    final type = (m['bookType'] ?? 'both').toString();

    Color badgeColor;
    IconData badgeIcon;
    String badgeText;
    if (type == 'digital') {
      badgeColor = kPurple;
      badgeIcon = Icons.tablet_mac_rounded;
      badgeText = 'DIGITAL';
    } else if (type == 'physical') {
      badgeColor = kBlue;
      badgeIcon = Icons.menu_book_rounded;
      badgeText = 'PHYSICAL';
    } else {
      badgeColor = kGreen;
      badgeIcon = Icons.auto_stories_rounded;
      badgeText = 'BOTH';
    }

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () async {
          final bookDoc = await FirebaseFirestore.instance
              .collection('books')
              .doc(m['bookId'])
              .get();
          if (!bookDoc.exists) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Book no longer available')),
            );
            return;
          }
          if (!context.mounted) return;
          context.pushNamed(
            DetailsWidget.routeName,
            queryParameters: {
              'books': serializeParam(
                  bookDoc.reference, ParamType.DocumentReference),
            }.withoutNulls,
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: FlutterFlowTheme.of(context).alternate.withOpacity(0.25),
            ),
            boxShadow: const [
              BoxShadow(
                blurRadius: 6,
                color: Color(0x0A000000),
                offset: Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 7,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        cover.isNotEmpty
                            ? Image.network(cover,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _placeholder(context))
                            : _placeholder(context),
                        Positioned(
                          top: 6, left: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: badgeColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(badgeIcon, color: Colors.white, size: 9),
                                const SizedBox(width: 3),
                                Text(badgeText,
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.4,
                                    )),
                              ],
                            ),
                          ),
                        ),
                        // Remove save button
                        Positioned(
                          top: 6, right: 6,
                          child: Material(
                            color: Colors.white,
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () async {
                                await doc.reference.delete();
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Removed'),
                                    backgroundColor: kBlue,
                                  ),
                                );
                              },
                              child: const SizedBox(
                                width: 26, height: 26,
                                child: Icon(Icons.close_rounded,
                                    size: 14, color: Colors.black87),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 2, 10, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.interTight(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                height: 1.15,
                                color:
                                    FlutterFlowTheme.of(context).primaryText,
                              )),
                          if (author.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(author,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w500,
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                )),
                          ],
                        ],
                      ),
                      if (code.isNotEmpty)
                        Text(code,
                            style: GoogleFonts.inter(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              color: kBlue.withOpacity(0.55),
                            )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      color: FlutterFlowTheme.of(context).alternate,
      alignment: Alignment.center,
      child: Icon(
        Icons.menu_book_rounded,
        size: 32,
        color: FlutterFlowTheme.of(context).secondaryText,
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
              width: 110, height: 110,
              decoration: BoxDecoration(
                color: kYellow.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.bookmark_border_rounded,
                  size: 56, color: kYellow),
            ),
            const SizedBox(height: 20),
            Text('No saved books yet',
                style: GoogleFonts.interTight(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: FlutterFlowTheme.of(context).primaryText,
                )),
            const SizedBox(height: 8),
            Text('Tap the bookmark icon on any book to save it here',
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

  Widget _errorState(BuildContext context, String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 56, color: Colors.red),
            const SizedBox(height: 16),
            Text('Could not load saved books',
                style: GoogleFonts.interTight(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: FlutterFlowTheme.of(context).primaryText,
                )),
          ],
        ),
      ),
    );
  }
}
