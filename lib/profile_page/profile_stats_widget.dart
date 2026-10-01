import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Rich stats strip for the profile page.
/// Shows Active, Pending, Returned, Overdue.
class ProfileStatsWidget extends StatelessWidget {
  const ProfileStatsWidget({super.key});

  static const Color kBlue   = Color(0xFF0A1E5C);
  static const Color kYellow = Color(0xFFFFC107);
  static const Color kGreen  = Color(0xFF10B981);
  static const Color kRed    = Color(0xFFDC0F0F);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('borrowings')
          .where('userId', isEqualTo: currentUserUid)
          .snapshots(),
      builder: (context, snap) {
        int active = 0, pending = 0, returned = 0, overdue = 0;
        if (snap.hasData) {
          final now = DateTime.now();
          for (final d in snap.data!.docs) {
            final m = d.data() as Map<String, dynamic>;
            final s = (m['status'] ?? '').toString();
            if (s == 'pending') {
              pending++;
            } else if (s == 'returned') {
              returned++;
            } else if (s == 'borrowed' || s == 'approved') {
              final due = m['dueDate'] is Timestamp
                  ? (m['dueDate'] as Timestamp).toDate()
                  : null;
              if (due != null && due.isBefore(now)) {
                overdue++;
              } else {
                active++;
              }
            }
          }
        }

        return Column(
          children: [
            Row(
              children: [
                Expanded(child: _stat(context, 'Active', active, kGreen, Icons.book_rounded)),
                const SizedBox(width: 10),
                Expanded(child: _stat(context, 'Pending', pending, kYellow, Icons.hourglass_top_rounded)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _stat(context, 'Returned', returned, kBlue, Icons.assignment_turned_in_rounded)),
                const SizedBox(width: 10),
                Expanded(child: _stat(context, 'Overdue', overdue, kRed, Icons.warning_amber_rounded)),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _stat(BuildContext context, String label, int value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$value',
                    style: GoogleFonts.interTight(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: color,
                    )),
                Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: FlutterFlowTheme.of(context).secondaryText,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
