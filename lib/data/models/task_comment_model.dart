import 'package:planapp/domain/entities/task_comment.dart';
import 'package:planapp/domain/entities/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskCommentModel extends TaskComment {
  const TaskCommentModel({
    required super.id,
    required super.projectId,
    required super.taskId,
    required super.author,
    required super.content,
    required super.createdAt,
  });

  factory TaskCommentModel.fromJson(Map<String, dynamic> json) {
    return TaskCommentModel(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      taskId: json['taskId'] as String,
      author: User(
        id: json['author']['id'] as String,
        email: json['author']['email'] as String,
        displayName:
            (json['author']['displayName'] ?? json['author']['email'])
                as String,
      ),
      content: json['content'] as String,
      createdAt: _parseCreatedAt(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'taskId': taskId,
      'author': {
        'id': author.id,
        'email': author.email,
        'displayName': author.displayName,
      },
      'content': content,
      'createdAt': createdAt,
    };
  }

  static DateTime _parseCreatedAt(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    return DateTime.now();
  }
}
