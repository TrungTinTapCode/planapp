import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/app_notification.dart';

class NotificationModel extends AppNotification {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.body,
    required super.type,
    required super.isRead,
    required super.createdAt,
    super.projectId,
    super.taskId,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime created;
    final raw = map['createdAt'];
    if (raw is Timestamp) {
      created = raw.toDate();
    } else if (raw is DateTime) {
      created = raw;
    } else if (raw is String) {
      created = DateTime.tryParse(raw) ?? DateTime.now();
    } else {
      created = DateTime.now();
    }

    return NotificationModel(
      id: id,
      title: (map['title'] as String?) ?? '',
      body: (map['body'] as String?) ?? '',
      type: (map['type'] as String?) ?? 'GENERAL',
      isRead: (map['isRead'] as bool?) ?? false,
      createdAt: created,
      projectId: map['projectId'] as String?,
      taskId: map['taskId'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'body': body,
    'type': type,
    'isRead': isRead,
    'createdAt': Timestamp.fromDate(createdAt),
    'projectId': projectId,
    'taskId': taskId,
  };
}
