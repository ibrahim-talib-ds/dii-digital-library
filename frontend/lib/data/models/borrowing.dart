import 'enums.dart';

class Borrowing {
  final String id;
  final String userId;
  final String bookId;
  final BorrowStatus status;
  final int days;
  final String? notes;
  final DateTime requestedAt;
  final DateTime? approvedAt;
  final String? approvedBy;
  final DateTime? rejectedAt;
  final DateTime? dueAt;
  final DateTime? returnedAt;
  final double fine;

  // hydrated
  final String? bookTitle;
  final String? bookCover;
  final String? bookCode;
  final String? studentName;
  final String? studentNumber;

  const Borrowing({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.status,
    required this.days,
    required this.requestedAt,
    required this.fine,
    this.notes,
    this.approvedAt,
    this.approvedBy,
    this.rejectedAt,
    this.dueAt,
    this.returnedAt,
    this.bookTitle,
    this.bookCover,
    this.bookCode,
    this.studentName,
    this.studentNumber,
  });

  factory Borrowing.fromJson(Map<String, dynamic> j) => Borrowing(
        id:            j['id'] as String,
        userId:        j['user_id'] as String,
        bookId:        j['book_id'] as String,
        status:        BorrowStatus.parse(j['status'] as String?),
        days:          (j['days'] as num?)?.toInt() ?? 14,
        notes:         j['notes'] as String?,
        requestedAt:   DateTime.tryParse(j['requested_at'] as String? ?? '')?.toLocal() ?? DateTime.now(),
        approvedAt:    _dt(j['approved_at']),
        approvedBy:    j['approved_by'] as String?,
        rejectedAt:    _dt(j['rejected_at']),
        dueAt:         _dt(j['due_at']),
        returnedAt:    _dt(j['returned_at']),
        fine:          (j['fine'] as num?)?.toDouble() ?? 0.0,
        bookTitle:     j['book_title'] as String?,
        bookCover:     j['book_cover'] as String?,
        bookCode:      j['book_code'] as String?,
        studentName:   j['student_name'] as String?,
        studentNumber: j['student_number'] as String?,
      );

  bool get isPending  => status == BorrowStatus.pending;
  bool get isActive   => status == BorrowStatus.approved;
  bool get isOverdue  => status == BorrowStatus.overdue ||
      (status == BorrowStatus.approved && dueAt != null && dueAt!.isBefore(DateTime.now()));
  bool get isReturned => status == BorrowStatus.returned;
  bool get isRejected => status == BorrowStatus.rejected;

  int? get daysUntilDue {
    if (dueAt == null) return null;
    return dueAt!.difference(DateTime.now()).inDays;
  }
}

DateTime? _dt(dynamic v) =>
    v is String ? DateTime.tryParse(v)?.toLocal() : null;
