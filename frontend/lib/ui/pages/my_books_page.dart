import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/breakpoints.dart';
import '../../core/colors.dart';
import '../../core/constants.dart';
import '../../core/result.dart';
import '../../data/models/borrowing.dart';
import '../../data/repositories/borrowings_repository.dart';
import '../components/borrowing_card.dart';
import '../layout/responsive_shell.dart';

class MyBooksPage extends StatefulWidget {
  const MyBooksPage({super.key});

  @override
  State<MyBooksPage> createState() => _MyBooksPageState();
}

class _MyBooksPageState extends State<MyBooksPage> {
  late Future<Ok<List<Borrowing>>?> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = context
        .read<BorrowingsRepository>()
        .mine()
        .then((r) => r is Ok<List<Borrowing>> ? r : null);
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = DiiBreakpoints.isPhone(context);

    return ResponsiveShell(
      currentRoute: DiiRoutes.myBooks,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: DiiBreakpoints.pad(context),
                vertical: isPhone ? 16 : 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(isPhone),
                  const SizedBox(height: 20),
                  Expanded(child: _body()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(bool isPhone) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Books',
                style: GoogleFonts.interTight(
                  fontSize: isPhone ? 24 : 30,
                  fontWeight: FontWeight.w900,
                  color: DiiColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Your active loans and pending requests',
                style: TextStyle(
                  color: DiiColors.textSecondary,
                  fontSize: 13,
                ),
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
          return const Center(child: CircularProgressIndicator());
        }
        final ok = snap.data;
        if (ok == null) {
          return _error();
        }

        // Active = approved + overdue (still out), plus pending
        final active = ok.data
            .where((b) => b.isActive || b.isOverdue || b.isPending)
            .toList();

        if (active.isEmpty) return _empty();

        return ListView.separated(
          itemCount: active.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) => BorrowingCard(borrowing: active[i]),
        );
      },
    );
  }

  Widget _empty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96, height: 96,
              decoration: BoxDecoration(
                color: DiiColors.blue.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.book_outlined,
                  size: 48, color: DiiColors.blue.withValues(alpha: 0.4)),
            ),
            const SizedBox(height: 20),
            Text(
              'No active books',
              style: GoogleFonts.interTight(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: DiiColors.blue,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Request a book from the Browse page',
              style: TextStyle(color: DiiColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _error() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded,
              size: 64, color: DiiColors.textDisabled),
          const SizedBox(height: 12),
          const Text('Could not load your books'),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => setState(_reload),
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}
