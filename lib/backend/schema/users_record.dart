import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class UsersRecord extends FirestoreRecord {
  UsersRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "studentNumber" field.
  String? _studentNumber;
  String get studentNumber => _studentNumber ?? '';
  bool hasStudentNumber() => _studentNumber != null;

  // "photoUrl" field.
  String? _photoUrl;
  String get photoUrl => _photoUrl ?? '';
  bool hasPhotoUrl() => _photoUrl != null;

  // "active" field.
  bool? _active;
  bool get active => _active ?? false;
  bool hasActive() => _active != null;

  // "createdAt" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "lastLogin" field.
  DateTime? _lastLogin;
  DateTime? get lastLogin => _lastLogin;
  bool hasLastLogin() => _lastLogin != null;

  // "role" field.
  String? _role;
  String get role => _role ?? 'student';
  bool hasRole() => _role != null;

  // "department" field.
  String? _department;
  String get department => _department ?? '';
  bool hasDepartment() => _department != null;

  // "status" field.
  String? _status;
  String get status => _status ?? 'active';
  bool hasStatus() => _status != null;

  // "borrowLimit" field.
  int? _borrowLimit;
  int get borrowLimit => _borrowLimit ?? 3;
  bool hasBorrowLimit() => _borrowLimit != null;

  // "phone" field.
  String? _phone;
  String get phone => _phone ?? '';
  bool hasPhone() => _phone != null;

  // "year" field.
  int? _year;
  int get year => _year ?? 0;
  bool hasYear() => _year != null;

  void _initializeFields() {
    _role = snapshotData['role'] as String?;
    _department = snapshotData['department'] as String?;
    _status = snapshotData['status'] as String?;
    _borrowLimit = castToType<int>(snapshotData['borrowLimit']);
    _phone = snapshotData['phone'] as String?;
    _year = castToType<int>(snapshotData['year']);
    _email = snapshotData['email'] as String?;
    _name = snapshotData['name'] as String?;
    _studentNumber = snapshotData['studentNumber'] as String?;
    _photoUrl = snapshotData['photoUrl'] as String?;
    _active = snapshotData['active'] as bool?;
    _createdAt = snapshotData['createdAt'] as DateTime?;
    _lastLogin = snapshotData['lastLogin'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('users');

  static Stream<UsersRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => UsersRecord.fromSnapshot(s));

  static Future<UsersRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => UsersRecord.fromSnapshot(s));

  static UsersRecord fromSnapshot(DocumentSnapshot snapshot) =>
      UsersRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static UsersRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      UsersRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'UsersRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is UsersRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createUsersRecordData({
  String? email,
  String? name,
  String? studentNumber,
  String? photoUrl,
  bool? active,
  DateTime? createdAt,
  DateTime? lastLogin,
  String? role,
  String? department,
  String? status,
  int? borrowLimit,
  String? phone,
  int? year,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'email': email,
      'name': name,
      'studentNumber': studentNumber,
      'photoUrl': photoUrl,
      'active': active,
      'createdAt': createdAt,
      'lastLogin': lastLogin,
      'role': role,
      'department': department,
      'status': status,
      'borrowLimit': borrowLimit,
      'phone': phone,
      'year': year,
    }.withoutNulls,
  );

  return firestoreData;
}

class UsersRecordDocumentEquality implements Equality<UsersRecord> {
  const UsersRecordDocumentEquality();

  @override
  bool equals(UsersRecord? e1, UsersRecord? e2) {
    return e1?.email == e2?.email &&
        e1?.name == e2?.name &&
        e1?.studentNumber == e2?.studentNumber &&
        e1?.photoUrl == e2?.photoUrl &&
        e1?.active == e2?.active &&
        e1?.createdAt == e2?.createdAt &&
        e1?.lastLogin == e2?.lastLogin &&
        e1?.role == e2?.role &&
        e1?.department == e2?.department &&
        e1?.status == e2?.status &&
        e1?.borrowLimit == e2?.borrowLimit &&
        e1?.phone == e2?.phone &&
        e1?.year == e2?.year;
  }

  @override
  int hash(UsersRecord? e) => const ListEquality().hash([
        e?.email,
        e?.name,
        e?.studentNumber,
        e?.photoUrl,
        e?.active,
        e?.createdAt,
        e?.lastLogin,
        e?.role,
        e?.department,
        e?.status,
        e?.borrowLimit,
        e?.phone,
        e?.year
      ]);

  @override
  bool isValidKey(Object? o) => o is UsersRecord;
}
