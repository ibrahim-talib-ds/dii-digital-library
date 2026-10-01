import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class BorrowingsRecord extends FirestoreRecord {
  BorrowingsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "userId" field.
  String? _userId;
  String get userId => _userId ?? '';
  bool hasUserId() => _userId != null;

  // "studentNumber" field.
  String? _studentNumber;
  String get studentNumber => _studentNumber ?? '';
  bool hasStudentNumber() => _studentNumber != null;

  // "userName" field.
  String? _userName;
  String get userName => _userName ?? '';
  bool hasUserName() => _userName != null;

  // "bookId" field.
  String? _bookId;
  String get bookId => _bookId ?? '';
  bool hasBookId() => _bookId != null;

  // "bookTitle" field.
  String? _bookTitle;
  String get bookTitle => _bookTitle ?? '';
  bool hasBookTitle() => _bookTitle != null;

  // "bookCover" field.
  String? _bookCover;
  String get bookCover => _bookCover ?? '';
  bool hasBookCover() => _bookCover != null;

  // "borrowedAt" field.
  DateTime? _borrowedAt;
  DateTime? get borrowedAt => _borrowedAt;
  bool hasBorrowedAt() => _borrowedAt != null;

  // "dueDate" field.
  DateTime? _dueDate;
  DateTime? get dueDate => _dueDate;
  bool hasDueDate() => _dueDate != null;

  // "returnedAt" field.
  DateTime? _returnedAt;
  DateTime? get returnedAt => _returnedAt;
  bool hasReturnedAt() => _returnedAt != null;

  // "status" field.
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  // "receivedBy" field.
  String? _receivedBy;
  String get receivedBy => _receivedBy ?? '';
  bool hasReceivedBy() => _receivedBy != null;

  // "notes" field.
  String? _notes;
  String get notes => _notes ?? '';
  bool hasNotes() => _notes != null;

  // "bookCode" field.
  String? _bookCode;
  String get bookCode => _bookCode ?? '';
  bool hasBookCode() => _bookCode != null;

  // "approvedBy" field.
  String? _approvedBy;
  String get approvedBy => _approvedBy ?? '';
  bool hasApprovedBy() => _approvedBy != null;

  // "approvedAt" field.
  DateTime? _approvedAt;
  DateTime? get approvedAt => _approvedAt;
  bool hasApprovedAt() => _approvedAt != null;

  // "requestStatus" field.
  String? _requestStatus;
  String get requestStatus => _requestStatus ?? 'pending';
  bool hasRequestStatus() => _requestStatus != null;

  // "fine" field.
  double? _fine;
  double get fine => _fine ?? 0.0;
  bool hasFine() => _fine != null;

  void _initializeFields() {
    _bookCode = snapshotData['bookCode'] as String?;
    _approvedBy = snapshotData['approvedBy'] as String?;
    _approvedAt = snapshotData['approvedAt'] as DateTime?;
    _requestStatus = snapshotData['requestStatus'] as String?;
    _fine = castToType<double>(snapshotData['fine']);
    _userId = snapshotData['userId'] as String?;
    _studentNumber = snapshotData['studentNumber'] as String?;
    _userName = snapshotData['userName'] as String?;
    _bookId = snapshotData['bookId'] as String?;
    _bookTitle = snapshotData['bookTitle'] as String?;
    _bookCover = snapshotData['bookCover'] as String?;
    _borrowedAt = snapshotData['borrowedAt'] as DateTime?;
    _dueDate = snapshotData['dueDate'] as DateTime?;
    _returnedAt = snapshotData['returnedAt'] as DateTime?;
    _status = snapshotData['status'] as String?;
    _receivedBy = snapshotData['receivedBy'] as String?;
    _notes = snapshotData['notes'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('borrowings');

  static Stream<BorrowingsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => BorrowingsRecord.fromSnapshot(s));

  static Future<BorrowingsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => BorrowingsRecord.fromSnapshot(s));

  static BorrowingsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      BorrowingsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static BorrowingsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      BorrowingsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'BorrowingsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is BorrowingsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createBorrowingsRecordData({
  String? userId,
  String? studentNumber,
  String? userName,
  String? bookId,
  String? bookTitle,
  String? bookCover,
  DateTime? borrowedAt,
  DateTime? dueDate,
  DateTime? returnedAt,
  String? status,
  String? receivedBy,
  String? notes,
  String? bookCode,
  String? approvedBy,
  DateTime? approvedAt,
  String? requestStatus,
  double? fine,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'userId': userId,
      'studentNumber': studentNumber,
      'userName': userName,
      'bookId': bookId,
      'bookTitle': bookTitle,
      'bookCover': bookCover,
      'borrowedAt': borrowedAt,
      'dueDate': dueDate,
      'returnedAt': returnedAt,
      'status': status,
      'receivedBy': receivedBy,
      'notes': notes,
      'bookCode': bookCode,
      'approvedBy': approvedBy,
      'approvedAt': approvedAt,
      'requestStatus': requestStatus,
      'fine': fine,
    }.withoutNulls,
  );

  return firestoreData;
}

class BorrowingsRecordDocumentEquality implements Equality<BorrowingsRecord> {
  const BorrowingsRecordDocumentEquality();

  @override
  bool equals(BorrowingsRecord? e1, BorrowingsRecord? e2) {
    return e1?.userId == e2?.userId &&
        e1?.studentNumber == e2?.studentNumber &&
        e1?.userName == e2?.userName &&
        e1?.bookId == e2?.bookId &&
        e1?.bookTitle == e2?.bookTitle &&
        e1?.bookCover == e2?.bookCover &&
        e1?.borrowedAt == e2?.borrowedAt &&
        e1?.dueDate == e2?.dueDate &&
        e1?.returnedAt == e2?.returnedAt &&
        e1?.status == e2?.status &&
        e1?.receivedBy == e2?.receivedBy &&
        e1?.notes == e2?.notes &&
        e1?.bookCode == e2?.bookCode &&
        e1?.approvedBy == e2?.approvedBy &&
        e1?.approvedAt == e2?.approvedAt &&
        e1?.requestStatus == e2?.requestStatus &&
        e1?.fine == e2?.fine;
  }

  @override
  int hash(BorrowingsRecord? e) => const ListEquality().hash([
        e?.userId,
        e?.studentNumber,
        e?.userName,
        e?.bookId,
        e?.bookTitle,
        e?.bookCover,
        e?.borrowedAt,
        e?.dueDate,
        e?.returnedAt,
        e?.status,
        e?.receivedBy,
        e?.notes,
        e?.bookCode,
        e?.approvedBy,
        e?.approvedAt,
        e?.requestStatus,
        e?.fine
      ]);

  @override
  bool isValidKey(Object? o) => o is BorrowingsRecord;
}
