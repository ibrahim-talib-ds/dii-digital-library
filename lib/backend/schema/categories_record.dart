import 'dart:async';
import 'package:collection/collection.dart';
import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class CategoriesRecord extends FirestoreRecord {
  CategoriesRecord._(DocumentReference reference, Map<String, dynamic> data)
      : super(reference, data) {
    _initializeFields();
  }

  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  String? _description;
  String get description => _description ?? '';
  bool hasDescription() => _description != null;

  String? _icon;
  String get icon => _icon ?? '';
  bool hasIcon() => _icon != null;

  String? _color;
  String get color => _color ?? '#1B7A4E';
  bool hasColor() => _color != null;

  int? _order;
  int get order => _order ?? 0;
  bool hasOrder() => _order != null;

  bool? _isActive;
  bool get isActive => _isActive ?? true;
  bool hasIsActive() => _isActive != null;

  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  void _initializeFields() {
    _name = snapshotData['name'] as String?;
    _description = snapshotData['description'] as String?;
    _icon = snapshotData['icon'] as String?;
    _color = snapshotData['color'] as String?;
    _order = castToType<int>(snapshotData['order']);
    _isActive = snapshotData['isActive'] as bool?;
    _createdAt = snapshotData['createdAt'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('categories');

  static Stream<CategoriesRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => CategoriesRecord.fromSnapshot(s));

  static Future<CategoriesRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => CategoriesRecord.fromSnapshot(s));

  static CategoriesRecord fromSnapshot(DocumentSnapshot snapshot) =>
      CategoriesRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static CategoriesRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) => CategoriesRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'CategoriesRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is CategoriesRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createCategoriesRecordData({
  String? name,
  String? description,
  String? icon,
  String? color,
  int? order,
  bool? isActive,
  DateTime? createdAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
      'order': order,
      'isActive': isActive,
      'createdAt': createdAt,
    }.withoutNulls,
  );
  return firestoreData;
}
