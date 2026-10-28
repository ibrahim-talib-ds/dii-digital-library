import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/breakpoints.dart';
import '../../../core/colors.dart';
import '../../../core/result.dart';
import '../../../data/models/book.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/books_repository.dart';
import '../../../data/repositories/borrowings_repository.dart';
import '../../../data/repositories/users_repository.dart';
import '../../layout/responsive_shell.dart';

class IssueBookPage extends StatefulWidget {
  const IssueBookPage({super.key});

  @override
  State<IssueBookPage> createState() => _IssueBookPageState();
}

class _IssueBookPageState extends State<IssueBookPage> {
  // student
  final _studentCtl = TextEditingController();
  User? _student;
  bool _studentBusy = false;
  String? _studentError;

  // book
  final _bookCtl = TextEditingController();
  Book? _book;
  bool _bookBusy = false;
  String? _bookError;

  // issue
  final _daysCtl = TextEditingController(text: '14');
  bool _issuing = false;

  @override
  void dispose() {
    _studentCtl.dispose();
    _bookCtl.dispose();
    _daysCtl.dispose();
    super.dispose();
  }

  // ── lookup student by number ──
  Future<void> _findStudent() async {
    final q = _studentCtl.text.trim();
    if (q.isEmpty) return;
    setState(() {
      _studentBusy = true;
      _studentError = null;
      _student = null;
    });

    final repo = context.read<UsersRepository>();
    final res = await repo.list(search: q, role: 'student', size: 50);

    if (!mounted) return;
    setState(() => _studentBusy = false);

    switch (res) {
      case Ok(:final data):
        final items = data.items;
        if (items.isEmpty) {
          setState(() => _studentError = 'No student found');
          break;
        }
        final match = items.firstWhere(
          (u) => u.studentNumber == q,
          orElse: () => items.first,
        );
        setState(() => _student = match);
      case Err(:final error):
        setState(() => _studentError = error.toString());
    }
  }

  // ── lookup book by code ──
  Future<void> _findBook() async {
    final q = _bookCtl.text.trim();
    if (q.isEmpty) return;
    setState(() {
      _bookBusy = true;
      _bookError = null;
      _book = null;
    });

    final repo = context.read<BooksRepository>();
    final res = await repo.list(search: q, size: 50);

    if (!mounted) return;
    setState(() => _bookBusy = false);

    switch (res) {
      case Ok(:final data):
        final items = data.items;
        if (items.isEmpty) {
          setState(() => _bookError = 'No book found');
          break;
        }
        final ql = q.toLowerCase();
        final match = items.firstWhere(
          (b) => (b.bookCode ?? '').toLowerCase() == ql,
          orElse: () => items.first,
        );
        setState(() => _book = match);
      case Err(:final error):
        setState(() => _bookError = error.toString());
    }
  }

  // ── issue ──
  Future<void> _issue() async {
    if (_student == null || _book == null) return;
    final days = int.tryParse(_daysCtl.text.trim()) ?? 14;
    if (days < 1 || days > 90) {
      _snack('Days must be between 1 and 90', DiiColors.danger);
      return;
    }

    setState(() => _issuing = true);
    final repo = context.read<BorrowingsRepository>();
    final res = await repo.issue(
      studentNumber: _student!.studentNumber,
      bookCode: _book!.bookCode ?? '',
      days: days,
    );
    if (!mounted) return;
    setState(() => _issuing = false);

    switch (res) {
      case Ok():
        _snack('Issued "${_book!.title}" to ${_student!.name}',
            DiiColors.blue);
        setState(() {
          _student = null;
          _book = null;
          _studentCtl.clear();
          _bookCtl.clear();
          _daysCtl.text = '14';
        });
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
      currentRoute: '/issue-book',
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isPhone ? 14 : 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(),
                  const SizedBox(height: 20),
                  _card1(),
                  const SizedBox(height: 16),
                  _card2(),
                  const SizedBox(height: 16),
                  _card3(),
                  const SizedBox(height: 24),
                  _actions(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Issue Book',
            style: GoogleFonts.interTight(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: DiiColors.textPrimary,
              letterSpacing: -0.5,
            )),
        const SizedBox(height: 4),
        const Text(
          'Issue a physical book to a student at the counter',
          style: TextStyle(color: DiiColors.textSecondary, fontSize: 13),
        ),
      ],
    );
  }

  Widget _card1() {
    return _card(
      step: '1',
      title: 'Find Student',
      icon: Icons.person_search_rounded,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _studentCtl,
                  onSubmitted: (_) => _findStudent(),
                  decoration: const InputDecoration(
                    labelText: 'Student number',
                    hintText: 'e.g. 240023015',
                    prefixIcon: Icon(Icons.badge_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _studentBusy ? null : _findStudent,
                  icon: _studentBusy
                      ? const SizedBox(
                          width: 14, height: 14,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.search_rounded, size: 18),
                  label: const Text('Find'),
                ),
              ),
            ],
          ),
          if (_studentError != null) ...[
            const SizedBox(height: 10),
            _errorBox(_studentError!),
          ],
          if (_student != null) ...[
            const SizedBox(height: 12),
            _studentTile(_student!),
          ],
        ],
      ),
    );
  }

  Widget _card2() {
    return _card(
      step: '2',
      title: 'Find Book',
      icon: Icons.menu_book_rounded,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _bookCtl,
                  onSubmitted: (_) => _findBook(),
                  decoration: const InputDecoration(
                    labelText: 'Book code',
                    hintText: 'e.g. CS-001',
                    prefixIcon: Icon(Icons.qr_code_rounded),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _bookBusy ? null : _findBook,
                  icon: _bookBusy
                      ? const SizedBox(
                          width: 14, height: 14,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.search_rounded, size: 18),
                  label: const Text('Find'),
                ),
              ),
            ],
          ),
          if (_bookError != null) ...[
            const SizedBox(height: 10),
            _errorBox(_bookError!),
          ],
          if (_book != null) ...[
            const SizedBox(height: 12),
            _bookTile(_book!),
          ],
        ],
      ),
    );
  }

  Widget _card3() {
    return _card(
      step: '3',
      title: 'Loan Details',
      icon: Icons.calendar_today_rounded,
      body: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _daysCtl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Loan duration (days)',
                helperText: 'Min 1 · Max 90',
                prefixIcon: Icon(Icons.timelapse_rounded),
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actions() {
    final ready = _student != null && _book != null && !_issuing;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton.icon(
          onPressed: _issuing
              ? null
              : () => setState(() {
                    _student = null;
                    _book = null;
                    _studentCtl.clear();
                    _bookCtl.clear();
                    _studentError = null;
                    _bookError = null;
                    _daysCtl.text = '14';
                  }),
          icon: const Icon(Icons.clear_rounded, size: 18),
          label: const Text('Reset'),
        ),
        const SizedBox(width: 12),
        SizedBox(
          height: 48,
          child: ElevatedButton.icon(
            onPressed: ready ? _issue : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 28),
            ),
            icon: _issuing
                ? const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.check_circle_rounded, size: 18),
            label: Text(_issuing ? 'Issuing…' : 'Issue Book'),
          ),
        ),
      ],
    );
  }

  // ─── helpers ───
  Widget _card({
    required String step,
    required String title,
    required IconData icon,
    required Widget body,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
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
                width: 32, height: 32,
                decoration: const BoxDecoration(
                  color: DiiColors.blue, shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(step,
                    style: GoogleFonts.interTight(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    )),
              ),
              const SizedBox(width: 12),
              Icon(icon, size: 18, color: DiiColors.blue),
              const SizedBox(width: 8),
              Text(title,
                  style: GoogleFonts.interTight(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: DiiColors.textPrimary,
                  )),
            ],
          ),
          const SizedBox(height: 16),
          body,
        ],
      ),
    );
  }

  Widget _studentTile(User u) {
    final initials = _initials(u.name);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DiiColors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: DiiColors.blue.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: const BoxDecoration(
              color: DiiColors.blue, shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(initials,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                )),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(u.name,
                    style: GoogleFonts.interTight(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: DiiColors.textPrimary,
                    )),
                const SizedBox(height: 2),
                Text(
                  '${u.studentNumber} · ${u.department ?? "—"} · Year ${u.year ?? "—"}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: DiiColors.textSecondary,
                  ),
                ),
                Text(u.email,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: DiiColors.textSecondary,
                    )),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded,
              color: DiiColors.blue, size: 22),
        ],
      ),
    );
  }

  Widget _bookTile(Book b) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DiiColors.yellow.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: DiiColors.yellow.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 60,
            decoration: BoxDecoration(
              color: DiiColors.blue,
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.menu_book_rounded,
                color: DiiColors.yellow, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(b.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.interTight(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: DiiColors.textPrimary,
                    )),
                const SizedBox(height: 4),
                Text('Code: ${b.bookCode} · Author: ${b.author}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: DiiColors.textSecondary,
                    )),
                const SizedBox(height: 4),
                Text(
                  '${b.availableCopies} / ${b.totalCopies} copies available',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: b.availableCopies > 0
                        ? DiiColors.blue
                        : DiiColors.danger,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorBox(String msg) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DiiColors.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: DiiColors.danger.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: DiiColors.danger, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(msg,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: DiiColors.danger,
                )),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final p = name.trim().split(RegExp(r'\s+'));
    if (p.isEmpty) return '?';
    if (p.length == 1) return p.first[0].toUpperCase();
    return (p.first[0] + p.last[0]).toUpperCase();
  }
}
