import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  String _filter = 'all'; // all | active | overdue | pending | returned

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
        if (ok == null) return _error();

        final all = ok.data;

        // counts
        final nAll = all.length;
        final nActive =
            all.where((b) => b.isActive && !b.isOverdue).length;
        final nOverdue = all.where((b) => b.isOverdue).length;
        final nPending = all.where((b) => b.isPending).length;
        final nReturned = all.where((b) => b.isReturned).length;

        // filtered
        final List<Borrowing> list;
        switch (_filter) {
          case 'active':
            list = all.where((b) => b.isActive && !b.isOverdue).toList();
            break;
          case 'overdue':
            list = all.where((b) => b.isOverdue).toList();
            break;
          case 'pending':
            list = all.where((b) => b.isPending).toList();
            break;
          case 'returned':
            list = all.where((b) => b.isReturned).toList();
            break;
          default:
            list = all;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── overdue summary strip ──
            if (nOverdue > 0) ...[
              _overdueStrip(nOverdue),
              const SizedBox(height: 14),
            ],

            // ── filter chips ──
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _chip('all', 'All', nAll, DiiColors.blue),
                  const SizedBox(width: 8),
                  _chip('active', 'Active', nActive, DiiColors.blue),
                  const SizedBox(width: 8),
                  _chip('overdue', 'Overdue', nOverdue, DiiColors.danger),
                  const SizedBox(width: 8),
                  _chip('pending', 'Pending', nPending, DiiColors.yellow),
                  const SizedBox(width: 8),
                  _chip('returned', 'Returned', nReturned, DiiColors.textSecondary),
                ],
              ),
            ),
            const SizedBox(height: 18),

            if (list.isEmpty)
              _emptyFiltered()
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) =>
                    BorrowingCard(borrowing: list[i]),
              ),
          ],
        );
      },
    );
  }

  // ─── overdue summary strip ───
  Widget _overdueStrip(int n) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DiiColors.danger.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DiiColors.danger.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: DiiColors.danger,
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(Icons.warning_amber_rounded,
                color: Colors.white, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You have $n overdue ${n == 1 ? "book" : "books"}',
                  style: GoogleFonts.interTight(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: DiiColors.danger,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Please return them as soon as possible',
                  style: TextStyle(
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

  // ─── filter chip ───
  Widget _chip(String value, String label, int count, Color accent) {
    final selected = _filter == value;
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => setState(() => _filter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? accent : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? accent : DiiColors.border,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: selected ? Colors.white : DiiColors.textPrimary,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: 0.25)
                    : DiiColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  color: selected ? Colors.white : DiiColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyFiltered() {
    // adapt text + icon to current filter
    final String title;
    final String subtitle;
    final IconData icon;
    final Color accent;
    final bool showBrowse;

    switch (_filter) {
      case 'overdue':
        title = 'Nothing overdue';
        subtitle = 'You\'re all caught up — great job!';
        icon = Icons.check_circle_rounded;
        accent = DiiColors.blue;
        showBrowse = false;
        break;
      case 'active':
        title = 'No active loans';
        subtitle = 'Request a book from the library to start reading.';
        icon = Icons.book_outlined;
        accent = DiiColors.blue;
        showBrowse = true;
        break;
      case 'pending':
        title = 'No pending requests';
        subtitle = 'Your requests will appear here once submitted.';
        icon = Icons.hourglass_empty_rounded;
        accent = DiiColors.yellow;
        showBrowse = true;
        break;
      case 'returned':
        title = 'No returned books';
        subtitle = 'Books you return will be kept here for your history.';
        icon = Icons.history_rounded;
        accent = DiiColors.textSecondary;
        showBrowse = false;
        break;
      default:
        title = 'Your shelf is empty';
        subtitle =
            'Browse the library and request your first book to get started.';
        icon = Icons.menu_book_rounded;
        accent = DiiColors.blue;
        showBrowse = true;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // icon in a soft circle with subtle yellow halo
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 32),
              ),
            ],
          ),
          const SizedBox(height: 26),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.interTight(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: DiiColors.blue,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                color: DiiColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
          if (showBrowse) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go(DiiRoutes.browse),
              icon: const Icon(Icons.search_rounded, size: 18),
              label: const Text('Browse Books'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
          ],
        ],
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
