/// Mục đích: Entity Task cho tầng domain.
/// Vị trí: lib/domain/entities/task.dart

import 'package:planapp/domain/entities/task_priority.dart';
import 'package:planapp/domain/entities/user.dart';

/// Trạng thái của Task
enum TaskStatus { todo, inProgress, done }

/// Entity đại diện cho một task trong project
class Task {
  /// ID duy nhất của task
  final String id;

  /// ID của project chứa task này
  final String projectId;

  /// Tiêu đề của task
  final String title;

  /// Mô tả chi tiết của task
  final String description;

  /// Thời hạn hoàn thành task
  final DateTime? deadline;

  /// Danh sách tag của task
  final List<String> tags;

  /// Mức độ ưu tiên của task
  final TaskPriority priority;

  /// Người được gán cho task
  final User? assignee;

  /// Thời điểm tạo task
  final DateTime createdAt;

  /// Người tạo task
  final User creator;

  /// Trạng thái hoàn thành của task
  final bool isCompleted;

  /// Trạng thái tiến độ (3 trạng thái: todo/inProgress/done)
  final TaskStatus status;

  const Task({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    this.deadline,
    this.tags = const [],
    this.priority = TaskPriority.medium,
    this.assignee,
    required this.createdAt,
    required this.creator,
    this.isCompleted = false,
    this.status = TaskStatus.todo,
  });

  /// Copy task với các thuộc tính mới
  Task copyWith({
    String? id,
    String? projectId,
    String? title,
    String? description,
    DateTime? deadline,
    List<String>? tags,
    TaskPriority? priority,
    User? assignee,
    DateTime? createdAt,
    User? creator,
    bool? isCompleted,
    TaskStatus? status,
  }) {
    return Task(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      tags: tags ?? this.tags,
      priority: priority ?? this.priority,
      assignee: assignee ?? this.assignee,
      createdAt: createdAt ?? this.createdAt,
      creator: creator ?? this.creator,
      isCompleted: isCompleted ?? this.isCompleted,
      status: status ?? this.status,
    );
  }
}
