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

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
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
      currentRoute: DiiRoutes.history,
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
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'History',
                              style: GoogleFonts.interTight(
                                fontSize: isPhone ? 24 : 30,
                                fontWeight: FontWeight.w900,
                                color: DiiColors.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Past loans and closed requests',
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
                      ),
                    ],
                  ),
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

  Widget _body() {
    return FutureBuilder<Ok<List<Borrowing>>?>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final ok = snap.data;
        if (ok == null) return _error();

        // History = returned + rejected + cancelled
        final past = ok.data
            .where((b) => b.isReturned || b.isRejected ||
                b.status.name == 'cancelled')
            .toList();

        if (past.isEmpty) return _empty();

        return ListView.separated(
          itemCount: past.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) => BorrowingCard(borrowing: past[i]),
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
              child: Icon(Icons.history_rounded,
                  size: 48, color: DiiColors.blue.withValues(alpha: 0.4)),
            ),
            const SizedBox(height: 20),
            Text(
              'No history yet',
              style: GoogleFonts.interTight(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: DiiColors.blue,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Returned and closed requests will appear here',
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
          const Text('Could not load history'),
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
