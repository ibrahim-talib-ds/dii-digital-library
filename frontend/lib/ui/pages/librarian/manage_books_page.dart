import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/breakpoints.dart';
import '../../../core/colors.dart';
import '../../../core/constants.dart';
import '../../../core/result.dart';
import '../../../data/models/book.dart';
import '../../../data/models/category.dart';
import '../../../data/models/paginated.dart';
import '../../../data/repositories/books_repository.dart';
import '../../../data/repositories/categories_repository.dart';
import '../../layout/responsive_shell.dart';

class ManageBooksPage extends StatefulWidget {
  const ManageBooksPage({super.key});

  @override
  State<ManageBooksPage> createState() => _ManageBooksPageState();
}

class _ManageBooksPageState extends State<ManageBooksPage> {
  final _searchCtrl = TextEditingController();
  String _search = '';
  String? _categoryFilter;
  late Future<Ok<Paginated<Book>>?> _future;
  List<Category> _categories = const [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _reload();
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

  void _reload() {
    _future = context
        .read<BooksRepository>()
        .list(
          search: _search.isEmpty ? null : _search,
          categoryId: _categoryFilter,
          size: 100,
        )
        .then((r) => r is Ok<Paginated<Book>> ? r : null);
  }

  Future<void> _openEditor({Book? existing}) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _BookEditorDialog(
        existing: existing,
        categories: _categories,
      ),
    );
    if (saved == true) setState(_reload);
  }

  Future<void> _delete(Book book) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: DiiColors.danger,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete_outline_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            const Text('Delete Book?'),
          ],
        ),
        content: Text(
          'Soft-delete "${book.title}" from the catalog? '
          'Borrow history stays intact.',
          style: const TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: DiiColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.delete_rounded, size: 16),
            label: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    final res = await context.read<BooksRepository>().delete(book.id);
    if (!mounted) return;
    switch (res) {
      case Ok():
        _snack('Deleted "${book.title}"', DiiColors.blue);
        setState(_reload);
      case Err(:final error):
        _snack(error.toString(), DiiColors.danger);
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = DiiBreakpoints.isPhone(context);

    return ResponsiveShell(
      currentRoute: DiiRoutes.manageBooks,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isPhone ? 14 : 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1300),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _pageHeader(isPhone),
                  const SizedBox(height: 20),
                  _toolbar(isPhone),
                  const SizedBox(height: 16),
                  _body(isPhone),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── header ───
  Widget _pageHeader(bool isPhone) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Manage Books',
                style: GoogleFonts.interTight(
                  fontSize: isPhone ? 22 : 28,
                  fontWeight: FontWeight.w900,
                  color: DiiColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text('Home',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: DiiColors.blue,
                        fontWeight: FontWeight.w600,
                      )),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(Icons.chevron_right_rounded,
                        size: 14, color: DiiColors.textSecondary),
                  ),
                  Text('Books Catalog',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: DiiColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      )),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => setState(_reload),
          icon: const Icon(Icons.refresh_rounded),
          color: DiiColors.blue,
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  // ─── toolbar: search + add ───
  Widget _toolbar(bool isPhone) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DiiColors.border),
      ),
      child: isPhone
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _searchField(),
                const SizedBox(height: 10),
                _addButton(),
              ],
            )
          : Row(
              children: [
                Expanded(child: _searchField()),
                const SizedBox(width: 12),
                _addButton(),
              ],
            ),
    );
  }

  Widget _searchField() {
    return TextField(
      controller: _searchCtrl,
      onChanged: (v) => setState(() {
        _search = v.trim();
        _reload();
      }),
      decoration: InputDecoration(
        hintText: 'Search books by title, author, or code',
        prefixIcon: const Icon(Icons.search_rounded, color: DiiColors.blue),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        suffixIcon: _search.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () {
                  _searchCtrl.clear();
                  setState(() {
                    _search = '';
                    _reload();
                  });
                },
              ),
      ),
    );
  }

  Widget _addButton() {
    return ElevatedButton.icon(
      onPressed: () => _openEditor(),
      icon: const Icon(Icons.add_rounded, size: 18),
      label: const Text('Add Book'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  // ─── body ───
  Widget _body(bool isPhone) {
    return FutureBuilder<Ok<Paginated<Book>>?>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(60),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final ok = snap.data;
        if (ok == null) return _error();
        if (ok.data.items.isEmpty) return _empty();

        return Column(
          children: [
            // counter strip
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: DiiColors.blue.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: DiiColors.blue.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: DiiColors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.menu_book_rounded,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${ok.data.total} ${ok.data.total == 1 ? "book" : "books"} in catalog',
                    style: GoogleFonts.interTight(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: DiiColors.blue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ─── classic table ───
            if (!isPhone) _desktopTable(ok.data.items)
            else Column(
              children: [
                for (final b in ok.data.items) ...[
                  _mobileCard(b),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ],
        );
      },
    );
  }

  // ─── desktop table ───
  Widget _desktopTable(List<Book> books) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DiiColors.border),
      ),
      child: Column(
        children: [
          // table header
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: DiiColors.blue.withValues(alpha: 0.04),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              border: Border(
                bottom: BorderSide(color: DiiColors.border),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 60), // cover space
                const SizedBox(width: 14),
                Expanded(
                  flex: 4,
                  child: Text('BOOK',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: DiiColors.textSecondary,
                        letterSpacing: 1.2,
                      )),
                ),
                Expanded(
                  flex: 2,
                  child: Text('CATEGORY',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: DiiColors.textSecondary,
                        letterSpacing: 1.2,
                      )),
                ),
                Expanded(
                  flex: 2,
                  child: Text('COPIES',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: DiiColors.textSecondary,
                        letterSpacing: 1.2,
                      )),
                ),
                SizedBox(
                  width: 100,
                  child: Text('ACTIONS',
                      textAlign: TextAlign.right,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: DiiColors.textSecondary,
                        letterSpacing: 1.2,
                      )),
                ),
              ],
            ),
          ),
          // rows
          for (var i = 0; i < books.length; i++) ...[
            _desktopRow(books[i]),
            if (i < books.length - 1)
              Divider(
                height: 1,
                color: DiiColors.border.withValues(alpha: 0.6),
              ),
          ],
        ],
      ),
    );
  }

  Widget _desktopRow(Book b) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _cover(b, 60, 90),
          const SizedBox(width: 14),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  b.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.interTight(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                    color: DiiColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  b.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: DiiColors.textSecondary,
                  ),
                ),
                if (b.bookCode != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: DiiColors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      b.bookCode!,
                      style: GoogleFonts.inter(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: DiiColors.blue,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: DiiColors.yellow.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: DiiColors.yellow.withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                b.categoryName ?? '—',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: DiiColors.blue,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: _copiesPill(b),
          ),
          SizedBox(
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _iconAction(
                  Icons.edit_outlined,
                  DiiColors.blue,
                  'Edit',
                  () => _openEditor(existing: b),
                ),
                const SizedBox(width: 4),
                _iconAction(
                  Icons.delete_outline_rounded,
                  DiiColors.danger,
                  'Delete',
                  () => _delete(b),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _copiesPill(Book b) {
    final out = b.isOut;
    final low = b.isLowStock;
    final color = out
        ? DiiColors.danger
        : low
            ? DiiColors.yellow
            : DiiColors.blue;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                out
                    ? Icons.block_rounded
                    : Icons.check_circle_rounded,
                size: 12,
                color: out ? DiiColors.danger : DiiColors.blue,
              ),
              const SizedBox(width: 5),
              Text(
                '${b.availableCopies} / ${b.totalCopies}',
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  color: out ? DiiColors.danger : DiiColors.blue,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _iconAction(
    IconData icon,
    Color color,
    String tooltip,
    VoidCallback onTap,
  ) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 18, color: color),
          ),
        ),
      ),
    );
  }

  // ─── mobile card ───
  Widget _mobileCard(Book b) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DiiColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cover(b, 56, 84),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  b.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.interTight(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: DiiColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(b.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: DiiColors.textSecondary,
                    )),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (b.bookCode != null)
                      _chip(b.bookCode!, DiiColors.blue),
                    if (b.categoryName != null)
                      _chip(b.categoryName!, DiiColors.yellow),
                    _chip('${b.availableCopies}/${b.totalCopies}',
                        DiiColors.blue),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              _iconAction(Icons.edit_outlined, DiiColors.blue, 'Edit',
                  () => _openEditor(existing: b)),
              const SizedBox(height: 6),
              _iconAction(Icons.delete_outline_rounded, DiiColors.danger,
                  'Delete', () => _delete(b)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String text, Color bg) {
    final isYellow = bg == DiiColors.yellow;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: isYellow ? 1 : 0.1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 9.5,
          fontWeight: FontWeight.w900,
          color: DiiColors.blue,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  // ─── cover ───
  Widget _cover(Book b, double w, double h) {
    return SizedBox(
      width: w, height: h,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: b.coverUrl != null && b.coverUrl!.isNotEmpty
            ? Image.network(
                b.coverUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _coverFallback(),
              )
            : _coverFallback(),
      ),
    );
  }

  Widget _coverFallback() => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [DiiColors.blue, DiiColors.deep],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Icon(Icons.menu_book_rounded,
            color: DiiColors.yellow, size: 22),
      );

  Widget _empty() => Container(
        padding: const EdgeInsets.all(60),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                color: DiiColors.blue.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.menu_book_outlined,
                  size: 50, color: DiiColors.blue.withValues(alpha: 0.4)),
            ),
            const SizedBox(height: 20),
            Text('No books yet',
                style: GoogleFonts.interTight(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: DiiColors.blue,
                )),
            const SizedBox(height: 6),
            const Text('Add your first book to get started',
                style: TextStyle(color: DiiColors.textSecondary)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _openEditor(),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add First Book'),
            ),
          ],
        ),
      );

  Widget _error() => Container(
        padding: const EdgeInsets.all(60),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 64, color: DiiColors.textDisabled),
            const SizedBox(height: 12),
            const Text('Could not load books'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => setState(_reload),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════
// Editor dialog — Add / Edit book
// ═══════════════════════════════════════════════════════════════════
class _BookEditorDialog extends StatefulWidget {
  const _BookEditorDialog({this.existing, required this.categories});
  final Book? existing;
  final List<Category> categories;

  @override
  State<_BookEditorDialog> createState() => _BookEditorDialogState();
}

class _BookEditorDialogState extends State<_BookEditorDialog> {
  final _title = TextEditingController();
  final _author = TextEditingController();
  final _code = TextEditingController();
  final _isbn = TextEditingController();
  // live-updates the barcode preview
  final _previewTick = ValueNotifier<int>(0);
  final _cover = TextEditingController();
  final _pdf = TextEditingController();
  final _pages = TextEditingController();
  final _total = TextEditingController(text: '1');
  final _desc = TextEditingController();

  String? _categoryId;
  bool _saving = false;

  bool get _isNew => widget.existing == null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _title.text = e.title;
      _author.text = e.author;
      _code.text = e.bookCode ?? '';
      _isbn.text = e.isbn ?? '';
      _cover.text = e.coverUrl ?? '';
      _pdf.text = e.pdfUrl ?? '';
      _pages.text = e.pages?.toString() ?? '';
      _total.text = e.totalCopies.toString();
      _desc.text = e.description ?? '';
      _categoryId = e.categoryId;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _author.dispose();
    _code.dispose();
    _isbn.dispose();
    _previewTick.dispose();
    _cover.dispose();
    _pdf.dispose();
    _pages.dispose();
    _total.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty || _author.text.trim().isEmpty) {
      _snack('Title and author are required');
      return;
    }

    setState(() => _saving = true);

    final body = <String, dynamic>{
      'title': _title.text.trim(),
      'author': _author.text.trim(),
      'book_code': _code.text.trim().isEmpty ? null : _code.text.trim(),
      'isbn': _isbn.text.trim().isEmpty ? null : _isbn.text.trim(),
      'cover_url': _cover.text.trim().isEmpty ? null : _cover.text.trim(),
      'pdf_url': _pdf.text.trim().isEmpty ? null : _pdf.text.trim(),
      'description': _desc.text.trim().isEmpty ? null : _desc.text.trim(),
      'pages': int.tryParse(_pages.text.trim()),
      'total_copies': int.tryParse(_total.text.trim()) ?? 1,
      'category_id': _categoryId,
    };

    final repo = context.read<BooksRepository>();
    final res = _isNew
        ? await repo.create(body)
        : await repo.update(widget.existing!.id, body);

    if (!mounted) return;
    switch (res) {
      case Ok():
        Navigator.pop(context, true);
      case Err(:final error):
        setState(() => _saving = false);
        _snack(error.toString());
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: DiiColors.danger),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 780),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ─── header ───
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 22, vertical: 18),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [DiiColors.blue, DiiColors.deep],
                ),
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: DiiColors.yellow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _isNew ? Icons.add_rounded : Icons.edit_rounded,
                      color: DiiColors.blue,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isNew ? 'Add New Book' : 'Edit Book',
                          style: GoogleFonts.interTight(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          _isNew
                              ? 'Fill in the details below'
                              : 'Update the book information',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded,
                        color: Colors.white),
                  ),
                ],
              ),
            ),

            // ─── form ───
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _sectionLabel('BASIC INFORMATION'),
                    const SizedBox(height: 10),
                    _field(_title, 'Title *', Icons.title_rounded),
                    _field(_author, 'Author *', Icons.person_outline_rounded),
                    Row(
                      children: [
                        Expanded(
                            child: _field(_code, 'Book Code',
                                Icons.tag_rounded)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _field(_isbn, 'ISBN',
                                Icons.qr_code_rounded)),
                      ],
                    ),

                    const SizedBox(height: 18),
                    _sectionLabel('CLASSIFICATION'),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String?>(
                      initialValue: _categoryId,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('— Select category —'),
                        ),
                        ...widget.categories.map(
                          (c) => DropdownMenuItem<String?>(
                            value: c.id,
                            child: Text(c.name),
                          ),
                        ),
                      ],
                      onChanged: (v) => setState(() => _categoryId = v),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                            child: _field(_total, 'Total Copies',
                                Icons.inventory_2_outlined,
                                numeric: true)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _field(_pages, 'Pages',
                                Icons.description_outlined,
                                numeric: true)),
                      ],
                    ),

                    const SizedBox(height: 16),
                    _BarcodePreview(
                      bookCode: _code.text,
                      totalCopies: int.tryParse(_total.text) ?? 0,
                    ),

                    const SizedBox(height: 18),
                    _sectionLabel('MEDIA & LINKS'),
                    const SizedBox(height: 10),
                    _field(_cover, 'Cover Image URL', Icons.image_outlined),
                    _field(_pdf, 'PDF URL', Icons.picture_as_pdf_outlined),

                    const SizedBox(height: 18),
                    _sectionLabel('DESCRIPTION'),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _desc,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText:
                            'Short summary shown on the book details page...',
                        alignLabelWithHint: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── actions ───
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: DiiColors.background,
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(18)),
                border: Border(
                  top: BorderSide(color: DiiColors.border),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving
                          ? null
                          : () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox(
                              width: 16, height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.5, color: Colors.white),
                            )
                          : const Icon(Icons.save_rounded, size: 18),
                      label: Text(_isNew ? 'Create Book' : 'Save Changes'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Row(
      children: [
        Container(
          width: 3, height: 14,
          decoration: BoxDecoration(
            color: DiiColors.yellow,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10.5,
            fontWeight: FontWeight.w900,
            color: DiiColors.blue,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _field(TextEditingController ctl, String label, IconData icon,
      {bool numeric = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctl,
        keyboardType: numeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Live barcode preview — shows generated copy codes CS-001-01 …
// ═══════════════════════════════════════════════════════════════
class _BarcodePreview extends StatelessWidget {
  const _BarcodePreview({
    required this.bookCode,
    required this.totalCopies,
  });

  final String bookCode;
  final int totalCopies;

  @override
  Widget build(BuildContext context) {
    final code = bookCode.trim().toUpperCase();

    // nothing to show until the librarian types a book code
    if (code.isEmpty) return const SizedBox.shrink();

    final count = totalCopies.clamp(0, 20);
    if (count == 0) return const SizedBox.shrink();

    // show up to 5 barcodes, wrap if needed
    final show = count > 5 ? 5 : count;
    final remaining = count - show;

    final codes = List.generate(
      show,
      (i) => '$code-${(i + 1).toString().padLeft(2, '0')}',
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7DB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DiiColors.yellow.withValues(alpha: 0.75)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: DiiColors.yellow,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Icon(Icons.qr_code_2_rounded,
                    size: 14, color: DiiColors.blue),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'BARCODE PREVIEW',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: DiiColors.blue,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Text(
                '$count ${count == 1 ? "copy" : "copies"}',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: DiiColors.blue.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'These will be assigned to each physical copy',
            style: TextStyle(
              fontSize: 10.5,
              color: DiiColors.textSecondary.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 12,
            children: [
              for (final c in codes) _BarcodeTile(code: c),
            ],
          ),
          if (remaining > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.more_horiz_rounded,
                    size: 14, color: DiiColors.blue),
                const SizedBox(width: 6),
                Text(
                  '+ $remaining more ${remaining == 1 ? "copy" : "copies"} will be generated',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: DiiColors.blue.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _BarcodeTile extends StatelessWidget {
  const _BarcodeTile({required this.code});
  final String code;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: DiiColors.blue.withValues(alpha: 0.15),
            ),
          ),
          child: SizedBox(
            width: 108,
            height: 40,
            child: CustomPaint(
              painter: _BarcodePainter(code),
              size: const Size(108, 40),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          code,
          style: GoogleFonts.inter(
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            color: DiiColors.blue,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

class _BarcodePainter extends CustomPainter {
  _BarcodePainter(this.code);
  final String code;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    // deterministic: use character codes of the string
    final bytes = code.codeUnits;
    int x = 2;
    int i = 0;
    while (x < size.width - 2) {
      final c = bytes[i % bytes.length];
      final wide = (c + i) % 3 == 0;
      final w = wide ? 3.0 : 1.5;
      canvas.drawRect(
        Rect.fromLTWH(x.toDouble(), 0, w, size.height - 10),
        paint,
      );
      final gap = 1.5 + ((c + i) % 3).toDouble();
      x += (w + gap).ceil();
      i++;
      if (i > 200) break;
    }
    final line = Paint()
      ..color = Colors.black
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, size.height - 6),
      Offset(size.width, size.height - 6),
      line,
    );
  }

  @override
  bool shouldRepaint(covariant _BarcodePainter old) => old.code != code;
}
