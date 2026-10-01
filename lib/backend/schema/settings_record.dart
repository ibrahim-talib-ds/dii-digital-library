import 'dart:async';
import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class SettingsRecord extends FirestoreRecord {
  SettingsRecord._(DocumentReference reference, Map<String, dynamic> data)
      : super(reference, data) {
    _initializeFields();
  }

  String? _libraryName;
  String get libraryName => _libraryName ?? 'DII Digital Library';
  bool hasLibraryName() => _libraryName != null;

  String? _universityName;
  String get universityName => _universityName ?? 'Dushanbe Innovation Institute';
  bool hasUniversityName() => _universityName != null;

  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  String? _phone;
  String get phone => _phone ?? '';
  bool hasPhone() => _phone != null;

  String? _address;
  String get address => _address ?? '';
  bool hasAddress() => _address != null;

  int? _borrowingDays;
  int get borrowingDays => _borrowingDays ?? 14;
  bool hasBorrowingDays() => _borrowingDays != null;

  int? _maximumBooks;
  int get maximumBooks => _maximumBooks ?? 3;
  bool hasMaximumBooks() => _maximumBooks != null;

  String? _logo;
  String get logo => _logo ?? '';
  bool hasLogo() => _logo != null;

  void _initializeFields() {
    _libraryName = snapshotData['libraryName'] as String?;
    _universityName = snapshotData['universityName'] as String?;
    _email = snapshotData['email'] as String?;
    _phone = snapshotData['phone'] as String?;
    _address = snapshotData['address'] as String?;
    _borrowingDays = castToType<int>(snapshotData['borrowingDays']);
    _maximumBooks = castToType<int>(snapshotData['maximumBooks']);
    _logo = snapshotData['logo'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('settings');

  static Stream<SettingsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => SettingsRecord.fromSnapshot(s));

  static Future<SettingsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => SettingsRecord.fromSnapshot(s));

  static SettingsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      SettingsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static SettingsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) => SettingsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'SettingsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is SettingsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}
