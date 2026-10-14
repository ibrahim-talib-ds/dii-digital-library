import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/breakpoints.dart';
import '../../../core/colors.dart';
import '../../../core/constants.dart';
import '../../../core/result.dart';
import '../../../data/models/borrowing.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/borrowings_repository.dart';
import '../../../data/repositories/users_repository.dart';
import '../../layout/responsive_shell.dart';

class ReceiveReturnPage extends StatefulWidget {
  const ReceiveReturnPage({super.key});

  @override
  State<ReceiveReturnPage> createState() => _ReceiveReturnPageState();
}

class _ReceiveReturnPageState extends State<ReceiveReturnPage> {
  late Future<Ok<List<Borrowing>>?> _future;
  final Set<String> _busy = {};
  final Map<String, User> _userCache = {};

  // search filter
  final _searchCtrl = TextEditingController();
  String _search = '';

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _reload() {
    _future = context
        .read<BorrowingsRepository>()
        .listForStaff(status: 'approved')
        .then((r) => r is Ok<List<Borrowing>> ? r : null);
  }

  Future<User?> _fetchUser(String userId) async {
    if (_userCache.containsKey(userId)) return _userCache[userId];
    final res = await context.read<UsersRepository>().get(userId);
    if (res is Ok<User>) {
      _userCache[userId] = res.data;
      return res.data;
    }
    return null;
  }

  // ─── mark returned with confirmation ───
  Future<void> _markReturned(Borrowing b) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: DiiColors.blue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.assignment_turned_in_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Confirm Return',
                style: GoogleFonts.interTight(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mark this book as returned to the library?',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 16),
              _dialogInfoRow('Student', b.studentName ?? '—',
                  Icons.person_outline_rounded),
              const SizedBox(height: 6),
              _dialogInfoRow('Book', b.bookTitle ?? '—',
                  Icons.menu_book_rounded),
              if (b.dueAt != null) ...[
                const SizedBox(height: 6),
                _dialogInfoRow('Due Date', _date(b.dueAt!),
                    Icons.calendar_today_rounded,
                    danger: b.isOverdue),
              ],
              if (b.isOverdue) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: DiiColors.danger.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: DiiColors.danger.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: DiiColors.danger, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'This book is ${_daysLate(b)} days late. '
                          'Consider sending a message to the student.',
                          style: TextStyle(
                            fontSize: 12,
                            color: DiiColors.danger,
                            height: 1.4,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.check_rounded, size: 16),
            label: const Text('Confirm Return'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _busy.add(b.id));
    final repo = context.read<BorrowingsRepository>();
    final res = await repo.markReturned(b.id);
    if (!mounted) return;
    setState(() {
      _busy.remove(b.id);
      _reload();
    });
    switch (res) {
      case Ok():
        _snack('Book returned. Inventory updated.', DiiColors.blue);
      case Err(:final error):
        _snack(error.toString(), DiiColors.danger);
    }
  }

  // ─── send reminder message ───
  Future<void> _remind(Borrowing b, String name) async {
    final bodyCtl = TextEditingController(
      text:
          'Hi $name, this is a reminder that "${b.bookTitle}" is overdue. '
          'Please return it to the library as soon as possible. Thank you.',
    );

    final send = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(
          children: [
            const Icon(Icons.notifications_active_rounded,
                color: DiiColors.blue),
            const SizedBox(width: 10),
            Text('Send Reminder',
                style: GoogleFonts.interTight(fontWeight: FontWeight.w900)),
          ],
        ),
        content: SizedBox(
          width: 480,
          child: TextField(
            controller: bodyCtl,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Message',
              alignLabelWithHint: true,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.send_rounded, size: 16),
            label: const Text('Send'),
          ),
        ],
      ),
    );

    if (send != true) return;

    final res = await context.read<UsersRepository>().sendMessage(
          b.userId,
          title: 'Overdue: ${b.bookTitle}',
          body: bodyCtl.text.trim(),
        );
    if (!mounted) return;
    switch (res) {
      case Ok():
        _snack('Reminder sent to $name', DiiColors.blue);
      case Err(:final error):
        _snack(error.toString(), DiiColors.danger);
    }
  }

  Widget _dialogInfoRow(String label, String value, IconData icon,
      {bool danger = false}) {
    return Row(
      children: [
        Icon(icon,
            size: 16,
            color: danger ? DiiColors.danger : DiiColors.textSecondary),
        const SizedBox(width: 8),
        Text('$label: ',
            style: TextStyle(
              color: danger ? DiiColors.danger : DiiColors.textSecondary,
              fontSize: 13,
            )),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: danger ? DiiColors.danger : DiiColors.textPrimary,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
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
      currentRoute: DiiRoutes.receiveReturn,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isPhone ? 14 : 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _pageHeader(isPhone),
                  const SizedBox(height: 20),
                  _searchBar(),
                  const SizedBox(height: 16),
                  _body(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _pageHeader(bool isPhone) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Receive Return',
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
                  Text('Books Currently Out',
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

  Widget _searchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DiiColors.border),
      ),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _search = v.trim().toLowerCase()),
        decoration: const InputDecoration(
          hintText: 'Search by student name, book title, or student number...',
          prefixIcon: Icon(Icons.search_rounded, color: DiiColors.blue),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          contentPadding: EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _body() {
    return FutureBuilder<Ok<List<Borrowing>>?>(
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

        // apply search filter
        var rows = ok.data;
        if (_search.isNotEmpty) {
          rows = rows.where((b) {
            final hay =
                '${b.studentName ?? ''} ${b.studentNumber ?? ''} ${b.bookTitle ?? ''} ${b.bookCode ?? ''}'
                    .toLowerCase();
            return hay.contains(_search);
          }).toList();
        }

        if (rows.isEmpty) return _empty();

        // overdue first
        rows.sort((a, b) {
          if (a.isOverdue && !b.isOverdue) return -1;
          if (!a.isOverdue && b.isOverdue) return 1;
          final ad = a.dueAt ?? DateTime(2100);
          final bd = b.dueAt ?? DateTime(2100);
          return ad.compareTo(bd);
        });

        final overdueCount = rows.where((r) => r.isOverdue).length;

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
                    child: const Icon(Icons.assignment_return_rounded,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${rows.length} ${rows.length == 1 ? "book" : "books"} currently out',
                      style: GoogleFonts.interTight(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: DiiColors.blue,
                      ),
                    ),
                  ),
                  if (overdueCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: DiiColors.danger,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: Colors.white, size: 14),
                          const SizedBox(width: 5),
                          Text(
                            '$overdueCount overdue',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            for (final b in rows) ...[
              _returnCard(b),
              const SizedBox(height: 14),
            ],
          ],
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // return card — 3-column classic layout
  // ═══════════════════════════════════════════════════════════════
  Widget _returnCard(Borrowing b) {
    final busy = _busy.contains(b.id);
    final overdue = b.isOverdue;
    final isPhone = DiiBreakpoints.isPhone(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: overdue
              ? DiiColors.danger.withValues(alpha: 0.4)
              : DiiColors.border,
          width: overdue ? 1.5 : 1.2,
        ),
      ),
      child: Column(
        children: [
          // header strip
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: overdue
                  ? DiiColors.danger.withValues(alpha: 0.05)
                  : DiiColors.blue.withValues(alpha: 0.04),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14)),
              border: Border(
                bottom: BorderSide(
                  color: overdue
                      ? DiiColors.danger.withValues(alpha: 0.2)
                      : DiiColors.border,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  overdue
                      ? Icons.warning_amber_rounded
                      : Icons.check_circle_rounded,
                  size: 16,
                  color: overdue ? DiiColors.danger : DiiColors.blue,
                ),
                const SizedBox(width: 8),
                Text(
                  overdue
                      ? 'OVERDUE RETURN'
                      : 'LOAN #${b.id.substring(0, 8).toUpperCase()}',
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    color: overdue ? DiiColors.danger : DiiColors.blue,
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: overdue ? DiiColors.danger : DiiColors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    overdue ? '${_daysLate(b)} DAYS LATE' : 'ON TIME',
                    style: GoogleFonts.inter(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // content
          Padding(
            padding: const EdgeInsets.all(18),
            child: isPhone
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _studentBlock(b),
                      const SizedBox(height: 18),
                      _bookBlock(b),
                      const SizedBox(height: 18),
                      _actionsBlock(b, busy),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 5, child: _studentBlock(b)),
                      const SizedBox(width: 20),
                      Expanded(flex: 5, child: _bookBlock(b)),
                      const SizedBox(width: 20),
                      SizedBox(width: 220, child: _actionsBlock(b, busy)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _studentBlock(Borrowing b) {
    return FutureBuilder<User?>(
      future: _fetchUser(b.userId),
      builder: (context, snap) {
        final u = snap.data;
        final name = u?.name ?? b.studentName ?? 'Student';
        final initials = _initials(name);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('BORROWED BY',
                style: GoogleFonts.inter(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                  color: DiiColors.textSecondary,
                  letterSpacing: 1.2,
                )),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  width: 46, height: 46,
                  decoration: const BoxDecoration(
                    color: DiiColors.blue,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initials,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.interTight(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: DiiColors.textPrimary,
                        ),
                      ),
                      Text(
                        b.studentNumber ?? '—',
                        style: const TextStyle(
                          fontSize: 12,
                          color: DiiColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (u != null) ...[
              _infoLine(Icons.email_outlined, u.email),
              if (u.department != null)
                _infoLine(Icons.school_outlined, u.department!),
              if (u.year != null)
                _infoLine(Icons.timeline_rounded, 'Year ${u.year}'),
            ],
          ],
        );
      },
    );
  }

  Widget _infoLine(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: DiiColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                color: DiiColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bookBlock(Borrowing b) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('BOOK TO RETURN',
            style: GoogleFonts.inter(
              fontSize: 9.5,
              fontWeight: FontWeight.w900,
              color: DiiColors.textSecondary,
              letterSpacing: 1.2,
            )),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52, height: 76,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: DiiColors.blue.withValues(alpha: 0.08),
                border: Border.all(color: DiiColors.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: b.bookCover != null && b.bookCover!.isNotEmpty
                  ? Image.network(
                      b.bookCover!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _bookFallback(),
                    )
                  : _bookFallback(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    b.bookTitle ?? 'Unknown',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.interTight(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: DiiColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (b.bookCode != null)
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
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: DiiColors.blue,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  // due date line
                  if (b.dueAt != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: b.isOverdue
                            ? DiiColors.danger.withValues(alpha: 0.08)
                            : DiiColors.blue.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 11,
                            color: b.isOverdue
                                ? DiiColors.danger
                                : DiiColors.blue,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Due ${_date(b.dueAt!)}',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: b.isOverdue
                                  ? DiiColors.danger
                                  : DiiColors.blue,
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
      ],
    );
  }

  Widget _bookFallback() => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [DiiColors.blue, DiiColors.deep],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Icon(Icons.menu_book_rounded,
            color: DiiColors.yellow, size: 24),
      );

  Widget _actionsBlock(Borrowing b, bool busy) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('ACTIONS',
            style: GoogleFonts.inter(
              fontSize: 9.5,
              fontWeight: FontWeight.w900,
              color: DiiColors.textSecondary,
              letterSpacing: 1.2,
            )),
        const SizedBox(height: 10),
        SizedBox(
          height: 42,
          child: ElevatedButton.icon(
            onPressed: busy ? null : () => _markReturned(b),
            icon: busy
                ? const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white),
                  )
                : const Icon(Icons.check_rounded, size: 18),
            label: const Text('Mark Returned'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 42,
          child: OutlinedButton.icon(
            onPressed: busy
                ? null
                : () => _remind(b, b.studentName ?? 'student'),
            icon: const Icon(Icons.notifications_active_rounded, size: 16),
            label: const Text('Send Reminder'),
            style: OutlinedButton.styleFrom(
              foregroundColor: DiiColors.blue,
              side: const BorderSide(color: DiiColors.blue, width: 1.3),
            ),
          ),
        ),
      ],
    );
  }

  String _date(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  int _daysLate(Borrowing b) {
    if (b.dueAt == null) return 0;
    final now = DateTime.now();
    return now.difference(b.dueAt!).inDays;
  }

  String _initials(String name) {
    final p = name.trim().split(RegExp(r'\s+'));
    if (p.isEmpty || p.first.isEmpty) return '?';
    if (p.length == 1) return p.first[0].toUpperCase();
    return (p.first[0] + p.last[0]).toUpperCase();
  }

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
              child: Icon(Icons.assignment_return_outlined,
                  size: 50, color: DiiColors.blue.withValues(alpha: 0.4)),
            ),
            const SizedBox(height: 20),
            Text('No books currently out',
                style: GoogleFonts.interTight(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: DiiColors.blue,
                )),
            const SizedBox(height: 6),
            const Text('All borrowed books have been returned',
                style: TextStyle(color: DiiColors.textSecondary)),
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
            const Text('Could not load returns'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => setState(_reload),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
}
