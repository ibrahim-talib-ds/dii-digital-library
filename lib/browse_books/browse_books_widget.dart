import '/backend/backend.dart';
import '/components/app_bottom_nav.dart';
import '/components/app_sidebar.dart';
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
  const BrowseBooksWidget({
    super.key,
    this.filter,
  });

  final String? filter;

  static String routeName = 'BrowseBooks';
  static String routePath = '/browseBooks';

  @override
  State<BrowseBooksWidget> createState() => _BrowseBooksWidgetState();
}

class _BrowseBooksWidgetState extends State<BrowseBooksWidget> {
  late BrowseBooksModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const Color kBlue   = Color(0xFF0A1E5C);
  static const Color kDeep   = Color(0xFF081444);
  static const Color kYellow = Color(0xFFFFC107);
  static const Color kGreen  = Color(0xFF10B981);
  static const Color kRed    = Color(0xFFDC0F0F);
  static const Color kPurple = Color(0xFF7B1FA2);

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
              title: Text('Browse Books',
                  style: GoogleFonts.interTight(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  )),
            ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isPhone ? 14 : (isTablet ? 20 : 28),
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Search bar ───
              Container(
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: FlutterFlowTheme.of(context).alternate.withOpacity(0.3),
                  ),
                ),
                child: TextField(
                  controller: _searchCtl,
                  onChanged: (v) => setState(() => _query = v.trim()),
                  decoration: InputDecoration(
                    hintText: 'Search title, author, code, or category...',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: FlutterFlowTheme.of(context).secondaryText,
                    ),
                    prefixIcon: const Icon(Icons.search_rounded, color: kBlue),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchCtl.clear();
                              setState(() => _query = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ─── Category chips ───
              SizedBox(
                height: 38,
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
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: selected ? color : color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected ? color : color.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(cat['icon'] as IconData,
                                color: selected ? Colors.white : color,
                                size: 14),
                            const SizedBox(width: 5),
                            Text(cat['title'] as String,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
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
              const SizedBox(height: 20),

              // ─── Section title ───
              _sectionTitle(
                context,
                _query.isEmpty
                    ? (_activeCategory == 'All' ? 'All Books' : _activeCategory)
                    : 'Search Results',
              ),
              const SizedBox(height: 12),

              // ─── Books grid ───
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

                  // Availability filter (from home stat card)
                  // Availability filter removed (no more copy counts)

                  // Category filter
                  if (_activeCategory != 'All') {
                    books = books
                        .where((b) =>
                            b.category.toLowerCase() ==
                            _activeCategory.toLowerCase())
                        .toList();
                  }

                  // Text search
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
                      childAspectRatio: 0.68,
                    ),
                    itemCount: books.length,
                    itemBuilder: (context, i) =>
                        _bookCard(context, books[i], isPhone),
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );

    if (isDesktop) {
      return Row(
        children: [
          const AppSidebar(currentRoute: 'BrowseBooks'),
          Expanded(child: body),
        ],
      );
    }
    return body;
  }

  // ═══════════════════════════════════════════════════════════════
  Widget _sectionTitle(BuildContext context, String t) {
    return Row(
      children: [
        Container(
          width: 4, height: 18,
          decoration: BoxDecoration(
            color: kYellow,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(t,
            style: GoogleFonts.interTight(
              fontSize: 17,
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
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: kBlue.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_off_rounded, size: 36, color: kBlue),
            ),
            const SizedBox(height: 16),
            Text(msg,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: FlutterFlowTheme.of(context).secondaryText,
                )),
          ],
        ),
      ),
    );
  }

  Widget _bookCard(BuildContext context, BooksRecord book, bool isPhone) {
    return BookCard(book: book);
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      color: FlutterFlowTheme.of(context).alternate,
      alignment: Alignment.center,
      child: Icon(
        Icons.menu_book_rounded,
        size: 28,
        color: FlutterFlowTheme.of(context).secondaryText,
      ),
    );
  }
}
