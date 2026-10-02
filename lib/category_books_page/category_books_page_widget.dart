import '/backend/backend.dart';
import '/components/app_bottom_nav.dart';
import '/components/app_sidebar.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'category_books_page_model.dart';
import '/custom/book_card.dart';
export 'category_books_page_model.dart';

class CategoryBooksPageWidget extends StatefulWidget {
  const CategoryBooksPageWidget({
    super.key,
    required this.category,
  });

  final String? category;

  static String routeName = 'CategoryBooksPage';
  static String routePath = '/categoryBooksPage';

  @override
  State<CategoryBooksPageWidget> createState() =>
      _CategoryBooksPageWidgetState();
}

class _CategoryBooksPageWidgetState extends State<CategoryBooksPageWidget> {
  late CategoryBooksPageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const Color kBlue   = Color(0xFF0A1E5C);
  static const Color kDeep   = Color(0xFF081444);
  static const Color kYellow = Color(0xFFFFC107);
  static const Color kGreen  = Color(0xFF10B981);
  static const Color kRed    = Color(0xFFDC0F0F);

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CategoryBooksPageModel());
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
    final cols = isPhone ? 2 : (isTablet ? 3 : 4);

    final categoryName = widget.category ?? 'Books';

    final body = Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: kBlue,
              iconTheme: const IconThemeData(color: Colors.white),
              title: Text(categoryName,
                  style: GoogleFonts.interTight(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  )),
            ),
      bottomNavigationBar: isDesktop
          ? null
          : const AppBottomNav(currentRoute: 'CategoryBooksPage'),
      body: SafeArea(
        child: StreamBuilder<List<BooksRecord>>(
          stream: queryBooksRecord(
            queryBuilder: (q) => q.where('category', isEqualTo: categoryName),
          ),
          builder: (context, snap) {
            if (snap.hasError) return _error(context, snap.error.toString());
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final books = snap.data!;
            if (books.isEmpty) return _empty(context, categoryName);

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                  horizontal: isPhone ? 16 : 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [kBlue, kDeep],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            color: kYellow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.menu_book_rounded,
                              color: kBlue, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(categoryName,
                                  style: GoogleFonts.interTight(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  )),
                              const SizedBox(height: 4),
                              Text(
                                '${books.length} book${books.length == 1 ? "" : "s"} in this category',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Section title
                  Row(
                    children: [
                      Container(
                        width: 4, height: 20,
                        decoration: BoxDecoration(
                          color: kYellow,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('All Books',
                          style: GoogleFonts.interTight(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: FlutterFlowTheme.of(context).primaryText,
                          )),
                    ],
                  ),
                  const SizedBox(height: 14),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.62,
                    ),
                    itemCount: books.length,
                    itemBuilder: (context, i) => _card(context, books[i]),
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
          const AppSidebar(currentRoute: 'CategoryBooksPage'),
          Expanded(child: body),
        ],
      );
    }
    return body;
  }

  Widget _card(BuildContext context, BooksRecord book) {
    final total = book.totalCopies;
    final available = book.availableCopies;
    final isAvailable = available > 0;
    final isLow = available > 0 && available <= 2;

    Color badgeColor;
    IconData badgeIcon;
    String badgeText;
    if (!isAvailable) {
      badgeColor = kRed;
      badgeIcon = Icons.cancel_rounded;
      badgeText = 'All out';
    } else if (isLow) {
      badgeColor = kYellow;
      badgeIcon = Icons.access_time_rounded;
      badgeText = 'Few left';
    } else {
      badgeColor = kGreen;
      badgeIcon = Icons.check_circle_rounded;
      badgeText = 'Available';
    }

    return InkWell(
      onTap: () => context.pushNamed(
        DetailsWidget.routeName,
        queryParameters: {
          'books': serializeParam(book.reference, ParamType.DocumentReference),
        }.withoutNulls,
      ),
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
              flex: 5,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(book.coverUrl.isNotEmpty
                          ? book.coverUrl
                          : '',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: FlutterFlowTheme.of(context).alternate,
                        child: const Icon(Icons.menu_book_rounded, size: 40),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 4,
                            color: Color(0x33000000),
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(badgeIcon, color: Colors.white, size: 11),
                          const SizedBox(width: 4),
                          Text(badgeText,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.3,
                              )),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('$available / $total copies',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                          )),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(book.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.interTight(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                              color:
                                  FlutterFlowTheme.of(context).primaryText,
                            )),
                        if (book.author.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(book.author,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: FlutterFlowTheme.of(context)
                                    .secondaryText,
                              )),
                        ],
                      ],
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: isAvailable
                              ? kBlue.withOpacity(0.1)
                              : kRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          isAvailable ? 'View & Borrow' : 'Out of stock',
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                            color: isAvailable ? kBlue : kRed,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _empty(BuildContext context, String category) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                color: kBlue.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.menu_book_outlined,
                  size: 48, color: kBlue),
            ),
            const SizedBox(height: 20),
            Text('No books in $category yet',
                textAlign: TextAlign.center,
                style: GoogleFonts.interTight(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: FlutterFlowTheme.of(context).primaryText,
                )),
            const SizedBox(height: 8),
            Text('Check back soon or browse other categories',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: FlutterFlowTheme.of(context).secondaryText,
                )),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.pushNamed(BrowseBooksWidget.routeName),
              icon: const Icon(Icons.library_books_rounded),
              label: const Text('Browse All',
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

  Widget _error(BuildContext context, String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 56, color: kRed),
            const SizedBox(height: 16),
            Text('Could not load books',
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
