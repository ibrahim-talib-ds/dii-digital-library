enum UserRole {
  student, librarian, admin;

  static UserRole parse(String? v) => switch (v) {
        'librarian' => UserRole.librarian,
        'admin'     => UserRole.admin,
        _           => UserRole.student,
      };

  String get label => switch (this) {
        UserRole.student   => 'Student',
        UserRole.librarian => 'Librarian',
        UserRole.admin     => 'Admin',
      };
}

enum UserStatus {
  active, blocked;

  static UserStatus parse(String? v) =>
      v == 'blocked' ? UserStatus.blocked : UserStatus.active;
}

enum BorrowStatus {
  pending, approved, rejected, returned, overdue, cancelled;

  static BorrowStatus parse(String? v) => switch (v) {
        'pending'   => BorrowStatus.pending,
        'approved'  => BorrowStatus.approved,
        'rejected'  => BorrowStatus.rejected,
        'returned'  => BorrowStatus.returned,
        'overdue'   => BorrowStatus.overdue,
        'cancelled' => BorrowStatus.cancelled,
        _           => BorrowStatus.pending,
      };

  String get label => switch (this) {
        BorrowStatus.pending   => 'Pending',
        BorrowStatus.approved  => 'Active',
        BorrowStatus.rejected  => 'Rejected',
        BorrowStatus.returned  => 'Returned',
        BorrowStatus.overdue   => 'Overdue',
        BorrowStatus.cancelled => 'Cancelled',
      };
}

enum NotificationType {
  request, approved, rejected, returned, overdue, info;

  static NotificationType parse(String? v) => switch (v) {
        'request'  => NotificationType.request,
        'approved' => NotificationType.approved,
        'rejected' => NotificationType.rejected,
        'returned' => NotificationType.returned,
        'overdue'  => NotificationType.overdue,
        _          => NotificationType.info,
      };
}
