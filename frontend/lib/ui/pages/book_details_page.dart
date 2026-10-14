import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/breakpoints.dart';
import '../../core/colors.dart';
import '../../core/constants.dart';
import '../../core/result.dart';
import '../../data/models/book.dart';
import '../../data/repositories/books_repository.dart';
import '../../data/repositories/borrowings_repository.dart';
import '../../data/repositories/saved_books_repository.dart';
import '../../state/auth_state.dart';
import '../layout/responsive_shell.dart';
import 'book_reader_page.dart';

class BookDetailsPage extends StatefulWidget {
  const BookDetailsPage({super.key, required this.bookId});

  final String bookId;

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  final _notesCtrl = TextEditingController();

  Book? _book;
  bool _loading = true;
  String? _error;

  bool _requesting = false;
  bool _alreadyRequested = false;
  bool _saved = false;
  bool _savingToggle = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final repo = context.read<BooksRepository>();
    final res = await repo.get(widget.bookId);
    if (!mounted) return;
    switch (res) {
      case Ok(:final data):
        setState(() {
          _book = data;
          _loading = false;
        });
      case Err(:final error):
        setState(() {
          _error = error.toString();
          _loading = false;
        });
    }
    _refreshSavedState();
  }

  Future<void> _refreshSavedState() async {
    final repo = context.read<SavedBooksRepository>();
    final res = await repo.list();
    if (!mounted) return;
    if (res is Ok<List<Book>>) {
      final isSaved = res.data.any((b) => b.id == widget.bookId);
      setState(() => _saved = isSaved);
    }
  }

  Future<void> _toggleSave() async {
    setState(() => _savingToggle = true);
    final repo = context.read<SavedBooksRepository>();
    final res = _saved
        ? await repo.unsave(widget.bookId)
        : await repo.save(widget.bookId);
    if (!mounted) return;
    setState(() => _savingToggle = false);
    switch (res) {
      case Ok():
        setState(() => _saved = !_saved);
        _snack(_saved ? 'Saved to your list' : 'Removed from saved',
            DiiColors.blue);
      case Err(:final error):
        _snack(error.toString(), DiiColors.danger);
    }
  }

  Future<void> _requestBook() async {
    final auth = context.read<AuthState>();
    if (!auth.isAuthenticated) {
      context.go(DiiRoutes.login);
      return;
    }
    if (auth.user?.isStaff ?? false) {
      _snack('Staff accounts cannot request books', DiiColors.blue);
      return;
    }

    final repo = context.read<BorrowingsRepository>();
    setState(() => _requesting = true);

    final res = await repo.request(
      bookId: widget.bookId,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _requesting = false);

    switch (res) {
      case Ok():
        setState(() => _alreadyRequested = true);
        _showSuccessDialog();
      case Err(:final error):
        _snack(error.toString(), DiiColors.danger);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: DiiColors.yellow,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.hourglass_top_rounded,
                  color: DiiColors.blue),
            ),
            const SizedBox(width: 12),
            Text('Request Sent',
                style: GoogleFonts.interTight(fontWeight: FontWeight.w900)),
          ],
        ),
        content: Text(
          'Your request for "${_book?.title}" is waiting for librarian approval. '
          'You will get a notification when it is reviewed.',
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go(DiiRoutes.myBooks);
            },
            child: const Text('View My Books'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go(DiiRoutes.browse);
            },
            child: const Text('Keep Browsing'),
          ),
        ],
      ),
    );
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }


  void _openReader() {
    final book = _book;
    if (book == null) return;
    final url = book.pdfUrl;
    if (url == null || url.isEmpty) {
      _snack('No PDF available for this book', DiiColors.danger);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BookReaderPage(
          title: book.title,
          pdfUrl: url,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const ResponsiveShell(
        currentRoute: DiiRoutes.browse,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null || _book == null) {
      return ResponsiveShell(
        currentRoute: DiiRoutes.browse,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded,
                    size: 64, color: DiiColors.danger),
                const SizedBox(height: 12),
                Text(_error ?? 'Book not found'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => context.go(DiiRoutes.browse),
                  child: const Text('Back to Browse'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final book = _book!;
    final isPhone = DiiBreakpoints.isPhone(context);
    final isTablet = DiiBreakpoints.isTablet(context);

    return ResponsiveShell(
      currentRoute: DiiRoutes.browse,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isPhone ? 14 : 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1300),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _breadcrumb(),
                  const SizedBox(height: 20),
                  isPhone
                      ? _phoneLayout(book)
                      : _wideLayout(book, isTablet),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── breadcrumb ───
  Widget _breadcrumb() {
    return Row(
      children: [
        InkWell(
          onTap: () => context.go(DiiRoutes.home),
          child: Text('Home',
              style: GoogleFonts.inter(
                fontSize: 12.5,
                color: DiiColors.blue,
                fontWeight: FontWeight.w600,
              )),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 6),
          child: Icon(Icons.chevron_right_rounded,
              size: 14, color: DiiColors.textSecondary),
        ),
        InkWell(
          onTap: () => context.go(DiiRoutes.browse),
          child: Text('Browse',
              style: GoogleFonts.inter(
                fontSize: 12.5,
                color: DiiColors.blue,
                fontWeight: FontWeight.w600,
              )),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 6),
          child: Icon(Icons.chevron_right_rounded,
              size: 14, color: DiiColors.textSecondary),
        ),
        Expanded(
          child: Text(
            _book!.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: DiiColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // WIDE — 3 columns: cover | info | request card
  // ═══════════════════════════════════════════════════════════════
  Widget _wideLayout(Book book, bool isTablet) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── cover ───
        SizedBox(
          width: isTablet ? 240 : 300,
          child: _coverCard(book),
        ),
        const SizedBox(width: 24),

        // ─── info ───
        Expanded(child: _infoCard(book)),
        const SizedBox(width: 24),

        // ─── request card ───
        SizedBox(
          width: isTablet ? 280 : 340,
          child: _requestCard(book),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // PHONE — stacked
  // ═══════════════════════════════════════════════════════════════
  Widget _phoneLayout(Book book) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: SizedBox(width: 200, child: _coverCard(book)),
        ),
        const SizedBox(height: 20),
        _infoCard(book),
        const SizedBox(height: 20),
        _requestCard(book),
      ],
    );
  }

  // ─── cover card ───
  Widget _coverCard(Book book) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DiiColors.border),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 2 / 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: book.coverUrl != null && book.coverUrl!.isNotEmpty
                  ? Image.network(
                      book.coverUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _fallbackCover(book),
                    )
                  : _fallbackCover(book),
            ),
          ),
          const SizedBox(height: 16),
          _availabilityBadge(book),
          if (book.copyIds.isNotEmpty) ...[
            const SizedBox(height: 14),
            _copiesSection(book),
          ],
        ],
      ),
    );
  }

  // ─── physical copies list ───
  Widget _copiesSection(Book book) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DiiColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: DiiColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.inventory_2_outlined,
                  size: 14, color: DiiColors.blue),
              const SizedBox(width: 6),
              Text(
                'PHYSICAL COPIES',
                style: GoogleFonts.inter(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                  color: DiiColors.blue,
                  letterSpacing: 1.1,
                ),
              ),
              const Spacer(),
              Text(
                '${book.copyIds.length}',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: DiiColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final copy in book.copyIds)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Container(
                    width: 6, height: 6,
                    decoration: BoxDecoration(
                      color: (copy['status'] ?? '') == 'available'
                          ? DiiColors.blue
                          : DiiColors.danger,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      copy['id'] as String? ?? '—',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: DiiColors.textPrimary,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  Text(
                    ((copy['status'] as String?) ?? 'available')
                        .toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      color: (copy['status'] ?? '') == 'available'
                          ? DiiColors.blue
                          : DiiColors.danger,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _fallbackCover(Book book) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [DiiColors.blue, DiiColors.deep],
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.menu_book_rounded,
              color: DiiColors.yellow, size: 32),
          Text(
            book.title,
            style: GoogleFonts.interTight(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 18,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _availabilityBadge(Book book) {
    final out = book.isOut;
    final color = out ? DiiColors.danger : DiiColors.blue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(
            out ? Icons.block_rounded : Icons.check_circle_rounded,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  out ? 'Not available' : 'Available for loan',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: color,
                  ),
                ),
                Text(
                  '${book.availableCopies} of ${book.totalCopies} on shelf',
                  style: const TextStyle(
                    fontSize: 11.5,
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

  // ─── info card ───
  Widget _infoCard(Book book) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DiiColors.border),
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // category pill
          if (book.categoryName != null)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: DiiColors.yellow,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                book.categoryName!.toUpperCase(),
                style: GoogleFonts.inter(
                  color: DiiColors.blue,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ),
          const SizedBox(height: 16),
          Text(
            book.title,
            style: GoogleFonts.interTight(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: DiiColors.textPrimary,
              height: 1.15,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person_outline_rounded,
                  size: 18, color: DiiColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                book.author,
                style: const TextStyle(
                  fontSize: 15,
                  color: DiiColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // meta grid
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              if (book.bookCode != null)
                _metaTile(Icons.tag_rounded, 'Code', book.bookCode!),
              if (book.isbn != null)
                _metaTile(Icons.qr_code_rounded, 'ISBN', book.isbn!),
              if (book.pages != null)
                _metaTile(Icons.description_outlined, 'Pages',
                    '${book.pages}'),
              if (book.language != null)
                _metaTile(Icons.language_rounded, 'Language',
                    book.language!.toUpperCase()),
            ],
          ),

          // description
          if (book.description != null && book.description!.isNotEmpty) ...[
            const SizedBox(height: 26),
            Row(
              children: [
                Container(
                  width: 4, height: 20,
                  decoration: BoxDecoration(
                    color: DiiColors.yellow,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Text('Description',
                    style: GoogleFonts.interTight(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: DiiColors.textPrimary,
                    )),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              book.description!,
              style: const TextStyle(
                fontSize: 14,
                height: 1.7,
                color: DiiColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _metaTile(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: DiiColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: DiiColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: DiiColors.blue),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: DiiColors.textSecondary,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: DiiColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── request card ───
  Widget _requestCard(Book book) {
    final auth = context.watch<AuthState>();
    final user = auth.user;
    final isStaff = user?.isStaff ?? false;
    final disabled =
        _requesting || _alreadyRequested || book.isOut || isStaff;

    String buttonLabel;
    if (isStaff) {
      buttonLabel = 'Staff cannot request';
    } else if (_alreadyRequested) {
      buttonLabel = 'Already Requested';
    } else if (book.isOut) {
      buttonLabel = 'Out of Stock';
    } else if (_requesting) {
      buttonLabel = 'Requesting...';
    } else {
      buttonLabel = 'Request this Book';
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DiiColors.border),
      ),
      child: Column(
        children: [
          // header
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: DiiColors.blue.withValues(alpha: 0.04),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14)),
              border: Border(
                bottom: BorderSide(color: DiiColors.border),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 4, height: 20,
                  decoration: BoxDecoration(
                    color: DiiColors.yellow,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Borrow Request',
                  style: GoogleFonts.interTight(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: DiiColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // student info (read-only)
                if (user != null && !isStaff) ...[
                  Text('YOUR DETAILS',
                      style: GoogleFonts.inter(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: DiiColors.textSecondary,
                        letterSpacing: 1.2,
                      )),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: DiiColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: DiiColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoLine(Icons.badge_outlined, user.studentNumber),
                        if (user.department != null)
                          _infoLine(Icons.school_outlined, user.department!),
                        if (user.year != null)
                          _infoLine(Icons.timeline_rounded,
                              'Year ${user.year}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                ],

                // notes
                Text('NOTES FOR LIBRARIAN (optional)',
                    style: GoogleFonts.inter(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      color: DiiColors.textSecondary,
                      letterSpacing: 1.2,
                    )),
                const SizedBox(height: 8),
                TextField(
                  controller: _notesCtrl,
                  maxLines: 3,
                  enabled: !disabled,
                  decoration: const InputDecoration(
                    hintText: 'Why do you need this book? Any notes?',
                    hintStyle: TextStyle(fontSize: 12.5),
                  ),
                ),
                const SizedBox(height: 16),

                // Save / bookmark button
                SizedBox(
                  height: 46,
                  child: OutlinedButton.icon(
                    onPressed: _savingToggle ? null : _toggleSave,
                    icon: _savingToggle
                        ? const SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: DiiColors.blue),
                          )
                        : Icon(
                            _saved
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_outline_rounded,
                            size: 18,
                            color: _saved
                                ? DiiColors.blue
                                : DiiColors.textSecondary,
                          ),
                    label: Text(
                      _saved ? 'Saved' : 'Save for Later',
                      style: TextStyle(
                        color: _saved
                            ? DiiColors.blue
                            : DiiColors.textPrimary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor:
                          _saved ? DiiColors.yellow.withValues(alpha: 0.15) : null,
                      side: BorderSide(
                        color: _saved
                            ? DiiColors.yellow
                            : DiiColors.border,
                        width: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // read pdf button (if available)
                if (book.pdfUrl != null && book.pdfUrl!.isNotEmpty) ...[
                  SizedBox(
                    height: 46,
                    child: OutlinedButton.icon(
                      onPressed: _openReader,
                      icon: const Icon(Icons.menu_book_rounded, size: 18),
                      label: const Text('Read PDF'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: DiiColors.blue,
                        side: const BorderSide(
                            color: DiiColors.blue, width: 1.4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // request button
                SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: disabled ? null : _requestBook,
                    icon: _requesting
                        ? const SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: Colors.white),
                          )
                        : Icon(
                            _alreadyRequested
                                ? Icons.check_rounded
                                : book.isOut
                                    ? Icons.block_rounded
                                    : Icons.bookmark_add_outlined,
                            size: 20,
                          ),
                    label: Text(buttonLabel),
                  ),
                ),

                const SizedBox(height: 12),

                // hints
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: DiiColors.yellow.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: DiiColors.yellow.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: DiiColors.blue, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'A librarian will review your request. '
                          'You will be notified when it is approved.',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: DiiColors.blue.withValues(alpha: 0.9),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoLine(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Icon(icon, size: 14, color: DiiColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                color: DiiColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
