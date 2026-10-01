import '/backend/backend.dart';
import '/components/app_bottom_nav.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'browse_books_model.dart';
import '/custom/book_card.dart';
export 'browse_books_model.dart';

class BrowseBooksWidget extends StatefulWidget {
  const BrowseBooksWidget({super.key});

  static String routeName = 'BrowseBooks';
  static String routePath = '/browseBooks';

  @override
  State<BrowseBooksWidget> createState() => _BrowseBooksWidgetState();
}

class _BrowseBooksWidgetState extends State<BrowseBooksWidget> {
  late BrowseBooksModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const Color kBlue    = Color(0xFF0A1E5C);
  static const Color kDeep    = Color(0xFF081444);
  static const Color kYellow  = Color(0xFFFFC107);

  final TextEditingController _searchCtl = TextEditingController();
  String _query = '';
  String _activeCategory = 'All';

  final List<Map<String, dynamic>> _categories = const [
    {'title': 'All', 'icon': Icons.apps_rounded, 'color': Color(0xFF0A1E5C)},
    {'title': 'Computer Science', 'icon': Icons.computer_rounded, 'color': Color(0xFF3B82F6)},
    {'title': 'Artificial Intelligence', 'icon': Icons.psychology_rounded, 'color': Color(0xFF7B1FA2)},
    {'title': 'Biotechnology', 'icon': Icons.biotech_rounded, 'color': Color(0xFF10B981)},
    {'title': 'Business Data Science', 'icon': Icons.insights_rounded, 'color': Color(0xFFFFC107)},
    {'title': 'Business Innovation', 'icon': Icons.lightbulb_rounded, 'color': Color(0xFFEF4444)},
    {'title': 'Mathematics', 'icon': Icons.calculate_rounded, 'color': Color(0xFF06B6D4)},
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BrowseBooksModel());
  }

  @override
  void dispose() {
    _searchCtl.dispose();
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isPhone = w < 600;
    final isTablet = w >= 600 && w < 1024;
    final cols = isPhone ? 2 : (isTablet ? 3 : 4);

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: kBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Browse Books',
            style: GoogleFonts.interTight(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            )),
      ),
      bottomNavigationBar: const AppBottomNav(currentRoute: 'BrowseBooks'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
              horizontal: isPhone ? 16 : 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Search bar ───
              TextField(
                controller: _searchCtl,
                onChanged: (v) => setState(() => _query = v.trim()),
                decoration: InputDecoration(
                  hintText: 'Search title, author, code or category...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchCtl.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color:
                          FlutterFlowTheme.of(context).alternate.withOpacity(0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color:
                          FlutterFlowTheme.of(context).alternate.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: kYellow, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ─── Category chips ───
              _title(context, 'Browse by Category'),
              const SizedBox(height: 10),
              SizedBox(
                height: 46,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final cat = _categories[i];
                    final selected = _activeCategory == cat['title'];
                    final color = cat['color'] as Color;
                    return InkWell(
                      onTap: () => setState(
                          () => _activeCategory = cat['title'] as String),
                      borderRadius: BorderRadius.circular(23),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected
                              ? color
                              : color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(23),
                          border: Border.all(
                            color: selected
                                ? color
                                : color.withOpacity(0.35),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(cat['icon'] as IconData,
                                color: selected ? Colors.white : color,
                                size: 16),
                            const SizedBox(width: 6),
                            Text(cat['title'] as String,
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: selected ? Colors.white : color,
                                )),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // ─── Books ───
              _title(context, _query.isEmpty
                  ? (_activeCategory == 'All'
                      ? 'All Books'
                      : _activeCategory)
                  : 'Search Results'),
              const SizedBox(height: 12),

              StreamBuilder<List<BooksRecord>>(
                stream: queryBooksRecord(),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  var books = snap.data!;

                  // Category filter
                  if (_activeCategory != 'All') {
                    books = books
                        .where((b) =>
                            b.category.toLowerCase() ==
                            _activeCategory.toLowerCase())
                        .toList();
                  }

                  // Text filter
                  if (_query.isNotEmpty) {
                    final q = _query.toLowerCase();
                    books = books.where((b) {
                      final hay =
                          '${b.title} ${b.author} ${b.bookCode} ${b.category}'
                              .toLowerCase();
                      return hay.contains(q);
                    }).toList();
                  }

                  if (books.isEmpty) {
                    return _emptyState(context, _query, _activeCategory);
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.62,
                    ),
                    itemCount: books.length,
                    itemBuilder: (context, i) => _bookCard(context, books[i]),
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  Widget _title(BuildContext context, String t) {
    return Row(
      children: [
        Container(
          width: 4, height: 20,
          decoration: BoxDecoration(
              color: kYellow, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 10),
        Text(t,
            style: GoogleFonts.interTight(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: FlutterFlowTheme.of(context).primaryText,
            )),
      ],
    );
  }

  Widget _emptyState(BuildContext context, String q, String cat) {
    final msg = q.isNotEmpty
        ? 'No results for "$q"'
        : (cat != 'All' ? 'No books in "$cat" yet' : 'No books available');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.search_off_rounded,
                size: 60,
                color: FlutterFlowTheme.of(context).secondaryText),
            const SizedBox(height: 12),
            Text(msg,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: FlutterFlowTheme.of(context).secondaryText,
                )),
          ],
        ),
      ),
    );
  }

  Widget _bookCard(BuildContext context, BooksRecord book) {
    final total = book.totalCopies;
    final available = book.availableCopies;
    final isAvail = available > 0;

    return InkWell(
      onTap: () => context.pushNamed(
        DetailsWidget.routeName,
        queryParameters: {
          'books': serializeParam(book.reference, ParamType.DocumentReference),
        }.withoutNulls,
      ),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: FlutterFlowTheme.of(context).alternate.withOpacity(0.25),
          ),
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
                    child: Image.network(
                      book.coverUrl.isNotEmpty
                          ? book.coverUrl
                          : 'https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=400',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: FlutterFlowTheme.of(context).alternate,
                        child: const Icon(Icons.menu_book_rounded, size: 40),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6, right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: isAvail ? kBlue : Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isAvail ? '$available/$total' : 'OUT',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(8),
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
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color:
                                  FlutterFlowTheme.of(context).primaryText,
                            )),
                        if (book.author.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(book.author,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                color: FlutterFlowTheme.of(context)
                                    .secondaryText,
                              )),
                        ],
                      ],
                    ),
                    if (book.bookCode.isNotEmpty)
                      Text(book.bookCode,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: FlutterFlowTheme.of(context).secondaryText,
                          )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
