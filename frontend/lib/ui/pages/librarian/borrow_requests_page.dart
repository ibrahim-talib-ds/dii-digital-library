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

class BorrowRequestsPage extends StatefulWidget {
  const BorrowRequestsPage({super.key});

  @override
  State<BorrowRequestsPage> createState() => _BorrowRequestsPageState();
}

class _BorrowRequestsPageState extends State<BorrowRequestsPage> {
  late Future<Ok<List<Borrowing>>?> _future;
  final Set<String> _busy = {};

  // cache users by id so we can show student info quickly
  final Map<String, User> _userCache = {};

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = context
        .read<BorrowingsRepository>()
        .listForStaff(status: 'pending')
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

  // ─── approve with days dialog ───
  Future<void> _approve(Borrowing b) async {
    final days = await _askDays(b);
    if (days == null) return;

    setState(() => _busy.add(b.id));
    final repo = context.read<BorrowingsRepository>();
    final res = await repo.approve(b.id, days: days);
    if (!mounted) return;
    setState(() {
      _busy.remove(b.id);
      _reload();
    });
    switch (res) {
      case Ok():
        _snack('Approved for $days days', DiiColors.blue);
      case Err(:final error):
        _snack(error.toString(), DiiColors.danger);
    }
  }

  Future<void> _reject(Borrowing b) async {
    // ask for reason first
    final reason = await _askRejectReason(b);
    if (reason == null) return;

    setState(() => _busy.add(b.id));
    final repo = context.read<BorrowingsRepository>();
    final res = await repo.reject(b.id);

    // if reason given, send it as a message
    if (reason.isNotEmpty && res is Ok) {
      await context.read<UsersRepository>().sendMessage(
            b.userId,
            title: 'Request declined',
            body: 'Your request for "${b.bookTitle}" was declined. Reason: $reason',
          );
    }

    if (!mounted) return;
    setState(() {
      _busy.remove(b.id);
      _reload();
    });
    switch (res) {
      case Ok():
        _snack('Rejected', DiiColors.blue);
      case Err(:final error):
        _snack(error.toString(), DiiColors.danger);
    }
  }

  // ─── message student ───
  Future<void> _messageStudent(Borrowing b, String studentName) async {
    final titleCtl = TextEditingController(text: 'About your request');
    final bodyCtl = TextEditingController(
        text: 'Regarding "${b.bookTitle}"...');

    final sent = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(
          children: [
            const Icon(Icons.message_rounded, color: DiiColors.blue),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Message to $studentName',
                style: GoogleFonts.interTight(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtl,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  prefixIcon: Icon(Icons.title_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bodyCtl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  alignLabelWithHint: true,
                ),
              ),
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
            icon: const Icon(Icons.send_rounded, size: 16),
            label: const Text('Send'),
          ),
        ],
      ),
    );

    if (sent != true) return;

    final res = await context.read<UsersRepository>().sendMessage(
          b.userId,
          title: titleCtl.text.trim(),
          body: bodyCtl.text.trim(),
        );
    if (!mounted) return;
    switch (res) {
      case Ok():
        _snack('Message sent to $studentName', DiiColors.blue);
      case Err(:final error):
        _snack(error.toString(), DiiColors.danger);
    }
  }

  Future<int?> _askDays(Borrowing b) async {
    final ctl = TextEditingController(text: '14');
    return showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: DiiColors.blue),
            const SizedBox(width: 10),
            Text('Approve Request',
                style: GoogleFonts.interTight(fontWeight: FontWeight.w900)),
          ],
        ),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dialogInfoRow('Student', b.studentName ?? '—',
                  Icons.person_outline_rounded),
              const SizedBox(height: 6),
              _dialogInfoRow('Book', b.bookTitle ?? '—',
                  Icons.menu_book_rounded),
              const SizedBox(height: 6),
              _dialogInfoRow('Code', b.bookCode ?? '—', Icons.tag_rounded),
              const SizedBox(height: 16),
              TextField(
                controller: ctl,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Loan duration (days)',
                  helperText: 'Default 14 · Min 1 · Max 90',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today_rounded),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              final n = int.tryParse(ctl.text.trim());
              if (n == null || n < 1 || n > 90) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(
                    content: Text('Enter a number between 1 and 90'),
                    backgroundColor: DiiColors.danger,
                  ),
                );
                return;
              }
              Navigator.pop(ctx, n);
            },
            icon: const Icon(Icons.check_rounded, size: 16),
            label: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  Future<String?> _askRejectReason(Borrowing b) async {
    final ctl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(
          children: [
            const Icon(Icons.cancel_rounded, color: DiiColors.danger),
            const SizedBox(width: 10),
            Text('Reject Request',
                style: GoogleFonts.interTight(fontWeight: FontWeight.w900)),
          ],
        ),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dialogInfoRow('Student', b.studentName ?? '—',
                  Icons.person_outline_rounded),
              const SizedBox(height: 6),
              _dialogInfoRow('Book', b.bookTitle ?? '—',
                  Icons.menu_book_rounded),
              const SizedBox(height: 16),
              TextField(
                controller: ctl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Reason (optional)',
                  helperText: 'Student will see this in their notification',
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(ctx, ctl.text.trim()),
            style: ElevatedButton.styleFrom(backgroundColor: DiiColors.danger),
            icon: const Icon(Icons.cancel_rounded, size: 16),
            label: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  Widget _dialogInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: DiiColors.textSecondary),
        const SizedBox(width: 8),
        Text('$label: ',
            style: const TextStyle(
              color: DiiColors.textSecondary,
              fontSize: 13,
            )),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: DiiColors.textPrimary,
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
      currentRoute: DiiRoutes.borrowRequests,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isPhone ? 14 : 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _pageHeader(isPhone),
                  const SizedBox(height: 20),
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
                'Borrow Requests',
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
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: Text('Home',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: DiiColors.blue,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(Icons.chevron_right_rounded,
                        size: 14, color: DiiColors.textSecondary),
                  ),
                  Text('Pending Requests',
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
        if (ok.data.isEmpty) return _empty();

        return Column(
          children: [
            // counter strip
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: DiiColors.yellow.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: DiiColors.yellow.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: DiiColors.yellow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.inbox_rounded,
                        color: DiiColors.blue, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${ok.data.length} pending ${ok.data.length == 1 ? "request" : "requests"}',
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
            for (final b in ok.data) ...[
              _requestCard(b),
              const SizedBox(height: 14),
            ],
          ],
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Individual request card — classic table-like layout
  // ═══════════════════════════════════════════════════════════════
  Widget _requestCard(Borrowing b) {
    final busy = _busy.contains(b.id);
    final isPhone = DiiBreakpoints.isPhone(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DiiColors.border, width: 1.2),
      ),
      child: Column(
        children: [
          // ── header strip ──
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 18, vertical: 12),
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
                  width: 8, height: 8,
                  decoration: const BoxDecoration(
                    color: DiiColors.yellow,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Request #${b.id.substring(0, 8).toUpperCase()}',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: DiiColors.blue,
                    letterSpacing: 0.8,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: DiiColors.yellow,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'PENDING',
                    style: GoogleFonts.inter(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      color: DiiColors.blue,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── content ──
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
                      // left: student
                      Expanded(flex: 5, child: _studentBlock(b)),
                      const SizedBox(width: 20),
                      // middle: book
                      Expanded(flex: 5, child: _bookBlock(b)),
                      const SizedBox(width: 20),
                      // right: actions
                      SizedBox(width: 200, child: _actionsBlock(b, busy)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ─── student info block ───
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
            Text('REQUESTED BY',
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
            const SizedBox(height: 10),
            Text(
              'Requested ${_date(b.requestedAt)}',
              style: const TextStyle(
                fontSize: 11,
                color: DiiColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
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

  // ─── book info block ───
  Widget _bookBlock(Borrowing b) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('BOOK REQUESTED',
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
            // small cover
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
                  if (b.notes != null && b.notes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      '"${b.notes}"',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontStyle: FontStyle.italic,
                        color: DiiColors.textSecondary,
                      ),
                    ),
                  ],
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

  // ─── actions block ───
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
            onPressed: busy ? null : () => _approve(b),
            icon: busy
                ? const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white),
                  )
                : const Icon(Icons.check_rounded, size: 18),
            label: const Text('Approve'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 42,
          child: OutlinedButton.icon(
            onPressed: busy ? null : () => _reject(b),
            icon: const Icon(Icons.cancel_rounded, size: 18),
            label: const Text('Reject'),
            style: OutlinedButton.styleFrom(
              foregroundColor: DiiColors.danger,
              side: const BorderSide(color: DiiColors.danger),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 42,
          child: TextButton.icon(
            onPressed: busy
                ? null
                : () => _messageStudent(b, b.studentName ?? 'student'),
            icon: const Icon(Icons.message_rounded, size: 16),
            label: const Text('Message'),
            style: TextButton.styleFrom(
              foregroundColor: DiiColors.blue,
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
              child: Icon(Icons.inbox_outlined,
                  size: 50, color: DiiColors.blue.withValues(alpha: 0.4)),
            ),
            const SizedBox(height: 20),
            Text('No pending requests',
                style: GoogleFonts.interTight(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: DiiColors.blue,
                )),
            const SizedBox(height: 6),
            const Text('All requests have been handled',
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
            const Text('Could not load requests'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => setState(_reload),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
}
