import 'package:equatable/equatable.dart';

class AppNotification extends Equatable {
  final String id;
  final String title;
  final String body;
  final String type; // TASK_ASSIGNED, MENTIONED, DEADLINE_SOON
  final bool isRead;
  final DateTime createdAt;
  final String? projectId;
  final String? taskId;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.projectId,
    this.taskId,
  });

  AppNotification copyWith({bool? isRead}) => AppNotification(
    id: id,
    title: title,
    body: body,
    type: type,
    isRead: isRead ?? this.isRead,
    createdAt: createdAt,
    projectId: projectId,
    taskId: taskId,
  );

  @override
  List<Object?> get props => [
    id,
    title,
    body,
    type,
    isRead,
    createdAt,
    projectId,
    taskId,
  ];
}
