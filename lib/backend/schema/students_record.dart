import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class StudentsRecord extends FirestoreRecord {
  StudentsRecord._(
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
  bool? _lastLogin;
  bool get lastLogin => _lastLogin ?? false;
  bool hasLastLogin() => _lastLogin != null;

  void _initializeFields() {
    _email = snapshotData['email'] as String?;
    _name = snapshotData['name'] as String?;
    _studentNumber = snapshotData['studentNumber'] as String?;
    _photoUrl = snapshotData['photoUrl'] as String?;
    _active = snapshotData['active'] as bool?;
    _createdAt = snapshotData['createdAt'] as DateTime?;
    _lastLogin = snapshotData['lastLogin'] as bool?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('students');

  static Stream<StudentsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => StudentsRecord.fromSnapshot(s));

  static Future<StudentsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => StudentsRecord.fromSnapshot(s));

  static StudentsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      StudentsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static StudentsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      StudentsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'StudentsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is StudentsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createStudentsRecordData({
  String? email,
  String? name,
  String? studentNumber,
  String? photoUrl,
  bool? active,
  DateTime? createdAt,
  bool? lastLogin,
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
    }.withoutNulls,
  );

  return firestoreData;
}

class StudentsRecordDocumentEquality implements Equality<StudentsRecord> {
  const StudentsRecordDocumentEquality();

  @override
  bool equals(StudentsRecord? e1, StudentsRecord? e2) {
    return e1?.email == e2?.email &&
        e1?.name == e2?.name &&
        e1?.studentNumber == e2?.studentNumber &&
        e1?.photoUrl == e2?.photoUrl &&
        e1?.active == e2?.active &&
        e1?.createdAt == e2?.createdAt &&
        e1?.lastLogin == e2?.lastLogin;
  }

  @override
  int hash(StudentsRecord? e) => const ListEquality().hash([
        e?.email,
        e?.name,
        e?.studentNumber,
        e?.photoUrl,
        e?.active,
        e?.createdAt,
        e?.lastLogin
      ]);

  @override
  bool isValidKey(Object? o) => o is StudentsRecord;
}
