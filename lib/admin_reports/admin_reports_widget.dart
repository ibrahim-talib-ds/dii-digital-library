import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'admin_reports_model.dart';
import '/components/responsive_shell.dart';
import '/custom/role_utils.dart';
export 'admin_reports_model.dart';

class AdminReportsWidget extends StatefulWidget {
  const AdminReportsWidget({super.key});

  static String routeName = 'AdminReports';
  static String routePath = '/adminReports';

  @override
  State<AdminReportsWidget> createState() => _AdminReportsWidgetState();
}

class _AdminReportsWidgetState extends State<AdminReportsWidget> {
  bool _roleChecked = false;

  late AdminReportsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const Color kBlue    = Color(0xFF0A1E5C);
  static const Color kDeep    = Color(0xFF081444);
  static const Color kYellow  = Color(0xFFFFC107);
  static const Color kRed     = Color(0xFFDC0F0F);
  static const Color kAccent   = Color(0xFF10B981);
  static const Color kPurple  = Color(0xFF7B1FA2);

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await loadCurrentUserRole();
      if (mounted) setState(() => _roleChecked = true);
    });
    _model = createModel(context, () => AdminReportsModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_roleChecked) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (!(isLibrarianUser() || isAdminUser())) return _accessDenied(context);
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: kBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Reports & Analytics',
            style: GoogleFonts.interTight(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            )),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('borrowings').snapshots(),
        builder: (context, bSnap) {
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('books').snapshots(),
            builder: (context, bkSnap) {
              return StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, uSnap) {
                  if (!bSnap.hasData ||
                      !bkSnap.hasData ||
                      !uSnap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return _buildContent(context, bSnap.data!, bkSnap.data!, uSnap.data!);
                },
              );
            },
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  Widget _buildContent(
    BuildContext context,
    QuerySnapshot borrowSnap,
    QuerySnapshot bookSnap,
    QuerySnapshot userSnap,
  ) {
    final borrows = borrowSnap.docs;
    final books = bookSnap.docs;
    final users = userSnap.docs;

    // ─── KPI counts ───
    int active = 0, overdue = 0, returned = 0, pending = 0;
    final now = DateTime.now();
    for (final d in borrows) {
      final m = d.data() as Map<String, dynamic>;
      final status = (m['status'] ?? '').toString();
      if (status == 'pending') pending++;
      else if (status == 'returned') returned++;
      else if (status == 'borrowed' || status == 'approved') {
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

    // Students / staff counts
    int students = 0, librarians = 0, admins = 0;
    for (final u in users) {
      final role = ((u.data() as Map)['role'] ?? 'student').toString();
      if (role == 'student') students++;
      else if (role == 'librarian') librarians++;
      else if (role == 'admin') admins++;
    }

    // ─── Book availability ───
    int totalCopies = 0, availableCopies = 0;
    for (final b in books) {
      final m = b.data() as Map<String, dynamic>;
      totalCopies += (m['totalCopies'] as num?)?.toInt() ?? 0;
      availableCopies += (m['availableCopies'] as num?)?.toInt() ?? 0;
    }

    // ─── Top borrowed books ───
    final bookCount = <String, int>{};
    final bookTitles = <String, String>{};
    for (final d in borrows) {
      final m = d.data() as Map<String, dynamic>;
      final id = (m['bookId'] ?? '').toString();
      if (id.isEmpty) continue;
      bookCount[id] = (bookCount[id] ?? 0) + 1;
      bookTitles[id] = (m['bookTitle'] ?? 'Unknown').toString();
    }
    final topBooks = bookCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // ─── Top students ───
    final userCount = <String, int>{};
    final userNames = <String, String>{};
    final userNums = <String, String>{};
    for (final d in borrows) {
      final m = d.data() as Map<String, dynamic>;
      final id = (m['userId'] ?? '').toString();
      if (id.isEmpty) continue;
      userCount[id] = (userCount[id] ?? 0) + 1;
      userNames[id] = (m['userName'] ?? 'Unknown').toString();
      userNums[id] = (m['studentNumber'] ?? '').toString();
    }
    final topStudents = userCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // ─── Overdue list ───
    final overdueList = borrows.where((d) {
      final m = d.data() as Map<String, dynamic>;
      if (m['status'] != 'borrowed' && m['status'] != 'approved') return false;
      final due = m['dueDate'] is Timestamp
          ? (m['dueDate'] as Timestamp).toDate()
          : null;
      return due != null && due.isBefore(now);
    }).toList();

    // ─── Category breakdown ───
    final catCount = <String, int>{};
    for (final b in books) {
      final m = b.data() as Map<String, dynamic>;
      final cat = (m['category'] ?? 'Other').toString();
      if (cat.isEmpty) continue;
      catCount[cat] = (catCount[cat] ?? 0) + 1;
    }
    final catList = catCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── KPI grid ───
          _section(context, 'Overview'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _kpi(context, 'Total Books', '${books.length}',
                  Icons.menu_book_rounded, kBlue),
              _kpi(context, 'Total Copies', '$totalCopies',
                  Icons.library_books_rounded, kBlue),
              _kpi(context, 'Available', '$availableCopies',
                  Icons.check_circle_rounded, kBlue),
              _kpi(context, 'Active Loans', '$active',
                  Icons.book_rounded, kBlue),
              _kpi(context, 'Pending', '$pending',
                  Icons.hourglass_top_rounded, kYellow),
              _kpi(context, 'Overdue', '$overdue',
                  Icons.warning_amber_rounded, kRed),
              _kpi(context, 'Returned', '$returned',
                  Icons.assignment_turned_in_rounded, kBlue),
              _kpi(context, 'Students', '$students',
                  Icons.people_rounded, kBlue),
              _kpi(context, 'Librarians', '$librarians',
                  Icons.badge_rounded, kPurple),
              _kpi(context, 'Admins', '$admins',
                  Icons.admin_panel_settings_rounded, kDeep),
            ],
          ),

          const SizedBox(height: 32),

          // ─── Top borrowed books ───
          _section(context, 'Most Borrowed Books'),
          const SizedBox(height: 10),
          if (topBooks.isEmpty)
            _empty(context, 'No borrowings yet')
          else
            Container(
              decoration: _cardDecoration(context),
              child: Column(
                children: [
                  for (int i = 0; i < topBooks.length && i < 10; i++)
                    _rankRow(
                      context,
                      rank: i + 1,
                      title: bookTitles[topBooks[i].key] ?? 'Unknown',
                      subtitle: '${topBooks[i].value} borrow(s)',
                      trailing: _bar(context, topBooks[i].value,
                          topBooks.first.value, kBlue),
                    ),
                ],
              ),
            ),

          const SizedBox(height: 32),

          // ─── Top students ───
          _section(context, 'Most Active Students'),
          const SizedBox(height: 10),
          if (topStudents.isEmpty)
            _empty(context, 'No student activity yet')
          else
            Container(
              decoration: _cardDecoration(context),
              child: Column(
                children: [
                  for (int i = 0; i < topStudents.length && i < 10; i++)
                    _rankRow(
                      context,
                      rank: i + 1,
                      title: userNames[topStudents[i].key] ?? 'Unknown',
                      subtitle:
                          '#${userNums[topStudents[i].key]} · ${topStudents[i].value} borrow(s)',
                      trailing: _bar(context, topStudents[i].value,
                          topStudents.first.value, kYellow),
                    ),
                ],
              ),
            ),

          const SizedBox(height: 32),

          // ─── Overdue ───
          _section(context, 'Overdue Books (${overdueList.length})'),
          const SizedBox(height: 10),
          if (overdueList.isEmpty)
            _empty(context, 'No overdue books 🎉')
          else
            Container(
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kRed.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  for (int i = 0; i < overdueList.length; i++)
                    _overdueRow(context, overdueList[i]),
                ],
              ),
            ),

          const SizedBox(height: 32),

          // ─── Categories ───
          _section(context, 'Books by Category'),
          const SizedBox(height: 10),
          if (catList.isEmpty)
            _empty(context, 'No categories')
          else
            Container(
              decoration: _cardDecoration(context),
              child: Column(
                children: [
                  for (final entry in catList)
                    _rankRow(
                      context,
                      rank: null,
                      title: entry.key,
                      subtitle: '${entry.value} book(s)',
                      trailing: _bar(context, entry.value,
                          catList.first.value, kBlue),
                    ),
                ],
              ),
            ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  Widget _section(BuildContext context, String title) {
    return Row(
      children: [
        Container(
          width: 4, height: 20,
          decoration: BoxDecoration(
            color: kYellow,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(title,
            style: GoogleFonts.interTight(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: FlutterFlowTheme.of(context).primaryText,
            )),
      ],
    );
  }

  BoxDecoration _cardDecoration(BuildContext context) {
    return BoxDecoration(
      color: FlutterFlowTheme.of(context).secondaryBackground,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: FlutterFlowTheme.of(context).alternate.withOpacity(0.2),
      ),
    );
  }

  Widget _kpi(BuildContext context, String label, String value,
      IconData icon, Color color) {
    return Container(
      width: 170,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(value,
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
                      color: FlutterFlowTheme.of(context).secondaryText,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _rankRow(BuildContext context,
      {int? rank,
      required String title,
      required String subtitle,
      required Widget trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          if (rank != null) ...[
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: rank == 1
                    ? kYellow
                    : rank == 2
                        ? Colors.grey.shade400
                        : rank == 3
                            ? const Color(0xFFB45309)
                            : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text('$rank',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: rank <= 3 ? Colors.white : Colors.black87,
                  )),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: FlutterFlowTheme.of(context).primaryText,
                    )),
                Text(subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: FlutterFlowTheme.of(context).secondaryText,
                    )),
              ],
            ),
          ),
          const SizedBox(width: 12),
          trailing,
        ],
      ),
    );
  }

  Widget _bar(BuildContext context, int value, int max, Color color) {
    final pct = max == 0 ? 0.0 : (value / max).clamp(0.0, 1.0);
    return SizedBox(
      width: 100,
      child: Stack(
        children: [
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          FractionallySizedBox(
            widthFactor: pct,
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _overdueRow(BuildContext context, QueryDocumentSnapshot doc) {
    final m = doc.data() as Map<String, dynamic>;
    final bookTitle = (m['bookTitle'] ?? 'Unknown').toString();
    final userName = (m['userName'] ?? 'Unknown').toString();
    final studentNum = (m['studentNumber'] ?? '').toString();
    final due = m['dueDate'] is Timestamp
        ? (m['dueDate'] as Timestamp).toDate()
        : null;

    int daysLate = 0;
    if (due != null) {
      daysLate = DateTime.now().difference(due).inDays;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: kRed.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.warning_amber_rounded,
                color: kRed, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bookTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: FlutterFlowTheme.of(context).primaryText,
                    )),
                Text('$userName · #$studentNum',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: FlutterFlowTheme.of(context).secondaryText,
                    )),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: kRed.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('${daysLate}d late',
                style: const TextStyle(
                  color: kRed,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                )),
          ),
        ],
      ),
    );
  }

  Widget _empty(BuildContext context, String msg) {
    return Container(
      width: double.infinity,
      decoration: _cardDecoration(context),
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Text(msg,
            style: TextStyle(
              color: FlutterFlowTheme.of(context).secondaryText,
            )),
      ),
    );
  }

  // ─── Access denied screen ───
  Widget _accessDenied(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline_rounded, size: 64, color: Colors.red.shade400),
              const SizedBox(height: 16),
              Text(
                'Access Denied',
                style: GoogleFonts.interTight(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: FlutterFlowTheme.of(context).primaryText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You do not have permission to view this page.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.safePop(),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
