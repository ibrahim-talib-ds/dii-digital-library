import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/breakpoints.dart';
import '../../../core/colors.dart';
import '../../../core/constants.dart';
import '../../../core/result.dart';
import '../../../data/models/report_summary.dart';
import '../../../data/repositories/reports_repository.dart';
import '../../layout/responsive_shell.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  late Future<Ok<ReportSummary>?> _summary;
  late Future<Ok<List<OverdueRow>>?> _overdue;
  late Future<Ok<List<PopularBook>>?> _popular;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    final repo = context.read<ReportsRepository>();
    _summary = repo.summary().then((r) => r is Ok<ReportSummary> ? r : null);
    _overdue = repo.overdue().then((r) => r is Ok<List<OverdueRow>> ? r : null);
    _popular = repo.popular().then((r) => r is Ok<List<PopularBook>> ? r : null);
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = DiiBreakpoints.isPhone(context);

    return ResponsiveShell(
      currentRoute: DiiRoutes.reports,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
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
                              Text('Reports',
                                  style: GoogleFonts.interTight(
                                    fontSize: isPhone ? 24 : 30,
                                    fontWeight: FontWeight.w900,
                                    color: DiiColors.textPrimary,
                                    letterSpacing: -0.5,
                                  )),
                              const SizedBox(height: 4),
                              const Text('Library statistics and insights',
                                  style: TextStyle(
                                    color: DiiColors.textSecondary,
                                    fontSize: 13,
                                  )),
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
                    const SizedBox(height: 24),
                    _summaryCards(isPhone),
                    const SizedBox(height: 32),
                    _popularBlock(isPhone),
                    const SizedBox(height: 32),
                    _overdueBlock(isPhone),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _summaryCards(bool isPhone) {
    return FutureBuilder<Ok<ReportSummary>?>(
      future: _summary,
      builder: (context, snap) {
        final s = snap.data?.data;
        final cols = isPhone ? 2 : 4;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: cols,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: isPhone ? 1.55 : 1.9,
          children: [
            _statCard('Books', '${s?.totalBookTitles ?? 0}',
                Icons.menu_book_rounded, DiiColors.blue),
            _statCard('Copies', '${s?.totalCopies ?? 0}',
                Icons.layers_rounded, DiiColors.blue),
            _statCard('Available', '${s?.availableCopies ?? 0}',
                Icons.check_circle_rounded, DiiColors.yellow),
            _statCard('Users', '${s?.totalUsers ?? 0}',
                Icons.people_rounded, DiiColors.blue),
            _statCard('Students', '${s?.totalStudents ?? 0}',
                Icons.school_rounded, DiiColors.blue),
            _statCard('Active', '${s?.activeLoans ?? 0}',
                Icons.book_rounded, DiiColors.yellow),
            _statCard('Pending', '${s?.pendingRequests ?? 0}',
                Icons.hourglass_top_rounded, DiiColors.blue),
            _statCard('Overdue', '${s?.overdueLoans ?? 0}',
                Icons.warning_amber_rounded, DiiColors.danger),
          ],
        );
      },
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    final isDanger = color == DiiColors.danger;
    final isYellow = color == DiiColors.yellow;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: isDanger ? 0.5 : 0.2),
          width: 1.3,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon,
                color: isYellow ? DiiColors.blue : Colors.white, size: 20),
          ),
          const SizedBox(height: 10),
          Text(value,
              style: GoogleFonts.interTight(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: isDanger ? DiiColors.danger : DiiColors.blue,
                height: 1.0,
                letterSpacing: -0.5,
              )),
          const SizedBox(height: 4),
          Text(label,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: DiiColors.textSecondary,
              )),
        ],
      ),
    );
  }

  Widget _popularBlock(bool isPhone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Most Borrowed Books'),
        const SizedBox(height: 14),
        FutureBuilder<Ok<List<PopularBook>>?>(
          future: _popular,
          builder: (context, snap) {
            final items = snap.data?.data ?? const <PopularBook>[];
            if (items.isEmpty) {
              return _emptyBlock('No borrow data yet');
            }
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: DiiColors.border),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    _popularRow(i + 1, items[i]),
                    if (i < items.length - 1)
                      Divider(height: 1,
                          color: DiiColors.border.withValues(alpha: 0.6)),
                  ]
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _popularRow(int rank, PopularBook b) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: rank <= 3 ? DiiColors.yellow : DiiColors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text('$rank',
                style: GoogleFonts.interTight(
                  color: rank <= 3 ? DiiColors.blue : DiiColors.blue,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                )),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(b.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.interTight(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: DiiColors.textPrimary,
                    )),
                Text(b.author,
                    style: const TextStyle(
                      fontSize: 12,
                      color: DiiColors.textSecondary,
                    )),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: DiiColors.blue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('${b.borrowCount}×',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                )),
          ),
        ],
      ),
    );
  }

  Widget _overdueBlock(bool isPhone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Overdue Loans'),
        const SizedBox(height: 14),
        FutureBuilder<Ok<List<OverdueRow>>?>(
          future: _overdue,
          builder: (context, snap) {
            final items = snap.data?.data ?? const <OverdueRow>[];
            if (items.isEmpty) return _emptyBlock('No overdue books — nice!');
            return Column(
              children: [
                for (final row in items) ...[
                  _overdueRow(row),
                  const SizedBox(height: 10),
                ]
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _overdueRow(OverdueRow row) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: DiiColors.danger.withValues(alpha: 0.35),
          width: 1.3,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: DiiColors.danger,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(Icons.warning_amber_rounded,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(row.bookTitle,
                    style: GoogleFonts.interTight(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: DiiColors.textPrimary,
                    )),
                Text('${row.studentName} · ${row.studentNumber}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: DiiColors.textSecondary,
                    )),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: DiiColors.danger,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('${row.daysOverdue}d late',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                )),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4, height: 22,
          decoration: BoxDecoration(
            color: DiiColors.yellow,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(title,
            style: GoogleFonts.interTight(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: DiiColors.textPrimary,
              letterSpacing: -0.3,
            )),
      ],
    );
  }

  Widget _emptyBlock(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DiiColors.border),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              color: DiiColors.blue.withValues(alpha: 0.4), size: 22),
          const SizedBox(width: 12),
          Text(message,
              style: const TextStyle(
                color: DiiColors.textSecondary,
                fontSize: 13.5,
              )),
        ],
      ),
    );
  }
}
