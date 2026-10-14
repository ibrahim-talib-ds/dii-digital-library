import 'enums.dart';

class User {
  final String id;
  final String studentNumber;
  final String email;
  final String name;
  final UserRole role;
  final UserStatus status;
  final String? department;
  final int? year;
  final String? phone;
  final String? avatarUrl;
  final int borrowLimit;
  final DateTime? lastLoginAt;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.studentNumber,
    required this.email,
    required this.name,
    required this.role,
    required this.status,
    required this.borrowLimit,
    required this.createdAt,
    this.department,
    this.year,
    this.phone,
    this.avatarUrl,
    this.lastLoginAt,
  });

  factory User.fromJson(Map<String, dynamic> j) => User(
        id:            j['id'] as String,
        studentNumber: j['student_number'] as String,
        email:         j['email'] as String,
        name:          j['name'] as String,
        role:          UserRole.parse(j['role'] as String?),
        status:        UserStatus.parse(j['status'] as String?),
        department:    j['department'] as String?,
        year:          j['year'] as int?,
        phone:         j['phone'] as String?,
        avatarUrl:     j['avatar_url'] as String?,
        borrowLimit:   (j['borrow_limit'] as num?)?.toInt() ?? 3,
        lastLoginAt:   _parseDate(j['last_login_at']),
        createdAt:     _parseDate(j['created_at']) ?? DateTime.now(),
      );

  bool get isStudent   => role == UserRole.student;
  bool get isLibrarian => role == UserRole.librarian;
  bool get isAdmin     => role == UserRole.admin;
  bool get isStaff     => isLibrarian || isAdmin;
  bool get isBlocked   => status == UserStatus.blocked;
  bool get isActive    => status == UserStatus.active;
}

DateTime? _parseDate(dynamic v) {
  if (v == null) return null;
  if (v is String) return DateTime.tryParse(v)?.toLocal();
  return null;
}
