/// Mục đích: Model dữ liệu cho Task (data layer), dùng freezed/json_serializable nếu cần.
/// Vị trí: lib/data/models/task_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planapp/data/models/user_model.dart';
import 'package:planapp/domain/entities/task.dart';
import 'package:planapp/domain/entities/task_priority.dart';

/// Model đại diện cho Task trong tầng data, hỗ trợ JSON serialization
class TaskModel extends Task {
  const TaskModel({
    required super.id,
    required super.projectId,
    required super.title,
    required super.description,
    super.deadline,
    required super.tags,
    super.priority = TaskPriority.medium,
    super.assignee,
    required super.createdAt,
    required super.creator,
    super.isCompleted = false,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      deadline:
          json['deadline'] != null
              ? (json['deadline'] as Timestamp).toDate()
              : null,
      tags: List<String>.from(json['tags'] ?? []),
      priority:
          json['priority'] != null
              ? TaskPriorityX.fromString(json['priority'] as String)
              : TaskPriority.medium,
      assignee:
          json['assignee'] != null
              ? UserModel.fromJson(Map<String, dynamic>.from(json['assignee']))
              : null,
      createdAt:
          json['createdAt'] != null
              ? (json['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
      creator: UserModel.fromJson(Map<String, dynamic>.from(json['creator'])),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'title': title,
      'description': description,
      'deadline': deadline != null ? Timestamp.fromDate(deadline!) : null,
      'tags': tags,
      'priority': priority.name,
      'assignee': assignee != null ? (assignee as UserModel).toJson() : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'creator': (creator as UserModel).toJson(),
      'isCompleted': isCompleted,
    };
  }

  factory TaskModel.fromTask(Task task) {
    return TaskModel(
      id: task.id,
      projectId: task.projectId,
      title: task.title,
      description: task.description,
      deadline: task.deadline,
      tags: task.tags,
      priority: task.priority,
      assignee: task.assignee,
      createdAt: task.createdAt,
      creator: task.creator,
      isCompleted: task.isCompleted,
    );
  }
}
