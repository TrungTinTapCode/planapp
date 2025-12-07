import 'package:planapp/domain/entities/user.dart';

class TaskComment {
  final String id;
  final String projectId;
  final String taskId;
  final User author;
  final String content;
  final DateTime createdAt;

  const TaskComment({
    required this.id,
    required this.projectId,
    required this.taskId,
    required this.author,
    required this.content,
    required this.createdAt,
  });
}
