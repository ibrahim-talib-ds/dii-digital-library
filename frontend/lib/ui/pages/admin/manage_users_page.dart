import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/breakpoints.dart';
import '../../../core/colors.dart';
import '../../../core/constants.dart';
import '../../../core/result.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/paginated.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/users_repository.dart';
import '../../layout/responsive_shell.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  final _searchCtrl = TextEditingController();
  String _search = '';
  String? _roleFilter;
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
          role: _roleFilter,
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
                u.isBlocked ? Icons.lock_open_rounded : Icons.block_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Text(u.isBlocked ? 'Unblock User?' : 'Block User?'),
          ],
        ),
        content: Text(
          u.isBlocked
              ? 'Restore access for ${u.name}?'
              : 'Block ${u.name}? They will not be able to log in.',
          style: const TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: u.isBlocked ? DiiColors.blue : DiiColors.danger,
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

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = DiiBreakpoints.isPhone(context);

    return ResponsiveShell(
      currentRoute: DiiRoutes.manageUsers,
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
                  _toolbar(),
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

  Widget _pageHeader(bool isPhone) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('All Users',
                  style: GoogleFonts.interTight(
                    fontSize: isPhone ? 22 : 28,
                    fontWeight: FontWeight.w900,
                    color: DiiColors.textPrimary,
                    letterSpacing: -0.5,
                  )),
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
                  Text('User Directory',
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
        ),
      ],
    );
  }

  Widget _toolbar() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DiiColors.border),
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() {
              _search = v.trim();
              _reload();
            }),
            decoration: InputDecoration(
              hintText: 'Search by name, student number, or email',
              prefixIcon:
                  const Icon(Icons.search_rounded, color: DiiColors.blue),
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _roleChip(null, 'All'),
              _roleChip('student', 'Students'),
              _roleChip('librarian', 'Librarians'),
              _roleChip('admin', 'Admins'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _roleChip(String? role, String label) {
    final active = _roleFilter == role;
    return Material(
      color: active ? DiiColors.blue : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => setState(() {
          _roleFilter = role;
          _reload();
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
              fontSize: 12.5,
              fontWeight: active ? FontWeight.w800 : FontWeight.w600,
              color: active ? Colors.white : DiiColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

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
        if (ok == null || ok.data.items.isEmpty) return _empty();

        final users = ok.data.items;
        final blocked = users.where((u) => u.isBlocked).length;

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: DiiColors.blue.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: DiiColors.blue.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: DiiColors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.group_rounded,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${users.length} ${users.length == 1 ? "user" : "users"}',
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
                      child: Text(
                        '$blocked blocked',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (!isPhone)
              _desktopTable(users)
            else
              Column(
                children: [
                  for (final u in users) ...[
                    _mobileCard(u),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
          ],
        );
      },
    );
  }

  Widget _desktopTable(List<User> users) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DiiColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: DiiColors.blue.withValues(alpha: 0.04),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              border: Border(bottom: BorderSide(color: DiiColors.border)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 46 + 14),
                Expanded(
                    flex: 4,
                    child: _header('USER')),
                Expanded(
                    flex: 3,
                    child: _header('CONTACT')),
                Expanded(
                    flex: 2,
                    child: _header('ROLE')),
                SizedBox(
                  width: 100,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _header('ACTIONS'),
                  ),
                ),
              ],
            ),
          ),
          for (var i = 0; i < users.length; i++) ...[
            _desktopRow(users[i]),
            if (i < users.length - 1)
              Divider(
                height: 1,
                color: DiiColors.border.withValues(alpha: 0.6),
              ),
          ],
        ],
      ),
    );
  }

  Widget _header(String text) => Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: DiiColors.textSecondary,
          letterSpacing: 1.2,
        ),
      );

  Widget _desktopRow(User u) {
    final roleColor = switch (u.role) {
      UserRole.admin => DiiColors.blue,
      UserRole.librarian => DiiColors.yellow,
      UserRole.student => DiiColors.blue.withValues(alpha: 0.7),
    };
    final roleFg = u.role == UserRole.librarian ? DiiColors.blue : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: u.isBlocked ? DiiColors.textDisabled : roleColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              _initials(u.name),
              style: GoogleFonts.inter(
                color: u.isBlocked ? Colors.white : roleFg,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 14),
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
          Expanded(
            flex: 3,
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
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: roleColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                u.role.label.toUpperCase(),
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: roleFg,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Tooltip(
                  message: u.isBlocked ? 'Unblock' : 'Block',
                  child: Material(
                    color: (u.isBlocked ? DiiColors.blue : DiiColors.danger)
                        .withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => _toggleBlock(u),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          u.isBlocked
                              ? Icons.lock_open_rounded
                              : Icons.block_rounded,
                          size: 18,
                          color:
                              u.isBlocked ? DiiColors.blue : DiiColors.danger,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mobileCard(User u) {
    final roleColor = switch (u.role) {
      UserRole.admin => DiiColors.blue,
      UserRole.librarian => DiiColors.yellow,
      UserRole.student => DiiColors.blue.withValues(alpha: 0.7),
    };

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
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: u.isBlocked ? DiiColors.textDisabled : roleColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              _initials(u.name),
              style: GoogleFonts.inter(
                color: u.role == UserRole.librarian
                    ? DiiColors.blue
                    : Colors.white,
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
                  u.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.interTight(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: DiiColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${u.studentNumber}  ·  ${u.role.label}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: DiiColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Tooltip(
            message: u.isBlocked ? 'Unblock' : 'Block',
            child: Material(
              color: (u.isBlocked ? DiiColors.blue : DiiColors.danger)
                  .withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _toggleBlock(u),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    u.isBlocked ? Icons.lock_open_rounded : Icons.block_rounded,
                    size: 18,
                    color: u.isBlocked ? DiiColors.blue : DiiColors.danger,
                  ),
                ),
              ),
            ),
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
            Icon(Icons.group_outlined,
                size: 64, color: DiiColors.blue.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text('No users found',
                style: GoogleFonts.interTight(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: DiiColors.blue,
                )),
          ],
        ),
      );
}
