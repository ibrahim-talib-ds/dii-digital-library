import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class BooksRecord extends FirestoreRecord {
  BooksRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  bool hasTitle() => _title != null;

  // "author" field.
  String? _author;
  String get author => _author ?? '';
  bool hasAuthor() => _author != null;

  // "category" field.
  String? _category;
  String get category => _category ?? '';
  bool hasCategory() => _category != null;

  // "description" field.
  String? _description;
  String get description => _description ?? '';
  bool hasDescription() => _description != null;

  // "pdfUrl" field.
  String? _pdfUrl;
  String get pdfUrl => _pdfUrl ?? '';
  bool hasPdfUrl() => _pdfUrl != null;

  // "createdAt" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "Cover_url" field.
  String? _coverUrl;
  String get coverUrl => _coverUrl ?? '';
  bool hasCoverUrl() => _coverUrl != null;

  // "is_computer_science" field.
  bool? _isComputerScience;
  bool get isComputerScience => _isComputerScience ?? false;
  bool hasIsComputerScience() => _isComputerScience != null;

  // "is_artificial_intelligence" field.
  bool? _isArtificialIntelligence;
  bool get isArtificialIntelligence => _isArtificialIntelligence ?? false;
  bool hasIsArtificialIntelligence() => _isArtificialIntelligence != null;

  // "is_biotechnology" field.
  bool? _isBiotechnology;
  bool get isBiotechnology => _isBiotechnology ?? false;
  bool hasIsBiotechnology() => _isBiotechnology != null;

  // "is_business_data_science" field.
  bool? _isBusinessDataScience;
  bool get isBusinessDataScience => _isBusinessDataScience ?? false;
  bool hasIsBusinessDataScience() => _isBusinessDataScience != null;

  // "is_business_innovation" field.
  bool? _isBusinessInnovation;
  bool get isBusinessInnovation => _isBusinessInnovation ?? false;
  bool hasIsBusinessInnovation() => _isBusinessInnovation != null;

  // "is_mathematics" field.
  bool? _isMathematics;
  bool get isMathematics => _isMathematics ?? false;
  bool hasIsMathematics() => _isMathematics != null;

  // "is_all" field.
  bool? _isAll;
  bool get isAll => _isAll ?? false;
  bool hasIsAll() => _isAll != null;

  // "language" field.
  String? _language;
  String get language => _language ?? '';
  bool hasLanguage() => _language != null;

  // "pages" field.
  int? _pages;
  int get pages => _pages ?? 0;
  bool hasPages() => _pages != null;

  // "totalCopies" field.
  int? _totalCopies;
  int get totalCopies => _totalCopies ?? 0;
  bool hasTotalCopies() => _totalCopies != null;

  // "availableCopies" field.
  int? _availableCopies;
  int get availableCopies => _availableCopies ?? 0;
  bool hasAvailableCopies() => _availableCopies != null;

  // "status" field.
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  // "active" field.
  bool? _active;
  bool get active => _active ?? false;
  bool hasActive() => _active != null;

  void _initializeFields() {
    _title = snapshotData['title'] as String?;
    _author = snapshotData['author'] as String?;
    _category = snapshotData['category'] as String?;
    _description = snapshotData['description'] as String?;
    _pdfUrl = snapshotData['pdfUrl'] as String?;
    _createdAt = snapshotData['createdAt'] as DateTime?;
    _coverUrl = snapshotData['Cover_url'] as String?;
    _isComputerScience = snapshotData['is_computer_science'] as bool?;
    _isArtificialIntelligence =
        snapshotData['is_artificial_intelligence'] as bool?;
    _isBiotechnology = snapshotData['is_biotechnology'] as bool?;
    _isBusinessDataScience = snapshotData['is_business_data_science'] as bool?;
    _isBusinessInnovation = snapshotData['is_business_innovation'] as bool?;
    _isMathematics = snapshotData['is_mathematics'] as bool?;
    _isAll = snapshotData['is_all'] as bool?;
    _language = snapshotData['language'] as String?;
    _pages = castToType<int>(snapshotData['pages']);
    _totalCopies = castToType<int>(snapshotData['totalCopies']);
    _availableCopies = castToType<int>(snapshotData['availableCopies']);
    _status = snapshotData['status'] as String?;
    _active = snapshotData['active'] as bool?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('books');

  static Stream<BooksRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => BooksRecord.fromSnapshot(s));

  static Future<BooksRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => BooksRecord.fromSnapshot(s));

  static BooksRecord fromSnapshot(DocumentSnapshot snapshot) => BooksRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static BooksRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      BooksRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'BooksRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is BooksRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createBooksRecordData({
  String? title,
  String? author,
  String? category,
  String? description,
  String? pdfUrl,
  DateTime? createdAt,
  String? coverUrl,
  bool? isComputerScience,
  bool? isArtificialIntelligence,
  bool? isBiotechnology,
  bool? isBusinessDataScience,
  bool? isBusinessInnovation,
  bool? isMathematics,
  bool? isAll,
  String? language,
  int? pages,
  int? totalCopies,
  int? availableCopies,
  String? status,
  bool? active,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'title': title,
      'author': author,
      'category': category,
      'description': description,
      'pdfUrl': pdfUrl,
      'createdAt': createdAt,
      'Cover_url': coverUrl,
      'is_computer_science': isComputerScience,
      'is_artificial_intelligence': isArtificialIntelligence,
      'is_biotechnology': isBiotechnology,
      'is_business_data_science': isBusinessDataScience,
      'is_business_innovation': isBusinessInnovation,
      'is_mathematics': isMathematics,
      'is_all': isAll,
      'language': language,
      'pages': pages,
      'totalCopies': totalCopies,
      'availableCopies': availableCopies,
      'status': status,
      'active': active,
    }.withoutNulls,
  );

  return firestoreData;
}

class BooksRecordDocumentEquality implements Equality<BooksRecord> {
  const BooksRecordDocumentEquality();

  @override
  bool equals(BooksRecord? e1, BooksRecord? e2) {
    return e1?.title == e2?.title &&
        e1?.author == e2?.author &&
        e1?.category == e2?.category &&
        e1?.description == e2?.description &&
        e1?.pdfUrl == e2?.pdfUrl &&
        e1?.createdAt == e2?.createdAt &&
        e1?.coverUrl == e2?.coverUrl &&
        e1?.isComputerScience == e2?.isComputerScience &&
        e1?.isArtificialIntelligence == e2?.isArtificialIntelligence &&
        e1?.isBiotechnology == e2?.isBiotechnology &&
        e1?.isBusinessDataScience == e2?.isBusinessDataScience &&
        e1?.isBusinessInnovation == e2?.isBusinessInnovation &&
        e1?.isMathematics == e2?.isMathematics &&
        e1?.isAll == e2?.isAll &&
        e1?.language == e2?.language &&
        e1?.pages == e2?.pages &&
        e1?.totalCopies == e2?.totalCopies &&
        e1?.availableCopies == e2?.availableCopies &&
        e1?.status == e2?.status &&
        e1?.active == e2?.active;
  }

  @override
  int hash(BooksRecord? e) => const ListEquality().hash([
        e?.title,
        e?.author,
        e?.category,
        e?.description,
        e?.pdfUrl,
        e?.createdAt,
        e?.coverUrl,
        e?.isComputerScience,
        e?.isArtificialIntelligence,
        e?.isBiotechnology,
        e?.isBusinessDataScience,
        e?.isBusinessInnovation,
        e?.isMathematics,
        e?.isAll,
        e?.language,
        e?.pages,
        e?.totalCopies,
        e?.availableCopies,
        e?.status,
        e?.active
      ]);

  @override
  bool isValidKey(Object? o) => o is BooksRecord;
}
