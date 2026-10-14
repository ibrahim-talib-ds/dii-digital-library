import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/breakpoints.dart';
import '../../../core/colors.dart';
import '../../../core/constants.dart';
import '../../../core/result.dart';
import '../../../data/models/borrowing.dart';
import '../../../data/models/paginated.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/borrowings_repository.dart';
import '../../../data/repositories/users_repository.dart';
import '../../layout/responsive_shell.dart';

class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key});

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  final _searchCtrl = TextEditingController();
  String _search = '';
  late Future<Ok<Paginated<User>>?> _future;

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
        .read<UsersRepository>()
        .list(
          role: 'student',
          search: _search.isEmpty ? null : _search,
          size: 100,
        )
        .then((r) => r is Ok<Paginated<User>> ? r : null);
  }

  Future<void> _toggleBlock(User u) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: u.isBlocked ? DiiColors.blue : DiiColors.danger,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                u.isBlocked
                    ? Icons.lock_open_rounded
                    : Icons.block_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Text(u.isBlocked ? 'Unblock Student?' : 'Block Student?'),
          ],
        ),
        content: Text(
          u.isBlocked
              ? 'Restore access for ${u.name}? They will be able to log in again.'
              : 'Block ${u.name}? They will not be able to log in until unblocked.',
          style: const TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  u.isBlocked ? DiiColors.blue : DiiColors.danger,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(u.isBlocked ? 'Unblock' : 'Block'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final repo = context.read<UsersRepository>();
    final res = u.isBlocked ? await repo.unblock(u.id) : await repo.block(u.id);
    if (!mounted) return;
    switch (res) {
      case Ok():
        _snack(u.isBlocked ? 'Unblocked' : 'Blocked', DiiColors.blue);
        setState(_reload);
      case Err(:final error):
        _snack(error.toString(), DiiColors.danger);
    }
  }

  Future<void> _showStudentProfile(User u) async {
    await showDialog(
      context: context,
      builder: (_) => _StudentProfileDialog(student: u),
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
      currentRoute: DiiRoutes.students,
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
                  _searchBar(),
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
                'Students',
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
                  Text('Students Directory',
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

  // ─── search bar ───
  Widget _searchBar() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DiiColors.border),
      ),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() {
          _search = v.trim();
          _reload();
        }),
        decoration: InputDecoration(
          hintText: 'Search by name, student number, or email',
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
      ),
    );
  }

  // ─── body ───
  Widget _body(bool isPhone) {
    return FutureBuilder<Ok<Paginated<User>>?>(
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

        final students = ok.data.items;
        final blocked = students.where((s) => s.isBlocked).length;

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
                    child: const Icon(Icons.people_rounded,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${students.length} ${students.length == 1 ? "student" : "students"}',
                    style: GoogleFonts.interTight(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: DiiColors.blue,
                    ),
                  ),
                  const Spacer(),
                  if (blocked > 0)
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
                          const Icon(Icons.block_rounded,
                              color: Colors.white, size: 12),
                          const SizedBox(width: 5),
                          Text(
                            '$blocked blocked',
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

            if (!isPhone) _desktopTable(students)
            else Column(
              children: [
                for (final s in students) ...[
                  _mobileCard(s),
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
  Widget _desktopTable(List<User> students) {
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
                const SizedBox(width: 46 + 14),
                Expanded(
                  flex: 4,
                  child: Text('STUDENT',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: DiiColors.textSecondary,
                        letterSpacing: 1.2,
                      )),
                ),
                Expanded(
                  flex: 3,
                  child: Text('CONTACT',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: DiiColors.textSecondary,
                        letterSpacing: 1.2,
                      )),
                ),
                Expanded(
                  flex: 2,
                  child: Text('PROGRAM',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: DiiColors.textSecondary,
                        letterSpacing: 1.2,
                      )),
                ),
                SizedBox(
                  width: 140,
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
          for (var i = 0; i < students.length; i++) ...[
            _desktopRow(students[i]),
            if (i < students.length - 1)
              Divider(
                height: 1,
                color: DiiColors.border.withValues(alpha: 0.6),
              ),
          ],
        ],
      ),
    );
  }

  Widget _desktopRow(User u) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          // avatar
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: u.isBlocked ? DiiColors.textDisabled : DiiColors.blue,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              _initials(u.name),
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // student info
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        u.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.interTight(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w900,
                          color: DiiColors.textPrimary,
                        ),
                      ),
                    ),
                    if (u.isBlocked) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: DiiColors.danger,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'BLOCKED',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  u.studentNumber,
                  style: const TextStyle(
                    fontSize: 12,
                    color: DiiColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // contact
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.email_outlined,
                        size: 12, color: DiiColors.textSecondary),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        u.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: DiiColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                if (u.phone != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.phone_outlined,
                          size: 12, color: DiiColors.textSecondary),
                      const SizedBox(width: 5),
                      Text(
                        u.phone!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: DiiColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // program
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (u.department != null)
                  Text(
                    u.department!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: DiiColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (u.year != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    'Year ${u.year}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: DiiColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // actions
          SizedBox(
            width: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _iconAction(
                  Icons.visibility_outlined,
                  DiiColors.blue,
                  'View profile',
                  () => _showStudentProfile(u),
                ),
                const SizedBox(width: 4),
                _iconAction(
                  u.isBlocked
                      ? Icons.lock_open_rounded
                      : Icons.block_rounded,
                  u.isBlocked ? DiiColors.blue : DiiColors.danger,
                  u.isBlocked ? 'Unblock' : 'Block',
                  () => _toggleBlock(u),
                ),
              ],
            ),
          ),
        ],
      ),
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
  Widget _mobileCard(User u) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: u.isBlocked
              ? DiiColors.danger.withValues(alpha: 0.3)
              : DiiColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: u.isBlocked ? DiiColors.textDisabled : DiiColors.blue,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              _initials(u.name),
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        u.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.interTight(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: DiiColors.textPrimary,
                        ),
                      ),
                    ),
                    if (u.isBlocked) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: DiiColors.danger,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('BLOCKED',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                            )),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  u.studentNumber,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: DiiColors.textSecondary,
                  ),
                ),
                if (u.department != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '${u.department}${u.year != null ? " · Year ${u.year}" : ""}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: DiiColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Column(
            children: [
              _iconAction(Icons.visibility_outlined, DiiColors.blue,
                  'View', () => _showStudentProfile(u)),
              const SizedBox(height: 4),
              _iconAction(
                u.isBlocked ? Icons.lock_open_rounded : Icons.block_rounded,
                u.isBlocked ? DiiColors.blue : DiiColors.danger,
                u.isBlocked ? 'Unblock' : 'Block',
                () => _toggleBlock(u),
              ),
            ],
          ),
        ],
      ),
    );
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
              child: Icon(Icons.people_outline_rounded,
                  size: 50, color: DiiColors.blue.withValues(alpha: 0.4)),
            ),
            const SizedBox(height: 20),
            Text('No students found',
                style: GoogleFonts.interTight(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: DiiColors.blue,
                )),
            const SizedBox(height: 6),
            const Text('Students appear here once they sign up',
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
            const Text('Could not load students'),
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
// Student profile dialog — shows info + borrow history
// ═══════════════════════════════════════════════════════════════════
class _StudentProfileDialog extends StatefulWidget {
  const _StudentProfileDialog({required this.student});
  final User student;

  @override
  State<_StudentProfileDialog> createState() => _StudentProfileDialogState();
}

class _StudentProfileDialogState extends State<_StudentProfileDialog> {
  late Future<Ok<List<Borrowing>>?> _history;

  @override
  void initState() {
    super.initState();
    _history = context
        .read<BorrowingsRepository>()
        .listForStaff()
        .then((r) => r is Ok<List<Borrowing>> ? r : null);
  }

  @override
  Widget build(BuildContext context) {
    final u = widget.student;

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 720),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // header
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
                    width: 52, height: 52,
                    decoration: const BoxDecoration(
                      color: DiiColors.yellow,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _initials(u.name),
                      style: GoogleFonts.inter(
                        color: DiiColors.blue,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          u.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.interTight(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'Student · ${u.studentNumber}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: u.isBlocked
                          ? DiiColors.danger
                          : DiiColors.yellow,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      u.isBlocked ? 'BLOCKED' : 'ACTIVE',
                      style: GoogleFonts.inter(
                        color: u.isBlocked ? Colors.white : DiiColors.blue,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded,
                        color: Colors.white),
                  ),
                ],
              ),
            ),

            // body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader('Contact'),
                    const SizedBox(height: 10),
                    _infoRow(Icons.email_outlined, 'Email', u.email),
                    if (u.phone != null) ...[
                      const SizedBox(height: 8),
                      _infoRow(Icons.phone_outlined, 'Phone', u.phone!),
                    ],
                    const SizedBox(height: 18),

                    _sectionHeader('Program'),
                    const SizedBox(height: 10),
                    _infoRow(Icons.school_outlined, 'Department',
                        u.department ?? '—'),
                    const SizedBox(height: 8),
                    _infoRow(Icons.timeline_rounded, 'Year',
                        u.year == null ? '—' : 'Year ${u.year}'),
                    const SizedBox(height: 8),
                    _infoRow(Icons.bookmark_outline_rounded, 'Borrow Limit',
                        '${u.borrowLimit} books'),
                    const SizedBox(height: 18),

                    _sectionHeader('Borrow History'),
                    const SizedBox(height: 12),
                    FutureBuilder<Ok<List<Borrowing>>?>(
                      future: _history,
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final ok = snap.data;
                        if (ok == null) {
                          return const Text('Could not load history',
                              style: TextStyle(color: DiiColors.textSecondary));
                        }
                        final rows = ok.data
                            .where((b) => b.userId == u.id)
                            .toList();

                        if (rows.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: DiiColors.background,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: DiiColors.border),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.history_rounded,
                                    color: DiiColors.blue
                                        .withValues(alpha: 0.4),
                                    size: 20),
                                const SizedBox(width: 10),
                                const Text(
                                  'No borrow history yet',
                                  style: TextStyle(
                                    color: DiiColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return Column(
                          children: [
                            for (final b in rows) ...[
                              _historyRow(b),
                              const SizedBox(height: 8),
                            ],
                          ],
                        );
                      },
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

  Widget _sectionHeader(String title) {
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
          title.toUpperCase(),
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

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: DiiColors.textSecondary),
        const SizedBox(width: 10),
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              color: DiiColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: DiiColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _historyRow(Borrowing b) {
    final isOverdue = b.isOverdue;
    final statusColor = isOverdue
        ? DiiColors.danger
        : b.isReturned
            ? DiiColors.blue
            : b.isPending
                ? DiiColors.yellow
                : DiiColors.blue;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isOverdue
              ? DiiColors.danger.withValues(alpha: 0.3)
              : DiiColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42, height: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: DiiColors.blue.withValues(alpha: 0.08),
            ),
            clipBehavior: Clip.antiAlias,
            child: b.bookCover != null && b.bookCover!.isNotEmpty
                ? Image.network(b.bookCover!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _miniFallback())
                : _miniFallback(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  b.bookTitle ?? 'Unknown',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.interTight(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: DiiColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${_label(b)} · ${b.days} days',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: DiiColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              b.status.name.toUpperCase(),
              style: GoogleFonts.inter(
                color: statusColor == DiiColors.yellow
                    ? DiiColors.blue
                    : Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniFallback() => Container(
        color: DiiColors.blue,
        child: const Icon(Icons.menu_book_rounded,
            color: DiiColors.yellow, size: 18),
      );

  String _label(Borrowing b) {
    if (b.returnedAt != null) return 'Returned ${_date(b.returnedAt!)}';
    if (b.dueAt != null) return 'Due ${_date(b.dueAt!)}';
    return 'Requested ${_date(b.requestedAt)}';
  }

  String _date(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month - 1]}';
  }

  String _initials(String name) {
    final p = name.trim().split(RegExp(r'\s+'));
    if (p.isEmpty || p.first.isEmpty) return '?';
    if (p.length == 1) return p.first[0].toUpperCase();
    return (p.first[0] + p.last[0]).toUpperCase();
  }
}
