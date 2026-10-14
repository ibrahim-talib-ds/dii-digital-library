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
import '../../data/models/report_summary.dart';
import '../../data/repositories/books_repository.dart';
import '../../data/repositories/categories_repository.dart';
import '../../data/repositories/reports_repository.dart';
import '../../state/auth_state.dart';
import '../components/book_card.dart';
import '../components/notification_bell.dart';
import '../layout/responsive_shell.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    final user = auth.user;
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isPhone = DiiBreakpoints.isPhone(context);
    final isTablet = DiiBreakpoints.isTablet(context);

    return ResponsiveShell(
      currentRoute: DiiRoutes.home,
      child: SafeArea(
        child: isPhone
            ? _phoneLayout(context, user.name)
            : _wideLayout(context, user.name, isTablet),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // WIDE (desktop / tablet) — main + right sidebar
  // ═══════════════════════════════════════════════════════════════
  Widget _wideLayout(BuildContext context, String name, bool isTablet) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── MAIN column ───
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _topBanner(name),
                    const SizedBox(height: 24),
                    _statsStrip(),
                    const SizedBox(height: 32),
                    _bookSections(),
                  ],
                ),
              ),
              // ─── SIDEBAR ───
              if (!isTablet) ...[
                const SizedBox(width: 24),
                SizedBox(
                  width: 300,
                  child: _sidebar(),
                ),
              ] else ...[
                const SizedBox(width: 20),
                SizedBox(
                  width: 240,
                  child: _sidebar(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // PHONE — stacked, no sidebar
  // ═══════════════════════════════════════════════════════════════
  Widget _phoneLayout(BuildContext context, String name) {
    return Column(
      children: [
        // ─── mobile top bar with brand + notification bell ───
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: const BoxDecoration(
            color: DiiColors.blue,
            boxShadow: [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: DiiColors.yellow,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(Icons.menu_book_rounded,
                      color: DiiColors.blue, size: 18),
                ),
                const SizedBox(width: 10),
                RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: 'DII ',
                      style: GoogleFonts.interTight(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text: 'Library',
                      style: GoogleFonts.interTight(
                        fontWeight: FontWeight.w900,
                        color: DiiColors.yellow,
                        fontSize: 16,
                      ),
                    ),
                  ]),
                ),
                const Spacer(),
                const NotificationBell(
                  iconColor: Colors.white,
                  iconSize: 22,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _topBanner(name, compact: true),
          const SizedBox(height: 18),
          _statsStrip(compact: true),
          const SizedBox(height: 24),
                _bookSections(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TOP BANNER — welcome + search
  // ═══════════════════════════════════════════════════════════════
  Widget _topBanner(String name, {bool compact = false}) {
    final auth = context.watch<AuthState>();
    final isStaff = auth.user?.isStaff ?? false;
    final roleLabel = auth.user?.role.label ?? 'User';

    return Container(
      padding: EdgeInsets.all(compact ? 20 : 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [DiiColors.blue, DiiColors.deep],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: DiiColors.blue.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: DiiColors.yellow,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  roleLabel.toUpperCase(),
                  style: GoogleFonts.inter(
                    color: DiiColors.blue,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const Spacer(),
              Icon(Icons.auto_stories_rounded,
                  color: Colors.white.withValues(alpha: 0.3),
                  size: compact ? 28 : 40),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Welcome back, $name',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.interTight(
              fontSize: compact ? 20 : 26,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.1,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isStaff
                ? 'Manage requests, books, and students'
                : 'Find your next book from the collection',
            style: TextStyle(
              fontSize: compact ? 12 : 13.5,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchCtrl,
              onSubmitted: (v) {
                final q = v.trim();
                if (q.isEmpty) return;
                context.go('${DiiRoutes.browse}?search=$q');
              },
              style: GoogleFonts.inter(
                fontSize: 14,
                color: DiiColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search by title, author, or code...',
                hintStyle: GoogleFonts.inter(
                  color: DiiColors.textDisabled,
                  fontSize: 13.5,
                ),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: DiiColors.blue, size: 22),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // STATS STRIP
  // ═══════════════════════════════════════════════════════════════
  Widget _statsStrip({bool compact = false}) {
    final repo = context.read<ReportsRepository>();

    return FutureBuilder<Ok<ReportSummary>?>(
      future: repo.summary().then((r) => r is Ok<ReportSummary> ? r : null),
      builder: (context, snap) {
        final s = snap.data?.data;
        final books = s?.totalBookTitles ?? 0;
        final available = s?.availableCopies ?? 0;
        final active = s?.activeLoans ?? 0;
        final overdue = s?.overdueLoans ?? 0;

        final items = [
          _Stat('Books', '$books', Icons.menu_book_rounded, DiiColors.blue),
          _Stat('Available', '$available', Icons.check_circle_rounded, DiiColors.yellow),
          _Stat('Active', '$active', Icons.book_rounded, DiiColors.blue),
          _Stat('Overdue', '$overdue', Icons.warning_amber_rounded, DiiColors.yellow),
        ];

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: items
              .map((it) => SizedBox(
                    width: compact ? (MediaQuery.sizeOf(context).width - 48) / 2 : 170,
                    child: _statCard(it),
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _statCard(_Stat s) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: s.color.withValues(alpha: 0.25),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: s.color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              s.icon,
              color: s.color == DiiColors.yellow ? DiiColors.blue : Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  s.value,
                  style: GoogleFonts.interTight(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: DiiColors.blue,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  s.label,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: DiiColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // BOOK SECTIONS — one per category
  // ═══════════════════════════════════════════════════════════════
  Widget _bookSections() {
    final repo = context.read<CategoriesRepository>();

    return FutureBuilder<Ok<List<Category>>?>(
      future: repo.list().then((r) => r is Ok<List<Category>> ? r : null),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ),
          );
        }
        final cats = snap.data?.data ?? const <Category>[];
        if (cats.isEmpty) return const SizedBox.shrink();

        return Column(
          children: [
            for (final cat in cats)
              Padding(
                padding: const EdgeInsets.only(bottom: 28),
                child: _categorySection(cat),
              ),
          ],
        );
      },
    );
  }

  Widget _categorySection(Category cat) {
    final repo = context.read<BooksRepository>();
    final isPhone = DiiBreakpoints.isPhone(context);
    final isAccent = DiiColors.categoryIsAccent[cat.slug] ?? false;
    final color = isAccent ? DiiColors.yellow : DiiColors.blue;
    final fg = isAccent ? DiiColors.blue : Colors.white;

    return FutureBuilder<Ok<Paginated<Book>>?>(
      future: repo
          .list(categoryId: cat.id, size: 12)
          .then((r) => r is Ok<Paginated<Book>> ? r : null),
      builder: (context, snap) {
        final ok = snap.data;
        if (ok == null || ok.data.items.isEmpty) {
          return const SizedBox.shrink();
        }
        final books = ok.data.items;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: DiiColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // header row
              Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_iconFor(cat.icon), color: fg, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          cat.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.interTight(
                            fontSize: isPhone ? 15 : 17,
                            fontWeight: FontWeight.w900,
                            color: DiiColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          '${books.length} ${books.length == 1 ? "book" : "books"}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: DiiColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => context
                        .go('${DiiRoutes.browse}?category=${cat.id}'),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: DiiColors.blue.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: DiiColors.blue.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'See all',
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: DiiColors.blue,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_rounded,
                              size: 14, color: DiiColors.blue),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 340,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: books.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, i) => BookCard(
                    book: books[i],
                    width: 175,
                    onTap: () => context
                        .go('${DiiRoutes.bookDetails}/${books[i].id}'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SIDEBAR — search + categories list
  // ═══════════════════════════════════════════════════════════════
  Widget _sidebar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sidebarSearchCard(),
        const SizedBox(height: 16),
        _sidebarCategoriesCard(),
      ],
    );
  }

  Widget _sidebarSearchCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DiiColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4, height: 18,
                decoration: BoxDecoration(
                  color: DiiColors.yellow,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Quick Search',
                style: GoogleFonts.interTight(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: DiiColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _sidebarLink(
            icon: Icons.library_books_rounded,
            label: 'All Books',
            onTap: () => context.go(DiiRoutes.browse),
          ),
          const SizedBox(height: 6),
          _sidebarLink(
            icon: Icons.check_circle_rounded,
            label: 'Available Now',
            onTap: () =>
                context.go('${DiiRoutes.browse}?available=true'),
          ),
          const SizedBox(height: 6),
          _sidebarLink(
            icon: Icons.book_rounded,
            label: 'My Books',
            onTap: () => context.go(DiiRoutes.myBooks),
          ),
          const SizedBox(height: 6),
          _sidebarLink(
            icon: Icons.history_rounded,
            label: 'History',
            onTap: () => context.go(DiiRoutes.history),
          ),
        ],
      ),
    );
  }

  Widget _sidebarCategoriesCard() {
    final repo = context.read<CategoriesRepository>();
    return FutureBuilder<Ok<List<Category>>?>(
      future: repo.list().then((r) => r is Ok<List<Category>> ? r : null),
      builder: (context, snap) {
        final cats = snap.data?.data ?? const <Category>[];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: DiiColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4, height: 18,
                    decoration: BoxDecoration(
                      color: DiiColors.yellow,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Categories',
                    style: GoogleFonts.interTight(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: DiiColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (final cat in cats)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: InkWell(
                    onTap: () => context
                        .go('${DiiRoutes.browse}?category=${cat.id}'),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            _iconFor(cat.icon),
                            size: 16,
                            color: DiiColors.blue,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              cat.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: DiiColors.textPrimary,
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded,
                              size: 16, color: DiiColors.textDisabled),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _sidebarLink({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 16, color: DiiColors.blue),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: DiiColors.textPrimary,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                size: 16, color: DiiColors.textDisabled),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String? name) => switch (name) {
        'computer' => Icons.computer_rounded,
        'psychology' => Icons.psychology_rounded,
        'biotech' => Icons.biotech_rounded,
        'insights' => Icons.insights_rounded,
        'lightbulb' => Icons.lightbulb_rounded,
        'calculate' => Icons.calculate_rounded,
        _ => Icons.menu_book_rounded,
      };
}

class _Stat {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  _Stat(this.label, this.value, this.icon, this.color);
}
