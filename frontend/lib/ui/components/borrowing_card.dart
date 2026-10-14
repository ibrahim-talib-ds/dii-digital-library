import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/colors.dart';
import '../../data/models/borrowing.dart';
import '../../data/models/enums.dart';

/// A single row in the "My Books" / "History" list.
/// Status pill, cover, title, due info.
class BorrowingCard extends StatelessWidget {
  const BorrowingCard({super.key, required this.borrowing});

  final Borrowing borrowing;

  @override
  Widget build(BuildContext context) {
    final status = _status(borrowing);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DiiColors.border, width: 1.1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── cover ───
          _cover(),
          const SizedBox(width: 14),

          // ─── info ───
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        borrowing.bookTitle ?? 'Untitled',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.interTight(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: DiiColors.textPrimary,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    status.pill,
                  ],
                ),
                if (borrowing.bookCode != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    borrowing.bookCode!,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: DiiColors.blue.withValues(alpha: 0.6),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Wrap(
                  spacing: 16,
                  runSpacing: 6,
                  children: [
                    _kv('Requested', _date(borrowing.requestedAt)),
                    if (borrowing.approvedAt != null)
                      _kv('Approved', _date(borrowing.approvedAt!)),
                    if (borrowing.dueAt != null)
                      _kv('Due', _date(borrowing.dueAt!),
                          accent: borrowing.isOverdue),
                    if (borrowing.returnedAt != null)
                      _kv('Returned', _date(borrowing.returnedAt!)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cover() {
    return SizedBox(
      width: 60,
      height: 88,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: borrowing.bookCover != null && borrowing.bookCover!.isNotEmpty
            ? Image.network(
                borrowing.bookCover!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _coverFallback(),
              )
            : _coverFallback(),
      ),
    );
  }

  Widget _coverFallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [DiiColors.blue, DiiColors.deep],
        ),
      ),
      child: const Icon(Icons.menu_book_rounded,
          color: DiiColors.yellow, size: 24),
    );
  }

  Widget _kv(String key, String value, {bool accent = false}) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$key: ',
            style: const TextStyle(
              fontSize: 11,
              color: DiiColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              fontSize: 11,
              color: accent ? DiiColors.danger : DiiColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  String _date(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';

  _Status _status(Borrowing b) {
    if (b.isOverdue) {
      return _Status('Overdue', DiiColors.danger, Icons.warning_amber_rounded);
    }
    switch (b.status) {
      case BorrowStatus.pending:
        return _Status('Pending', DiiColors.yellow, Icons.hourglass_top_rounded);
      case BorrowStatus.approved:
        return _Status('Active', DiiColors.blue, Icons.check_circle_rounded);
      case BorrowStatus.rejected:
        return _Status('Rejected', DiiColors.textDisabled, Icons.cancel_rounded);
      case BorrowStatus.returned:
        return _Status('Returned', DiiColors.blue, Icons.done_all_rounded);
      case BorrowStatus.overdue:
        return _Status('Overdue', DiiColors.danger, Icons.warning_amber_rounded);
      case BorrowStatus.cancelled:
        return _Status('Cancelled', DiiColors.textDisabled, Icons.block_rounded);
    }
  }
}

class _Status {
  final String label;
  final Color color;
  final IconData icon;

  _Status(this.label, this.color, this.icon);

  Widget get pill {
    final isYellow = color == DiiColors.yellow;
    final fg = isYellow ? DiiColors.blue : Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: fg),
          const SizedBox(width: 4),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              color: fg,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}
