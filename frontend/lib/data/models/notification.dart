import 'enums.dart';

class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final String? relatedId;
  final String? relatedType;
  final bool read;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.read,
    required this.createdAt,
    this.relatedId,
    this.relatedType,
  });

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
        id:          j['id'] as String,
        type:        NotificationType.parse(j['type'] as String?),
        title:       j['title'] as String,
        body:        j['body'] as String,
        relatedId:   j['related_id'] as String?,
        relatedType: j['related_type'] as String?,
        read:        j['read'] as bool? ?? false,
        createdAt:   DateTime.tryParse(j['created_at'] as String? ?? '')?.toLocal() ?? DateTime.now(),
      );

  AppNotification copyWith({bool? read}) => AppNotification(
        id: id,
        type: type,
        title: title,
        body: body,
        relatedId: relatedId,
        relatedType: relatedType,
        read: read ?? this.read,
        createdAt: createdAt,
      );
}
