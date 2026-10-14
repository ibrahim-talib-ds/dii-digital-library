import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/breakpoints.dart';
import '../../core/colors.dart';
import '../../core/constants.dart';
import '../../core/result.dart';
import '../../data/models/book.dart';
import '../../data/models/category.dart';
import '../../data/models/paginated.dart';
import '../../data/repositories/books_repository.dart';
import '../../data/repositories/categories_repository.dart';
import '../components/book_card.dart';
import '../layout/responsive_shell.dart';

class BrowsePage extends StatefulWidget {
  const BrowsePage({super.key, this.initialCategory, this.initialSearch});

  final String? initialCategory;
  final String? initialSearch;

  @override
  State<BrowsePage> createState() => _BrowsePageState();
}

class _BrowsePageState extends State<BrowsePage> {
  final _searchCtrl = TextEditingController();

  String? _selectedCategory;
  String _search = '';
  bool _availableOnly = false;
  int _page = 1;
  static const _pageSize = 24;

  List<Category> _categories = const [];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _search = widget.initialSearch ?? '';
    _searchCtrl.text = _search;
    _loadCategories();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final res = await context.read<CategoriesRepository>().list();
    if (!mounted) return;
    if (res is Ok<List<Category>>) {
      setState(() => _categories = res.data);
    }
  }

  void _reset() {
    setState(() {
      _search = '';
      _searchCtrl.clear();
      _selectedCategory = null;
      _availableOnly = false;
      _page = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = DiiBreakpoints.isPhone(context);
    final isTablet = DiiBreakpoints.isTablet(context);

    return ResponsiveShell(
      currentRoute: DiiRoutes.browse,
      child: SafeArea(
        child: isPhone
            ? _phoneLayout()
            : _wideLayout(isTablet),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // WIDE — left filter column + main grid
  // ═══════════════════════════════════════════════════════════════
  Widget _wideLayout(bool isTablet) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── filters sidebar ──
              SizedBox(
                width: isTablet ? 220 : 260,
                child: _filterSidebar(),
              ),
              const SizedBox(width: 24),
              // ── main content ──
              Expanded(child: _mainContent()),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // PHONE — stacked
  // ═══════════════════════════════════════════════════════════════
  Widget _phoneLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _searchBar(),
          const SizedBox(height: 12),
          _categoryChips(),
          const SizedBox(height: 12),
          _availableToggle(),
          const SizedBox(height: 16),
          _grid(forPhone: true),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SIDEBAR — filters
  // ═══════════════════════════════════════════════════════════════
  Widget _filterSidebar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              Container(
                width: 4, height: 22,
                decoration: BoxDecoration(
                  color: DiiColors.yellow,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Browse Books',
                style: GoogleFonts.interTight(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: DiiColors.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── category filter card ──
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: DiiColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CATEGORY',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: DiiColors.textSecondary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              _categoryRadio(null, 'All Categories'),
              for (final cat in _categories)
                _categoryRadio(cat.id, cat.name),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ── availability filter card ──
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: DiiColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AVAILABILITY',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: DiiColors.textSecondary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              _availRadio(false, 'Show all books'),
              _availRadio(true, 'Available only'),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // reset button
        OutlinedButton.icon(
          onPressed: _reset,
          icon: const Icon(Icons.refresh_rounded, size: 16),
          label: const Text('Reset filters'),
        ),
      ],
    );
  }

  Widget _categoryRadio(String? id, String label) {
    final active = _selectedCategory == id;
    return InkWell(
      onTap: () => setState(() {
        _selectedCategory = id;
        _page = 1;
      }),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 18, height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: active ? DiiColors.blue : DiiColors.border,
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: active
                  ? Container(
                      width: 9, height: 9,
                      decoration: const BoxDecoration(
                        color: DiiColors.blue,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                  color: active ? DiiColors.blue : DiiColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _availRadio(bool value, String label) {
    final active = _availableOnly == value;
    return InkWell(
      onTap: () => setState(() {
        _availableOnly = value;
        _page = 1;
      }),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 18, height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: active ? DiiColors.blue : DiiColors.border,
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: active
                  ? Container(
                      width: 9, height: 9,
                      decoration: const BoxDecoration(
                        color: DiiColors.blue,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                  color: active ? DiiColors.blue : DiiColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // MAIN — search bar + grid
  // ═══════════════════════════════════════════════════════════════
  Widget _mainContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _searchBar(),
        const SizedBox(height: 20),
        _grid(),
      ],
    );
  }

  // ─── top search bar ───
  Widget _searchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DiiColors.border),
      ),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() {
          _search = v.trim();
          _page = 1;
        }),
        decoration: InputDecoration(
          hintText: 'Search by title, author, or code...',
          prefixIcon: const Icon(Icons.search_rounded, color: DiiColors.blue),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          suffixIcon: _search.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() {
                      _search = '';
                      _page = 1;
                    });
                  },
                ),
        ),
      ),
    );
  }

  // ─── category chips (phone only) ───
  Widget _categoryChips() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          if (i == 0) {
            final active = _selectedCategory == null;
            return _chip('All', active,
                () => setState(() {
                      _selectedCategory = null;
                      _page = 1;
                    }));
          }
          final cat = _categories[i - 1];
          final active = _selectedCategory == cat.id;
          return _chip(cat.name, active, () => setState(() {
                _selectedCategory = cat.id;
                _page = 1;
              }));
        },
      ),
    );
  }

  Widget _chip(String label, bool active, VoidCallback onTap) {
    return Material(
      color: active ? DiiColors.blue : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: active ? DiiColors.blue : DiiColors.border,
              width: 1.3,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: active ? FontWeight.w800 : FontWeight.w600,
              color: active ? Colors.white : DiiColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _availableToggle() {
    return InkWell(
      onTap: () => setState(() {
        _availableOnly = !_availableOnly;
        _page = 1;
      }),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _availableOnly
              ? DiiColors.blue.withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _availableOnly
                ? DiiColors.blue.withValues(alpha: 0.4)
                : DiiColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _availableOnly
                  ? Icons.check_circle_rounded
                  : Icons.check_circle_outline_rounded,
              size: 18,
              color: DiiColors.blue,
            ),
            const SizedBox(width: 8),
            Text(
              'Available only',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: DiiColors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── book grid ───
  Widget _grid({bool forPhone = false}) {
    final repo = context.read<BooksRepository>();
    final cols = forPhone
        ? 2
        : DiiBreakpoints.gridCols(context, phone: 2, tablet: 3, desktop: 4);

    return FutureBuilder<Ok<Paginated<Book>>?>(
      future: repo
          .list(
            search: _search.isEmpty ? null : _search,
            categoryId: _selectedCategory,
            availableOnly: _availableOnly ? true : null,
            page: _page,
            size: _pageSize,
          )
          .then((r) => r is Ok<Paginated<Book>> ? r : null),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final ok = snap.data;
        if (ok == null || ok.data.items.isEmpty) {
          return _emptyState();
        }
        final page = ok.data;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // result count
            Row(
              children: [
                Text(
                  '${page.total} ${page.total == 1 ? "book" : "books"} found',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: DiiColors.textSecondary,
                  ),
                ),
                const Spacer(),
                if (page.pages > 1)
                  Text(
                    'Page ${page.page} of ${page.pages}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: DiiColors.textSecondary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                crossAxisSpacing: 16,
                mainAxisSpacing: 20,
                childAspectRatio: 0.55,
              ),
              itemCount: page.items.length,
              itemBuilder: (context, i) => BookCard(
                book: page.items[i],
                width: double.infinity,
                onTap: () => context
                    .go('${DiiRoutes.bookDetails}/${page.items[i].id}'),
              ),
            ),
            if (page.pages > 1) ...[
              const SizedBox(height: 20),
              _pagination(page.pages),
            ],
          ],
        );
      },
    );
  }

  Widget _pagination(int totalPages) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: _page > 1
              ? () => setState(() => _page = _page - 1)
              : null,
          icon: const Icon(Icons.chevron_left_rounded),
          color: DiiColors.blue,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: DiiColors.blue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$_page / $totalPages',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ),
        IconButton(
          onPressed: _page < totalPages
              ? () => setState(() => _page = _page + 1)
              : null,
          icon: const Icon(Icons.chevron_right_rounded),
          color: DiiColors.blue,
        ),
      ],
    );
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.all(60),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: DiiColors.blue.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No books found',
            style: GoogleFonts.interTight(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: DiiColors.blue,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try changing your filters or search',
            style: TextStyle(color: DiiColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
