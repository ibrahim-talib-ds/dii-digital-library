import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/breakpoints.dart';
import '../../../core/colors.dart';
import '../../../core/constants.dart';
import '../../../core/result.dart';
import '../../../data/models/paginated.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/users_repository.dart';
import '../../layout/responsive_shell.dart';

class ManageLibrariansPage extends StatefulWidget {
  const ManageLibrariansPage({super.key});

  @override
  State<ManageLibrariansPage> createState() => _ManageLibrariansPageState();
}

class _ManageLibrariansPageState extends State<ManageLibrariansPage> {
  late Future<Ok<Paginated<User>>?> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = context
        .read<UsersRepository>()
        .list(role: 'librarian', size: 100)
        .then((r) => r is Ok<Paginated<User>> ? r : null);
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = DiiBreakpoints.isPhone(context);

    return ResponsiveShell(
      currentRoute: DiiRoutes.manageLibrarians,
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
              Text('Librarians',
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
                  Text('Staff Directory',
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

  Widget _body() {
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

        final librarians = ok.data.items;

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: DiiColors.yellow.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: DiiColors.yellow.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: DiiColors.yellow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.badge_rounded,
                        color: DiiColors.blue, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${librarians.length} ${librarians.length == 1 ? "librarian" : "librarians"}',
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
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: DiiColors.border),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < librarians.length; i++) ...[
                    _row(librarians[i]),
                    if (i < librarians.length - 1)
                      Divider(
                        height: 1,
                        color: DiiColors.border.withValues(alpha: 0.6),
                      ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _row(User u) {
    return Padding(
      padding: const EdgeInsets.all(16),
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
                fontSize: 17,
              ),
            ),
          ),
          const SizedBox(width: 14),
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
                const SizedBox(height: 3),
                Text(u.email,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: DiiColors.textSecondary,
                    )),
                const SizedBox(height: 3),
                Text('ID: ${u.studentNumber}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: DiiColors.textSecondary,
                    )),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: DiiColors.yellow,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text('LIBRARIAN',
                style: GoogleFonts.inter(
                  color: DiiColors.blue,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                )),
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
                color: DiiColors.yellow.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.badge_outlined,
                  size: 50, color: DiiColors.blue),
            ),
            const SizedBox(height: 20),
            Text('No librarians yet',
                style: GoogleFonts.interTight(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: DiiColors.blue,
                )),
            const SizedBox(height: 6),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'When a librarian account is created, they will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: DiiColors.textSecondary),
              ),
            ),
          ],
        ),
      );
}
