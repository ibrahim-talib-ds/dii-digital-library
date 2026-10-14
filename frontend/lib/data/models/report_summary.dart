class ReportSummary {
  final int totalBookTitles;
  final int totalCopies;
  final int availableCopies;
  final int totalUsers;
  final int totalStudents;
  final int activeLoans;
  final int pendingRequests;
  final int overdueLoans;
  final int returnedTotal;

  const ReportSummary({
    required this.totalBookTitles,
    required this.totalCopies,
    required this.availableCopies,
    required this.totalUsers,
    required this.totalStudents,
    required this.activeLoans,
    required this.pendingRequests,
    required this.overdueLoans,
    required this.returnedTotal,
  });

  factory ReportSummary.fromJson(Map<String, dynamic> j) {
    final books = j['books'] as Map<String, dynamic>? ?? {};
    final users = j['users'] as Map<String, dynamic>? ?? {};
    final loans = j['loans'] as Map<String, dynamic>? ?? {};
    return ReportSummary(
      totalBookTitles:  (books['titles'] as num?)?.toInt() ?? 0,
      totalCopies:      (books['total_copies'] as num?)?.toInt() ?? 0,
      availableCopies:  (books['available_copies'] as num?)?.toInt() ?? 0,
      totalUsers:       (users['total'] as num?)?.toInt() ?? 0,
      totalStudents:    (users['students'] as num?)?.toInt() ?? 0,
      activeLoans:      (loans['active'] as num?)?.toInt() ?? 0,
      pendingRequests:  (loans['pending'] as num?)?.toInt() ?? 0,
      overdueLoans:     (loans['overdue'] as num?)?.toInt() ?? 0,
      returnedTotal:    (loans['returned_total'] as num?)?.toInt() ?? 0,
    );
  }
}

class OverdueRow {
  final String borrowingId;
  final String userId;
  final String studentName;
  final String studentNumber;
  final String bookTitle;
  final DateTime? dueAt;
  final int daysOverdue;

  const OverdueRow({
    required this.borrowingId,
    required this.userId,
    required this.studentName,
    required this.studentNumber,
    required this.bookTitle,
    required this.daysOverdue,
    this.dueAt,
  });

  factory OverdueRow.fromJson(Map<String, dynamic> j) => OverdueRow(
        borrowingId:   j['borrowing_id'] as String,
        userId:        j['user_id'] as String,
        studentName:   j['student_name'] as String? ?? '',
        studentNumber: j['student_number'] as String? ?? '',
        bookTitle:     j['book_title'] as String? ?? '',
        dueAt:         j['due_at'] != null
            ? DateTime.tryParse(j['due_at'] as String)?.toLocal()
            : null,
        daysOverdue:   (j['days_overdue'] as num?)?.toInt() ?? 0,
      );
}

class PopularBook {
  final String bookId;
  final String title;
  final String author;
  final String? bookCode;
  final int borrowCount;

  const PopularBook({
    required this.bookId,
    required this.title,
    required this.author,
    required this.borrowCount,
    this.bookCode,
  });

  factory PopularBook.fromJson(Map<String, dynamic> j) => PopularBook(
        bookId:      j['book_id'] as String,
        title:       j['title'] as String,
        author:      j['author'] as String,
        bookCode:    j['book_code'] as String?,
        borrowCount: (j['borrow_count'] as num?)?.toInt() ?? 0,
      );
}
